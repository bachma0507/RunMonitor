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
#import "GVMusicPlayerController.h"
#import "NSString+TimeToString.h"


NSString * const detailSegueName = @"NewRunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate, GVMusicPlayerControllerDelegate, MPMediaPickerControllerDelegate>

{
    double pastMiles;
    double currentMiles;
    double totalMiles;
}


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

@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *itunesButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
//@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
//@property (weak, nonatomic) IBOutlet UILabel *trackCurrentPlaybackTimeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;
//@property (weak, nonatomic) IBOutlet UIView *chooseView;
//@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
//@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (strong, nonatomic) NSTimer *timerMusic;
@property BOOL panningProgress;
@property BOOL panningVolume;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *norunsongsLabel;

@property (strong, nonatomic) NSArray *objects;
//@property (nonatomic, strong) NSString *voiceMileValueStr;

//@property (nonatomic, strong) AVAudioPlayer * _audioPlayer;


@end

@implementation NewRunViewController

#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //[self.view bringSubviewToFront:self.chooseView];
    
//    self.timerMusic = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
//    [self.timerMusic fire];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
    
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
    self.itunesButton.hidden = YES;
    
    [self startrun];
    
    [self playMusic];
    
    NSLog(@"SONG LABEL TEXT IS: %@", self.songLabel.text);
    
    if(self.songLabel.text == NULL){
        
        self.playerView.hidden = YES;
    }
    else{
        
        self.norunsongsLabel.hidden = YES;
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[GVMusicPlayerController sharedInstance] removeDelegate:self];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];

    
    [self.timer invalidate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[GVMusicPlayerController sharedInstance] removeDelegate:self];
    [super viewDidDisappear:animated];
}

//- (void)timedJob {
//    if (!self.panningProgress) {
//        self.progressSlider.value = [GVMusicPlayerController sharedInstance].currentPlaybackTime;
//        self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:[GVMusicPlayerController sharedInstance].currentPlaybackTime];
//    }
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //self.shuffleButton.selected = ([GVMusicPlayerController sharedInstance].shuffleMode != MPMusicShuffleModeOff);
    //[self setCorrectRepeatButtomImage];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    [[GVMusicPlayerController sharedInstance] remoteControlReceivedWithEvent:receivedEvent];
}



-(void)playMusic{
    
//    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
//        [[GVMusicPlayerController sharedInstance] pause];
//    } else {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"songsList"] != nil) {
        
        NSMutableArray *theList = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"songsList"];
        
        NSArray *decodedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [theList addObjectsFromArray:decodedData];
        
        NSMutableArray *allTheSongs = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i = 0; i < [theList count]; i++) {
            
            MPMediaQuery *songQuery = [MPMediaQuery songsQuery];
            
            [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[theList objectAtIndex:i] forProperty:MPMediaItemPropertyPersistentID]];
            
            NSArray *songs = [songQuery items];
            
            [allTheSongs addObjectsFromArray: songs];
            
        }
        
        NSLog(@"ALLTHESONGS ARRAY COUNT: %lu", (unsigned long)allTheSongs.count);
        
        MPMediaItemCollection *currentQueue = [[MPMediaItemCollection alloc] initWithItems:allTheSongs];
        
        [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:currentQueue];
        
        [[GVMusicPlayerController sharedInstance] play];
        
    }
    else{
    
        [[GVMusicPlayerController sharedInstance] play];
    }
}

#pragma mark - IBActions

- (IBAction)playButtonPressed {
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
        [[GVMusicPlayerController sharedInstance] pause];
    } else {
        [[GVMusicPlayerController sharedInstance] play];
    }
}

- (IBAction)prevButtonPressed {
    [[GVMusicPlayerController sharedInstance] skipToPreviousItem];
}

- (IBAction)nextButtonPressed {
    [[GVMusicPlayerController sharedInstance] skipToNextItem];
}

