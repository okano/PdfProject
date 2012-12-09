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
#import "ContentListGenreTabController.h"
#import "ContentDetailViewController.h"
#import "ServerContentListVC.h"
#import "ServerContentDetailVC.h"

@interface SakuttoBookViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	ContentListViewController* contentListVC;
	ContentDetailViewController* contentDetailVC;
	//Server Content.
	ServerContentListVC* serverContentListVC;
	ServerContentDetailVC* serverContentDetailVC;
	
	//For multi Genre.
	ContentListGenreTabController* contentListGenreTabController;
	ContentListViewController* bookContentListVC;
	ContentListViewController* videoContentListVC;
	ContentListViewController* audioContentListVC;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;
@property (nonatomic, retain) ContentListViewController* contentListVC;
@property (nonatomic, retain) ContentDetailViewController* contentDetailVC;
@property (nonatomic, retain) ServerContentListVC* serverContentListVC;
@property (nonatomic, retain) ServerContentDetailVC* serverContentDetailVC;
//For multi Genre.
@property (nonatomic, retain) ContentListGenreTabController* contentListGenreTabController;
@property (nonatomic, retain) ContentListViewController* bookContentListVC;
@property (nonatomic, retain) ContentListViewController* videoContentListVC;
@property (nonatomic, retain) ContentListViewController* audioContentListVC;

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
