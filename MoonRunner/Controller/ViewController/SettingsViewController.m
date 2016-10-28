//
//  SettingsViewController.m
//  RunMonitor
//
//  Created by Barry on 7/28/16.
//  Copyright © 2016 Matt Luedke. All rights reserved.
//

#import "SettingsViewController.h"
#import "GVMusicPlayerController.h"
#import "NSString+TimeToString.h"



@interface SettingsViewController () <GVMusicPlayerControllerDelegate, MPMediaPickerControllerDelegate>
{
    MPMusicPlayerController* myPlayer;
}


@property (weak, nonatomic) NSString * voiceMileStr;

@property (strong, nonatomic) NSArray *objects;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    
    [self fetchVoiceMile];
    [self fetchVoiceMin];
    [self fetchVoiceStart];
    [self fetchVoicestop];
    
   
    
}

- (void)fetchVoiceMile{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemile == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [self.mileMarkerButton setTitle:@"Mile Marker Voice On" forState:normal];
        [self.mileMarkerButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    else{
        [self.mileMarkerButton setTitle:@"Mile Marker Voice Off" forState:normal];
        [self.mileMarkerButton setTitleColor:[UIColor redColor] forState:normal];
    }
    

    
}

- (void)fetchVoiceMin{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemin == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [self.minuteMarkerButton setTitle:@"5 Minute Marker Voice On" forState:normal];
        [self.minuteMarkerButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    else{
        [self.minuteMarkerButton setTitle:@"5 Minute Marker Voice Off" forState:normal];
        [self.minuteMarkerButton setTitleColor:[UIColor redColor] forState:normal];
    }
    
    
    
}

- (void)fetchVoiceStart{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestart == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [self.startRunButton setTitle:@"Start Run Voice On" forState:normal];
        [self.startRunButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    else{
        [self.startRunButton setTitle:@"Start Run Voice Off" forState:normal];
        [self.startRunButton setTitleColor:[UIColor redColor] forState:normal];
    }
    
    
    
}

- (void)fetchVoicestop{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestop == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [self.stopRunButton setTitle:@"Stop Run Voice On" forState:normal];
        [self.stopRunButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    else{
        [self.stopRunButton setTitle:@"Stop Run Voice Off" forState:normal];
        [self.stopRunButton setTitleColor:[UIColor redColor] forState:normal];
    }
    
    
    
}



- (IBAction)mileMarkerButtonPressed:(id)sender {
    
    
    NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemile == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [newVoice setValue:@"no" forKey:@"voicemile"];
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.mileMarkerButton setTitle:@"Mile Marker Voice Off" forState:normal];
        [self.mileMarkerButton setTitleColor:[UIColor redColor] forState:normal];
    }
    else{
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:@"yes" forKey:@"voicemile"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.mileMarkerButton setTitle:@"Mile Marker Voice On" forState:normal];
        [self.mileMarkerButton setTitleColor:[UIColor greenColor] forState:normal];
    }

}

- (IBAction)minuteMarkerButtonPressed:(id)sender {
    
    NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicemin == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [newVoice setValue:@"no" forKey:@"voicemin"];
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.minuteMarkerButton setTitle:@"5 Minute Marker Voice Off" forState:normal];
        [self.minuteMarkerButton setTitleColor:[UIColor redColor] forState:normal];
    }
    else{
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:@"yes" forKey:@"voicemin"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.minuteMarkerButton setTitle:@"5 Minute Marker Voice On" forState:normal];
        [self.minuteMarkerButton setTitleColor:[UIColor greenColor] forState:normal];
    }

}

- (IBAction)startRunButtonPressed:(id)sender {
    
    
    NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestart == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [newVoice setValue:@"no" forKey:@"voicestart"];
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.startRunButton setTitle:@"Start Run Voice Off" forState:normal];
        [self.startRunButton setTitleColor:[UIColor redColor] forState:normal];
    }
    else{
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:@"yes" forKey:@"voicestart"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.startRunButton setTitle:@"Start Run Voice On" forState:normal];
        [self.startRunButton setTitleColor:[UIColor greenColor] forState:normal];
    }

}

- (IBAction)stopRunButtonPressed:(id)sender {
    
    NSManagedObject *newVoice = [NSEntityDescription insertNewObjectForEntityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"voicestop == 'no'"]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.objects = results;
    
    if (!results || !results.count){
        [newVoice setValue:@"no" forKey:@"voicestop"];
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.stopRunButton setTitle:@"Stop Run Voice Off" forState:normal];
        [self.stopRunButton setTitleColor:[UIColor redColor] forState:normal];
    }
    else{
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:@"yes" forKey:@"voicestop"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.stopRunButton setTitle:@"Stop Run Voice On" forState:normal];
        [self.stopRunButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    
    
}

#pragma music settings

- (void)viewWillAppear:(BOOL)animated {
    // NOTE: add and remove the GVMusicPlayerController delegate in
    // the viewWillAppear / viewDidDisappear methods, not in the
    // viewDidLoad / viewDidUnload methods - it will result in dangling
    // objects in memory.
    [super viewWillAppear:animated];
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[GVMusicPlayerController sharedInstance] removeDelegate:self];
    [super viewDidDisappear:animated];
}

- (IBAction)chooseButtonPressed {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [myPlayer setQueueWithItemCollection:mediaItemCollection];
    //[[GVMusicPlayerController sharedInstance] play];
    [self savePlaylist:mediaItemCollection];
    [myPlayer pause];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
    
//    [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:mediaItemCollection];
//    //[[GVMusicPlayerController sharedInstance] play];
//    [self savePlaylist:mediaItemCollection];
//    [[GVMusicPlayerController sharedInstance] pause];
//    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePlaylist:(MPMediaItemCollection *) mediaItemCollection {
    
    NSArray* items = [mediaItemCollection items];
    
    NSMutableArray* listToSave = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (MPMediaItem *song in items) {
        
        NSNumber *persistentId = [song valueForProperty:MPMediaItemPropertyPersistentID];
        
        [listToSave addObject:persistentId];
        
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: listToSave];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"songsList"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}




@end
