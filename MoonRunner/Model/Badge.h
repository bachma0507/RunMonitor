//
//  Badge.h
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Badge : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *information;
@property float distance;

@end
