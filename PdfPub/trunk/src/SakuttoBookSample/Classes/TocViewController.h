//
//  TocView2.h
//  SakuttoBook
//
//  Created by okano on 10/12/14.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "Utility.h"
#import "Define.h"

@interface TocViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView* myTableView;
	IBOutlet UIToolbar* topToolBar;
}
@property (nonatomic, retain) UIToolbar* topToolBar;
- (IBAction)closeThisView:(id)sender;
- (void)reloadDataForce;
- (void)arrangeTopToolBar;
- (void)setToolbarForToc;

@end
