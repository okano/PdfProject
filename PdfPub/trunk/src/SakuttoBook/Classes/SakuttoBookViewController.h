//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "ContentPlayerViewController.h"
#import "InAppPurchaseDefine.h"
#import "ContentListViewController.h"
#import "ContentListGenreTabController.h"
#import "ContentListImageViewController.h"
#import "ContentDetailViewController.h"
#import "ServerContentListTableVC.h"
#import "ServerContentListImageVC.h"
#import "ServerContentDetailVC.h"

@interface SakuttoBookViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	ContentListTableViewController* contentListVC;
	ContentListImageViewController* contentListIVC;
	ContentDetailViewController* contentDetailVC;
	//Server Content.
	ServerContentListTableVC* serverContentListVC;
	ServerContentListImageVC* serverContentListIVC;
	ServerContentDetailVC* serverContentDetailVC;
	
	//For multi Genre.
	ContentListGenreTabController* contentListGenreTabController;
#if defined(IS_CONTENTLIST_WITH_IMAGE) && IS_CONTENTLIST_WITH_IMAGE != 0
	//content list with image.
	ContentListImageViewController* bookContentListVC;
	ContentListImageViewController* videoContentListVC;
	ContentListImageViewController* audioContentListVC;
#else
	//content list with table.
	ContentListTableViewController* bookContentListVC;
	ContentListTableViewController* videoContentListVC;
	ContentListTableViewController* audioContentListVC;
#endif
	
	SakuttoBookAppDelegate* appDelegate;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;
@property (nonatomic, retain) ContentListTableViewController* contentListVC;
@property (nonatomic, retain) ContentListImageViewController* contentListIVC;
@property (nonatomic, retain) ContentDetailViewController* contentDetailVC;
@property (nonatomic, retain) ServerContentListTableVC* serverContentListVC;
@property (nonatomic, retain) ServerContentListImageVC* serverContentListIVC;
@property (nonatomic, retain) ServerContentDetailVC* serverContentDetailVC;
//For multi Genre.
@property (nonatomic, retain) ContentListGenreTabController* contentListGenreTabController;
#if defined(IS_CONTENTLIST_WITH_IMAGE) && IS_CONTENTLIST_WITH_IMAGE != 0
//content list with image.
@property (nonatomic, retain) ContentListImageViewController* bookContentListVC;
@property (nonatomic, retain) ContentListImageViewController* videoContentListVC;
@property (nonatomic, retain) ContentListImageViewController* audioContentListVC;
#else
//content list with table.
@property (nonatomic, retain) ContentListTableViewController* bookContentListVC;
@property (nonatomic, retain) ContentListTableViewController* videoContentListVC;
@property (nonatomic, retain) ContentListTableViewController* audioContentListVC;
#endif

- (void)showContentPlayerView;

@end

@interface SakuttoBookViewController (InAppPurchase)
- (void)showContentListView;
- (void)hideContentListView;
- (void)showContentPlayerView:(ContentId)cid;
- (void)hideContentPlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end

@interface SakuttoBookViewController (ServerContent)
- (void)showServerContentListView;
- (void)hideServerContentListView;
- (void)showServerContentDetailView:(NSString*)uuid;
- (void)hideServerContentDetailView;
- (void)showDownloadView:(NSString*)productId;
@end
