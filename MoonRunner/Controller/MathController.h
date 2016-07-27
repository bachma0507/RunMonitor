//
//  MathController.h
//  RunMonitor
//
//  Created by Barry Julien on 5/20/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters;

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;


+ (NSString *)stringifySecondCountDouble:(float)seconds usingLongFormat:(BOOL)longFormat;

@end