- (IBAction)chooseButtonPressed {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void) playAfterPause{
    
    [[GVMusicPlayerController sharedInstance] play];
}
//
//- (IBAction)playEverythingButtonPressed {
//    MPMediaQuery *query = [MPMediaQuery songsQuery];
//    [[GVMusicPlayerController sharedInstance] setQueueWithQuery:query];
//    [[GVMusicPlayerController sharedInstance] play];
//}
//
//- (IBAction)volumeChanged:(UISlider *)sender {
//    self.panningVolume = YES;
//    [GVMusicPlayerController sharedInstance].volume = sender.value;
//}
//
//- (IBAction)volumeEnd {
//    self.panningVolume = NO;
//}
//
//- (IBAction)progressChanged:(UISlider *)sender {
//    // While dragging the progress slider around, we change the time label,
//    // but we're not actually changing the playback time yet.
//    self.panningProgress = YES;
//    self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:sender.value];
//}
//
//- (IBAction)progressEnd {
//    // Only when dragging is done, we change the playback time.
//    [GVMusicPlayerController sharedInstance].currentPlaybackTime = self.progressSlider.value;
//    self.panningProgress = NO;
//}
//
//- (IBAction)shuffleButtonPressed {
//    self.shuffleButton.selected = !self.shuffleButton.selected;
//    
//    if (self.shuffleButton.selected) {
//        [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeSongs;
//    } else {
//        [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeOff;
//    }
//}
//
//- (IBAction)repeatButtonPressed {
//    switch ([GVMusicPlayerController sharedInstance].repeatMode) {
//        case MPMusicRepeatModeAll:
//            // From all to one
//            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeOne;
//            break;
//            
//        case MPMusicRepeatModeOne:
//            // From one to none
//            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeNone;
//            break;
//            
//        case MPMusicRepeatModeNone:
//            // From none to all
//            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeAll;
//            break;
//            
//        default:
//            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeAll;
//            break;
//    }
//    
//    [self setCorrectRepeatButtomImage];
//}
//
//- (void)setCorrectRepeatButtomImage {
//    NSString *imageName;
//    
//    switch ([GVMusicPlayerController sharedInstance].repeatMode) {
//        case MPMusicRepeatModeAll:
//            imageName = @"Track_Repeat_On";
//            break;
//            
//        case MPMusicRepeatModeOne:
//            imageName = @"Track_Repeat_On_Track";
//            break;
//            
//        case MPMusicRepeatModeNone:
//            imageName = @"Track_Repeat_Off";
//            break;
//            
//        default:
//            imageName = @"Track_Repeat_Off";
//            break;
//    }
//    
//    [self.repeatButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//}

#pragma mark - GVMusicPlayerControllerDelegate

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState {
    self.playPauseButton.selected = (playbackState == MPMusicPlaybackStatePlaying);
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack {
//    if (!nowPlayingItem) {
//        self.chooseView.hidden = NO;
//        return;
//    }
    
    //self.chooseView.hidden = YES;
    
    // Time labels
//    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
//    self.trackLengthLabel.text = [NSString stringFromTime:trackLength];
//    self.progressSlider.value = 0;
//    self.progressSlider.maximumValue = trackLength;
    
    // Labels
    self.songLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    self.artistLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    
    
    // Artwork
    MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork != nil) {
        self.imageView.image = [artwork imageWithSize:self.imageView.frame.size];
    }
    
    NSLog(@"Proof that this code is being called, even in the background!");
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack {
    NSLog(@"End of queue, but last track was %@", [lastTrack valueForProperty:MPMediaItemPropertyTitle]);
}

//- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer volumeChanged:(float)volume {
//    if (!self.panningVolume) {
//        self.volumeSlider.value = volume;
//    }
//}

#pragma mark - MPMediaPickerControllerDelegate

//- (void)savePlaylist:(MPMediaItemCollection *) mediaItemCollection {
//    
//    NSArray* items = [mediaItemCollection items];
//    
//    NSMutableArray* listToSave = [[NSMutableArray alloc] initWithCapacity:0];
//    
//    for (MPMediaItem *song in items) {
//        
//        NSNumber *persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
//        
//        [listToSave addObject:persistentId];
//        
//    }
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: listToSave];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"songsList"];
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//}
//
//- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
//    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
//    [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:mediaItemCollection];
//    //[[GVMusicPlayerController sharedInstance] play];
//    [self savePlaylist:mediaItemCollection];
//    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
//}



