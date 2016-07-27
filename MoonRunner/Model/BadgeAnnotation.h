//
//  BadgeAnnotation.h
//  MoonRunner
//
//  Created by Barry Julien on 6/11/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BadgeAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSString *imageName;

@end
