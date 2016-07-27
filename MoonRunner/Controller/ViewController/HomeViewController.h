//
//  HomeViewController.h
//  RunMonitor
//
//  Created by Barry Julien on 5/19/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *badgesButton;

@end
