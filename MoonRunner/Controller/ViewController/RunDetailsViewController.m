#import <MapKit/MapKit.h>
#import "RunDetailsViewController.h"
#import "Run.h"
#import "MathController.h"
#import "Badge.h"
#import "BadgeController.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"
#import "BadgeAnnotation.h"
#import <AVFoundation/AVFoundation.h>

static float const mapPadding = 1.1f;

@interface RunDetailsViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSArray *colorSegmentArray;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;

@property (nonatomic, strong) NSString * currentRun;
@property (nonatomic, strong) NSString * pastRun;
@property (nonatomic, strong) NSString * totalRun;

@property (strong, nonatomic) NSArray *objects;

- (IBAction)goHome:(id)sender;




@end

@implementation RunDetailsViewController

#pragma mark - Lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    [self loadMap];
    
    self.infoButton.hidden = YES;
    
}

#pragma mark - IBActions

-(IBAction)displayModeToggled:(UISwitch *)sender
{
    self.badgeImageView.hidden = !sender.isOn;
    self.infoButton.hidden = !sender.isOn;
    self.mapView.hidden = sender.isOn;
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:badge.name
                              message:badge.information
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Private

- (void)configureView
{
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];
    
    self.paceLabel.text = [NSString stringWithFormat:@"Speed: %@",  [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestop == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){ //begin if no results
        
        NSString *paceTrunc7 = [self.paceLabel.text substringToIndex:[self.paceLabel.text length]-7];
        //NSLog(@"PACETRUNC7 is %@", paceTrunc7);
        NSString *paceTrunc6begin = [paceTrunc7 substringFromIndex:6];
        NSString *paceSec = [paceTrunc6begin substringFromIndex:3];
        NSString *paceMin = [paceTrunc6begin substringToIndex:[paceTrunc6begin length]-3];
        
        //NSLog(@"PACETRUNC^BEGIN is %@, PACESEC is %@, PACEMIN is %@", paceTrunc6begin, paceSec, paceMin);
        
        
        NSString *stopText = [[NSString alloc]initWithFormat:@"Run saved. Distance %@, %@, Speed %@ minutes %@ seconds per mile.", self.distanceLabel.text, self.timeLabel.text, paceMin, paceSec];
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:stopText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
        
    }
    else{
        NSLog(@"STOP RUN VOICE IS OFF.");
        
    }
    
    
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    self.badgeImageView.image = [UIImage imageNamed:badge.imageName];
    
    NSLog(@"BADGE IMAGENAME: %@", badge.imageName);
    
    if([badge.imageName isEqualToString:@"white.png"]){
    
        self.noticeLabel.text = @"Congrats! You ran between 0 and 5 miles and got to badge level White on this run.";
    }
    else if([badge.imageName isEqualToString:@"bronze.png"]){
        self.noticeLabel.text = @"Congrats! You ran between 5 and 10 miles and got to badge level Bronze on this run.";
    }
    else if([badge.imageName isEqualToString:@"silver.png"]){
        self.noticeLabel.text = @"Congrats! You ran between 10 and 15 miles and got to badge level Silver on this run.";
    }
    else if([badge.imageName isEqualToString:@"gold.png"]){
        self.noticeLabel.text = @"Congrats! You ran between 15 and 20 miles and got to badge level Gold on this run.";
    }
    else if([badge.imageName isEqualToString:@"royalpurple.png"]){
        self.noticeLabel.text = @"Congrats! You ran more than 20 miles and got to badge level Royal Purple on this run. You've done it!";
    }
    else{
        self.noticeLabel.text = @"";
    }
}

- (void)loadMap
{
    if (self.run.locations.count > 0) {
        
        self.mapView.hidden = NO;
        
        // set the map bounds
        [self.mapView setRegion:[self mapRegion]];
        
        // make the line(s!) on the map
        [self.mapView addOverlays:self.colorSegmentArray];
        
        [self.mapView addAnnotations:[[BadgeController defaultController] annotationsForRun:self.run]];
        
    } else {
        
        // no locations were found!
        self.mapView.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Sorry, this run has no locations saved."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Public

- (void)setRun:(Run *)newDetailRun
{
    if (_run != newDetailRun) {
        _run = newDetailRun;
        
        self.colorSegmentArray = [MathController colorSegmentsForLocations:newDetailRun.locations.array];
    }
}

#pragma mark - MKMapViewDelegate

- (MKCoordinateRegion)mapRegion
{
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * mapPadding;
    region.span.longitudeDelta = (maxLng - minLng) * mapPadding;
    
    return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MulticolorPolylineSegment class]]) {
        MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    BadgeAnnotation *badgeAnnotation = (BadgeAnnotation *)annotation;
        
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"checkpoint"];
    if (!annView) {
        annView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"checkpoint"];
        annView.image = [UIImage imageNamed:@"mapPin"];
        annView.canShowCallout = YES;
    }
    
    UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 50)];
    badgeImageView.image = [UIImage imageNamed:badgeAnnotation.imageName];
    badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
    annView.leftCalloutAccessoryView = badgeImageView;
    
    return annView;
}

- (IBAction)goHome:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
