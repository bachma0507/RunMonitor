//
//  SettingsViewController.m
//  RunMonitor
//
//  Created by Barry on 7/28/16.
//  Copyright © 2016 Matt Luedke. All rights reserved.
//

#import "SettingsViewController.h"


@interface SettingsViewController ()


@property (weak, nonatomic) NSString * voiceMileStr;

@property (strong, nonatomic) NSArray *objects;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
        [object setValue:@"yes" forKey:@"voicestart"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.stopRunButton setTitle:@"Stop Run Voice On" forState:normal];
        [self.stopRunButton setTitleColor:[UIColor greenColor] forState:normal];
    }
    
    
}


@end