-(void) startrun{
    
//     NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
//    
//    NSString *voiceMileStr = @"no";
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemile == 'no' || voicemile == 'yes'"]];
//    
//    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//    
//    self.objects = results;
//    
//    if (!results || !results.count){
//        NSLog(@"NO RESULTS FOR VOICEMILE IN MANAGEDOBJECTCONTEXT");
//        [newVoice setValue:voiceMileStr forKey:@"voicemile"];
//        
//        // Save the context.
//        NSError *error = nil;
//        if (![self.managedObjectContext save:&error]) {
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//
//    }
//    else{
//        NSManagedObject *object = [results objectAtIndex:0];
//        [object setValue:voiceMileStr forKey:@"voicemile"];
//        
//        NSError *error = nil;
//        // Save the object to persistent store
//        if (![self.managedObjectContext save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }
//        
//    }

    
    
    UIBackgroundTaskIdentifier bgTask;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestart == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){ //begin if no results
        
        
            
            NSString *startText = [[NSString alloc]initWithFormat:@"Run started."];
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance
                                            speechUtteranceWithString:startText];
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            utterance.rate = 0.45;
            utterance.pitchMultiplier = 0.95;
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
            utterance.volume = 0.75;
            
            [synth speakUtterance:utterance];
            
        
    }
    else{
        NSLog(@"START RUN VOICE IS OFF.");
        
    }
    
    
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
    
    
//    // hide the start UI
//    self.startButton.hidden = YES;
//    self.promptLabel.hidden = YES;
//    
//    // show the running UI
//    self.timeLabel.hidden = NO;
//    self.distLabel.hidden = NO;
//    self.paceLabel.hidden = NO;
//    self.stopButton.hidden = NO;
//    self.progressImageView.hidden = YES;
//    self.nextBadgeImageView.hidden = YES;
//    self.nextBadgeLabel.hidden = YES;
//    self.mapView.hidden = NO;
//    
//    self.seconds = 0;
//    
//    // initialize the timer
//	self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
//    
//    self.distance = 0;
//    self.locations = [NSMutableArray array];
//    
//    [self startLocationUpdates];
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
    
    //NSLog(@"DISTANCE IS %.2f", self.distance/1609.344);
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    NSLog(@"locationArray counts is: %lu", (unsigned long)locationArray.count);
    
    if (locationArray.count <= 2){
        
        [self.locationManager stopUpdatingLocation];
        [self.timer invalidate];
        //[locationArray removeAllObjects];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"There was a problem pinpointing your location on the map. Please try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = 1;
        [alertView show];
    }
    else{
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
        [self performSegueWithIdentifier:detailSegueName sender:nil];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //u need to change 0 to other value(,1,2,3) if u have more buttons.then u can check which button was pressed.
    if (alertView.tag ==1) {
        
        if (buttonIndex == 0) {
            
            [[GVMusicPlayerController sharedInstance] stop];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
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



- (void)setAudioSessionWithDucking:(BOOL)isDucking
{
    AudioSessionSetActive(NO);
    
    UInt32 overrideCategoryDefaultToSpeaker = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (overrideCategoryDefaultToSpeaker), &overrideCategoryDefaultToSpeaker);
    
    UInt32 overrideCategoryMixWithOthers = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (overrideCategoryMixWithOthers), &overrideCategoryMixWithOthers);
    
    UInt32 value = isDucking;
    AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(value), &value);
    
    AudioSessionSetActive(YES);
}


