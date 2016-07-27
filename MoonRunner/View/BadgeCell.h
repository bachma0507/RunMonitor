//
//  BadgeCell.h
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (nonatomic, weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *silverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *goldImageView;

@end
