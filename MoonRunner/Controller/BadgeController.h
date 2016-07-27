//
//  BadgeController.h
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Badge;
@class Run;

extern float const silverMultiplier;
extern float const goldMultiplier;

@interface BadgeController : NSObject

+ (BadgeController *)defaultController;

- (NSArray *)earnStatusesForRuns:(NSArray *)runArray;

- (Badge *)bestBadgeForDistance:(float)distance;

- (Badge *)nextBadgeForDistance:(float)distance;

- (NSArray *)annotationsForRun:(Run *)run;

@end
