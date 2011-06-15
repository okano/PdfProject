//
//  ContentListCell.h
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContentListCell : UITableViewCell {
    IBOutlet UIImageView* imageView;
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* authorLabel;
	IBOutlet UILabel* isDownloadedLabel;
}
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* authorLabel;
@property (nonatomic, retain) UILabel* isDownloadedLabel;

@end
