//
//  NewRunViewController.m
//  RunMonitor
//
//  Created by Barry Julien on 5/19/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import "NewRunViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MapKit/MapKit.h>
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "RunDetailsViewController.h"
#import "BadgeController.h"
#import "Badge.h"
#import <AVFoundation/AVFoundation.h>

NSString * const detailSegueName = @"NewRunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Run *run;
@property (nonatomic, strong) Badge *upcomingBadge;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UILabel *nextBadgeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *progressImageView;
@property (nonatomic, weak) IBOutlet UIImageView *nextBadgeImageView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;


//@property (nonatomic, strong) AVAudioPlayer * _audioPlayer;


@end

@implementation NewRunViewController

#pragma mark - Lifecycle


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    self.timeLabel.text = @"";
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.nextBadgeLabel.hidden = YES;
    self.stopButton.hidden = NO;
    self.nextBadgeImageView.hidden = YES;
    self.progressImageView.hidden = YES;
    self.mapView.hidden = NO;
    
    [self startrun];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

-(void) startrun{
    
    UIBackgroundTaskIdentifier bgTask;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    self.seconds = 0;
    
    // initialize the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    
    self.distance = 0;
    self.locations = [NSMutableArray array];
    
    [self startLocationUpdates];
}

#pragma mark - IBActions

-(IBAction)startPressed:(id)sender
{
    // hide the start UI
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    // show the running UI
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.stopButton.hidden = NO;
    self.progressImageView.hidden = YES;
    self.nextBadgeImageView.hidden = YES;
    self.nextBadgeLabel.hidden = YES;
    self.mapView.hidden = NO;
    
    self.seconds = 0;
    
    // initialize the timer
	self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    
    self.distance = 0;
    self.locations = [NSMutableArray array];
    
    [self startLocationUpdates];
}

- (IBAction)stopPressed:(id)sender
{
    NSLog(@"Pace label test:%@", self.paceLabel.text);
    NSLog(@"Distance label test:%@", self.distLabel.text);
    
    if([self.paceLabel.text isEqualToString:@"Speed: 0"] && [self.distLabel.text isEqualToString:@"Distance: 0.00 mi"]){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Discard", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
        
    }
    else{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    }
}

#pragma mark - Private

- (void)saveRun
{
    
    
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void)eachSecond
{
    self.seconds++;
    [self updateProgressImageView];
    [self maybePlaySound];
    [self updateLabels];
}

- (void)updateProgressImageView
{
    int currentPosition = self.progressImageView.frame.origin.x;
    CGRect newRect = self.progressImageView.frame;
    
    switch (currentPosition) {
        case 20:
            newRect.origin.x = 80;
            break;
        case 80:
            newRect.origin.x = 140;
            break;
        default:
            newRect.origin.x = 20;
            break;
    }
    
    self.progressImageView.frame = newRect;
}

