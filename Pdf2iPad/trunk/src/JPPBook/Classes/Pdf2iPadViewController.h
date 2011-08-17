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
#import "ServerContentListVC.h"
//#import "ServerContentDetailVC.h"

@interface Pdf2iPadViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	ContentListViewController* contentListVC;
	ContentDetailViewController* contentDetailVC;
	//Server Content.
	ServerContentListVC* serverContentListVC;
	//ServerContentDetailViewController* serverContentDetailVC;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;
@property (nonatomic, retain) ContentListViewController* contentListVC;
@property (nonatomic, retain) ContentDetailViewController* contentDetailVC;
@property (nonatomic, retain) ServerContentListVC* serverContentListVC;
//@property (nonatomic, retain) ServerContentDetailVC* serverContentDetailVC;

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

@interface Pdf2iPadViewController (ServerContent)
- (void)showServerContentListView;
- (void)hideServerContentListView;
- (void)showServerContentDetailView:(ContentId)cid;
- (void)hideServerContentDetailView;
- (void)showDownloadView:(NSString*)productId;
@end
