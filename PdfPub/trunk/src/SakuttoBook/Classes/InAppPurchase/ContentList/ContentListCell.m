//
//  ContentListCell.m
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentListCell.h"


@implementation ContentListCell
@synthesize imageView, titleLabel, authorLabel, isDownloadedLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[isDownloadedLabel release];
	[authorLabel release];
	[titleLabel release];
	[imageView release];

    [super dealloc];
}

@end
