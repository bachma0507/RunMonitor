//
//  RunCell.h
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *badgeImageView;

@end