- (void)updateLabels
{
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    //NSLog(@"TIME IS: %@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]);
    
    NSLog(@"DISTANCE/SECONDS: %@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]);
    
    
    if(self.distance/self.seconds > 0){
        NSString *mySpeed = [[NSString alloc]initWithFormat:@"%@",[MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        NSString *speedTrunc7 = [mySpeed substringToIndex:[mySpeed length]-7];
        //NSLog(@"VALUE OF SPEEDTRUNC7 MIN:SEC: %@", speedTrunc7);
        
        NSString *speedTrunc3 = [speedTrunc7 substringToIndex:[speedTrunc7 length]-3];
        //NSLog(@"VALUE OF SPEEDTRUNC3 MIN: %@", speedTrunc3);
        
        NSString *speedTrunc3begin = [speedTrunc7 substringFromIndex:3];
        //NSLog(@"VALUE OF SPEEDTRUNC3BEGIN SEC: %@", speedTrunc3begin);
    //}
        
         NSString *myTime = [[NSString alloc]initWithFormat:@"%@",[MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
         NSString *timeTrunc3 = [myTime substringToIndex:[myTime length]-3];
         NSString *timeTrunc3begin = [myTime substringFromIndex:3];
    
    //NSString *mySpeed = [[NSString alloc]initWithFormat:@"%@",[MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    
    //NSString *speedTrunc = [mySpeed substringToIndex:[mySpeed length]-10];
    
    //NSLog(@"TIME VALUE IN SECONDS: %i", self.seconds);
    double mins = self.seconds/60.0;
    //NSLog(@"TIME VALUE IN MINUTES: %f", mins);
    //NSLog(@"VALUE OF SPEED: %@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]);
    //NSLog(@"VALUE OF SPEED MINUTES: %@", mySpeed);
    if(fmod(mins,5) == 0){
        
        if([timeTrunc3 isEqualToString:@"05"]){
            NSString *fiveMinuteTime = @"5";
            NSString * newText = [[NSString alloc] initWithFormat:@"Time %@ minutes %@ seconds, distance %@, speed %@ minutes %@ seconds per mile.", fiveMinuteTime, timeTrunc3begin,[MathController stringifyDistance:self.distance],speedTrunc3, speedTrunc3begin];
            
            NSLog(@"YOU HAVE BEEN RUNNING FOR %@ MINUTES %@ SECONDS! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@", fiveMinuteTime, timeTrunc3begin,[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance
                                            speechUtteranceWithString:newText];
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            utterance.rate = 0.45;
            utterance.pitchMultiplier = 0.95;
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
            utterance.volume = 0.75;
            
            [synth speakUtterance:utterance];
            
        }else{
        NSLog(@"YOU HAVE BEEN RUNNING FOR %@ MINUTES %@ SECONDS! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@", timeTrunc3, timeTrunc3begin,[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
        
        NSString * newText = [[NSString alloc] initWithFormat:@"Time %@ minutes %@ seconds, distance %@, speed %@ minutes %@ seconds per mile.", timeTrunc3, timeTrunc3begin,[MathController stringifyDistance:self.distance],speedTrunc3, speedTrunc3begin];
        
                
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:newText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
        utterance.volume = 0.75;
        
        [synth speakUtterance:utterance];
            }
    }
    }
    
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Speed: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    self.nextBadgeLabel.text = [NSString stringWithFormat:@"%@ until %@!", [MathController stringifyDistance:(self.upcomingBadge.distance - self.distance)], self.upcomingBadge.name];
    
//    if([[MathController stringifySecondCount:self.seconds usingLongFormat:NO] isEqual:@"01:00"]){
//        NSLog(@"YOU HAVE BEEN RUNNING FOR 1 MINUTE! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@",[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
//    }
//    
//    if([[MathController stringifySecondCount:self.seconds usingLongFormat:NO] isEqual:@"05:00"]){
//        NSLog(@"YOU HAVE BEEN RUNNING FOR 5 MINUTES! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@",[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
//    }
}


- (void) maybePlaySound
{
    Badge *nextBadge = [[BadgeController defaultController] nextBadgeForDistance:self.distance];
    
    if (self.upcomingBadge
        && ![nextBadge.name isEqualToString:self.upcomingBadge.name]) {
        
        [self playSuccessSound];
    }
    
    self.upcomingBadge = nextBadge;
    self.nextBadgeImageView.image = [UIImage imageNamed:nextBadge.imageName];
}

- (void)playSuccessSound
{
    NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/genericsuccess.wav"];
    SystemSoundID soundID;
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(filePath), &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    //also vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[self.locationManager stopUpdatingLocation];
    
    NSLog(@"Pace label test:%@", self.paceLabel.text);
    NSLog(@"Distance label test:%@", self.distLabel.text);
    
    if([self.paceLabel.text isEqualToString:@"Speed: 0"] && [self.distLabel.text isEqualToString:@"Distance: 0.00 mi"]){
        
        // discard
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else{
    
    // save
    if (buttonIndex == 0) {
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
        
    // discard
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;

                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
                
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        [[segue destinationViewController] setRun:self.run];
    }
}

@end
