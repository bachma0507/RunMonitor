//
//  BadgeDetailsViewController.h
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BadgeEarnStatus;

@interface BadgeDetailsViewController : UIViewController

@property (strong, nonatomic) BadgeEarnStatus *earnStatus;

@end
