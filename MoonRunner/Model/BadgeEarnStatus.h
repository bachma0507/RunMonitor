//
//  BadgeEarnStatus.h
//  RunMonitor
//
//  Created by Barry Julien on 5/22/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Badge;
@class Run;

@interface BadgeEarnStatus : NSObject

@property (strong, nonatomic) Badge *badge;
@property (strong, nonatomic) Run *earnRun;
@property (strong, nonatomic) Run *silverRun;
@property (strong, nonatomic) Run *goldRun;
@property (strong, nonatomic) Run *bestRun;

@end
