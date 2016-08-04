//
//  HomeViewController.m
//  RunMonitor
//
//  Created by Barry Julien on 5/19/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import "HomeViewController.h"
#import "NewRunViewController.h"
#import "PastRunsViewController.h"
#import "BadgesTableViewController.h"
#import "BadgeController.h"
#import <MapKit/MapKit.h>
#import "GVMusicPlayerController.h"
#import "NSString+TimeToString.h"

@interface HomeViewController () <MKMapViewDelegate, GVMusicPlayerControllerDelegate, MPMediaPickerControllerDelegate>

@property (strong, nonatomic) NSArray *runArray;

@end

@implementation HomeViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GVMusicPlayerController sharedInstance] stop];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    self.runArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.badgesButton.hidden = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *nextController = [segue destinationViewController];
    if ([nextController isKindOfClass:[NewRunViewController class]]) {
        ((NewRunViewController *) nextController).managedObjectContext = self.managedObjectContext;
    } else if ([nextController isKindOfClass:[PastRunsViewController class]]) {
        ((PastRunsViewController *) nextController).runArray = self.runArray;
    } else if ([nextController isKindOfClass:[BadgesTableViewController class]]) {
        ((BadgesTableViewController *) nextController).earnStatusArray = [[BadgeController defaultController] earnStatusesForRuns:self.runArray];
    }
}



@end
