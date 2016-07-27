//
//  BadgeCell.m
//  RunMonitor
//
//  Created by Barry Julien on 5/21/16.
//  Copyright (c) 2016 Barry Julien. All rights reserved.
//

#import "BadgeCell.h"

@implementation BadgeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
