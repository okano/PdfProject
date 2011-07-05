//
//  BookmarkViewController.h
//  SakuttoBook
//
//  Created by okano on 11/01/06.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "Utility.h"
#import "Define.h"


@interface BookmarkViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView* myTableView;
	IBOutlet UIToolbar* topToolBar;
}
@property (nonatomic, retain) UIToolbar* topToolBar;
- (IBAction)closeThisView:(id)sender;
- (void)reloadDataForce;
- (void)setupViewFrame:(CGRect)frame;
//
- (void)setToolbarForBookmark;
- (void)setToolbarForBookmarkWithEditMode;
//
- (IBAction)switchToEditModeOn:(id)sender;
- (IBAction)switchToEditModeOff:(id)sender;

@end
