//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentPlayerViewController.h"
#import "InAppPurchaseDefine.h"
#import "ContentListViewController.h"
#import "ContentListImageViewController.h"
#import "ContentDetailViewController.h"
#import "ServerContentListTableVC.h"
#import "ServerContentListImageVC.h"
#import "ServerContentDetailVC.h"

@interface SakuttoBookViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	ContentListViewController* contentListVC;
	ContentListImageViewController* contentListIVC;
	ContentDetailViewController* contentDetailVC;
	//Server Content.
	ServerContentListTableVC* serverContentListVC;
	ServerContentListImageVC* serverContentListIVC;
	ServerContentDetailVC* serverContentDetailVC;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;
@property (nonatomic, retain) ContentListViewController* contentListVC;
@property (nonatomic, retain) ContentListImageViewController* contentListIVC;
@property (nonatomic, retain) ContentDetailViewController* contentDetailVC;
@property (nonatomic, retain) ServerContentListTableVC* serverContentListVC;
@property (nonatomic, retain) ServerContentListImageVC* serverContentListIVC;
@property (nonatomic, retain) ServerContentDetailVC* serverContentDetailVC;

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
