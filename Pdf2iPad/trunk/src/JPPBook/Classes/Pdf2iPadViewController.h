//
//  Pdf2iPadViewController.h
//  JPPBook
//
//  Created by okano on 11/07/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentPlayerViewController.h"
#import "InAppPurchaseDefine.h"
#import "ContentListViewController.h"
#import "ContentDetailViewController.h"

@interface Pdf2iPadViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	ContentListViewController* contentListVC;
	ContentDetailViewController* contentDetailVC;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;
@property (nonatomic, retain) ContentListViewController* contentListVC;
@property (nonatomic, retain) ContentDetailViewController* contentDetailVC;

- (void)showContentPlayerView;

@end

@interface Pdf2iPadViewController (InAppPurchase)
- (void)showContentListView;
- (void)hideContentListView;
- (void)showContentPlayerView:(ContentId)cid;
- (void)hideContentPlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end