- (void)updateLabels
{
    
    
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    NSLog(@"TIME IS: %@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]);
    
    //NSLog(@"DISTANCE/SECONDS: %@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]);
    NSLog(@"SECONDS: %d", self.seconds);
    
    if(self.distance/self.seconds > 0){
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemin == 'no'"]];
        
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        self.objects = results;
        
        if (!results || !results.count){ //begin if no results
            
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
        
        if(self.seconds < 3600){
            
            
        if([timeTrunc3 isEqualToString:@"05"]){
            NSString *fiveMinuteTime = @"5";
            NSString * newText = [[NSString alloc] initWithFormat:@"Time %@ minutes %@ seconds, distance %@, speed %@ minutes %@ seconds per mile.", fiveMinuteTime, timeTrunc3begin,[MathController stringifyDistance:self.distance],speedTrunc3, speedTrunc3begin];
            
            NSLog(@"YOU HAVE BEEN RUNNING FOR %@ MINUTES %@ SECONDS! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@", fiveMinuteTime, timeTrunc3begin,[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
            
            [[GVMusicPlayerController sharedInstance] pause];
            //[self setAudioSessionWithDucking:YES];
            [NSTimer scheduledTimerWithTimeInterval:12.0
                                             target:self
                                           selector:@selector(playAfterPause)
                                           userInfo:nil
                                            repeats:NO];
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance
                                            speechUtteranceWithString:newText];
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            
            utterance.rate = 0.45;
            utterance.pitchMultiplier = 0.95;
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
            utterance.volume = 1.0;
            
            
            
            [synth speakUtterance:utterance];
            
            
            
        }else{
            
            
            
        NSLog(@"YOU HAVE BEEN RUNNING FOR %@ MINUTES %@ SECONDS! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@", timeTrunc3, timeTrunc3begin,[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
        
        NSString * newText = [[NSString alloc] initWithFormat:@"Time %@ minutes %@ seconds, distance %@, speed %@ minutes %@ seconds per mile.", timeTrunc3, timeTrunc3begin,[MathController stringifyDistance:self.distance],speedTrunc3, speedTrunc3begin];
        
            [[GVMusicPlayerController sharedInstance] pause];
            //[self setAudioSessionWithDucking:YES];
            [NSTimer scheduledTimerWithTimeInterval:12.0
                                             target:self
                                           selector:@selector(playAfterPause)
                                           userInfo:nil
                                            repeats:NO];
            
            
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:newText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
        utterance.volume = 1.0;
        
        
            
        [synth speakUtterance:utterance];
            
            //[self setAudioSessionWithDucking:NO];
            //[[GVMusicPlayerController sharedInstance] play];
      
            }
    }
        else if (self.seconds >= 3600){
            
            NSString *myTime = [[NSString alloc]initWithFormat:@"%@",[MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
            NSString *timeTruncHour = [myTime substringToIndex:[myTime length]-6];
            NSString *timeTruncHourMin = [myTime substringToIndex:[myTime length]-3];
            NSString *timeTruncMin = [timeTruncHourMin substringFromIndex:3];
            NSString *timeTruncSec = [myTime substringFromIndex:6];
            
            NSLog(@"YOU HAVE BEEN RUNNING FOR %@ HOURS %@ MINUTES %@ SECONDS! AND YOUR DISTANCE COVERED IS %@, AND YOUR SPEED IS %@", timeTruncHour, timeTruncMin, timeTruncSec,[MathController stringifyDistance:self.distance], [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds] );
            
            NSString * newTextHour = [[NSString alloc] initWithFormat:@"Time %@ hours %@ minutes %@ seconds, distance %@, speed %@ minutes %@ seconds per mile.", timeTruncHour, timeTruncMin, timeTruncSec,[MathController stringifyDistance:self.distance],speedTrunc3, speedTrunc3begin];
            
            [[GVMusicPlayerController sharedInstance] pause];
            //[self setAudioSessionWithDucking:YES];
            [NSTimer scheduledTimerWithTimeInterval:12.0
                                             target:self
                                           selector:@selector(playAfterPause)
                                           userInfo:nil
                                            repeats:NO];
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance
                                            speechUtteranceWithString:newTextHour];
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            utterance.rate = 0.45;
            utterance.pitchMultiplier = 0.95;
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
            utterance.volume = 1.0;
            
            [synth speakUtterance:utterance];
            
        }
    }
                }//End if no results
        else{
            NSLog(@"VOICEMIN SET TO NO");
            
        }
        
    }
    
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Speed: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    self.nextBadgeLabel.text = [NSString stringWithFormat:@"%@ until %@!", [MathController stringifyDistance:(self.upcomingBadge.distance - self.distance)], self.upcomingBadge.name];
    
    //NSLog(@"NEXT BADGE TEXT IS: %@",self.nextBadgeLabel.text);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemile == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
        if (!results || !results.count){ //begin if no results
    
    if([[MathController stringifyDistance:self.distance] isEqualToString:@"1.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"2.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"3.00 mi"]|| [[MathController stringifyDistance:self.distance] isEqualToString:@"4.00 mi"]){
        
        NSString *mileText = [[NSString alloc]initWithFormat:@"You have reached %@ and are at badge level white. Get to 5 miles to reach badge level bronze.", [MathController stringifyDistance:self.distance]];
        
        [[GVMusicPlayerController sharedInstance] pause];
        //[self setAudioSessionWithDucking:YES];
        [NSTimer scheduledTimerWithTimeInterval:12.0
                                         target:self
                                       selector:@selector(playAfterPause)
                                       userInfo:nil
                                        repeats:NO];
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:mileText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
    }
    else if([[MathController stringifyDistance:self.distance] isEqualToString:@"5.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"6.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"7.00 mi"]|| [[MathController stringifyDistance:self.distance] isEqualToString:@"8.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"9.00 mi"]){
        
        NSString *mileText = [[NSString alloc]initWithFormat:@"You have reached %@ and are at badge level bronze. Get to 10 miles to reach badge level silver.", [MathController stringifyDistance:self.distance]];
        
        
        [[GVMusicPlayerController sharedInstance] pause];
        //[self setAudioSessionWithDucking:YES];
        [NSTimer scheduledTimerWithTimeInterval:12.0
                                         target:self
                                       selector:@selector(playAfterPause)
                                       userInfo:nil
                                        repeats:NO];
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:mileText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
    }
    else if([[MathController stringifyDistance:self.distance] isEqualToString:@"10.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"11.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"12.00 mi"]|| [[MathController stringifyDistance:self.distance] isEqualToString:@"13.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"14.00 mi"]){
        
        NSString *mileText = [[NSString alloc]initWithFormat:@"You have reached %@ and are at badge level silver. Get to 15 miles to reach badge level gold.", [MathController stringifyDistance:self.distance]];
        
        
        [[GVMusicPlayerController sharedInstance] pause];
        //[self setAudioSessionWithDucking:YES];
        [NSTimer scheduledTimerWithTimeInterval:12.0
                                         target:self
                                       selector:@selector(playAfterPause)
                                       userInfo:nil
                                        repeats:NO];
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:mileText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
    }
    else if([[MathController stringifyDistance:self.distance] isEqualToString:@"15.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"16.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"17.00 mi"]|| [[MathController stringifyDistance:self.distance] isEqualToString:@"18.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"19.00 mi"]){
        
        NSString *mileText = [[NSString alloc]initWithFormat:@"You have reached %@ and are at badge level gold. Get to 20 miles to reach badge level royal purple.", [MathController stringifyDistance:self.distance]];
        
        
        [[GVMusicPlayerController sharedInstance] pause];
        //[self setAudioSessionWithDucking:YES];
        [NSTimer scheduledTimerWithTimeInterval:12.0
                                         target:self
                                       selector:@selector(playAfterPause)
                                       userInfo:nil
                                        repeats:NO];
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:mileText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
    }
    else if([[MathController stringifyDistance:self.distance] isEqualToString:@"20.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"21.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"22.00 mi"]|| [[MathController stringifyDistance:self.distance] isEqualToString:@"23.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"24.00 mi"] || [[MathController stringifyDistance:self.distance] isEqualToString:@"25.00 mi"]){
        
        NSString *mileText = [[NSString alloc]initWithFormat:@"You have reached %@ and are at badge level royal purple. You have reached the highest badge level.", [MathController stringifyDistance:self.distance]];
        
        
        [[GVMusicPlayerController sharedInstance] pause];
        //[self setAudioSessionWithDucking:YES];
        [NSTimer scheduledTimerWithTimeInterval:12.0
                                         target:self
                                       selector:@selector(playAfterPause)
                                       userInfo:nil
                                        repeats:NO];
        
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance
                                        speechUtteranceWithString:mileText];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        
        utterance.rate = 0.45;
        utterance.pitchMultiplier = 0.95;
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.volume = 1.0;
        
        [synth speakUtterance:utterance];
        
    }
    }//end if no results
else{
    NSLog(@"VOICEMILE SET TO NO");
    
        }
    
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
            [[GVMusicPlayerController sharedInstance] stop];
        }
    }
    else{
    
    // save
    if (buttonIndex == 0) {
        [[GVMusicPlayerController sharedInstance] stop];
        [self saveRun];
        //[self performSegueWithIdentifier:detailSegueName sender:nil];
        
    // discard
    } else if (buttonIndex == 1) {
        [[GVMusicPlayerController sharedInstance] stop];
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
