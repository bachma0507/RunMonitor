//
//  SettingsViewController.h
//  RunMonitor
//
//  Created by Barry on 7/28/16.
//  Copyright © 2016 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *mileMarkerButton;
@property (weak, nonatomic) IBOutlet UIButton *minuteMarkerButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
- (IBAction)mileMarkerButtonPressed:(id)sender;
- (IBAction)minuteMarkerButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
