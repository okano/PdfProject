//
//  ContentListCellController.h
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentListCell.h"

@interface ContentListCellController : UIViewController {
	IBOutlet UITableViewCell* contentListCell;
}
@property (nonatomic, retain) UITableViewCell* contentListCell;

@end
