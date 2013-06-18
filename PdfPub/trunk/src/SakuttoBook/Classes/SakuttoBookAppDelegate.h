//
//  SakuttoBookAppDelegate.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "License.h"
#import "ReleaseHash.h"
#import "InAppPurchaseDefine.h"
#import "PaymentConductor.h"
#import "ContentListDS.h"
#import "ServerContentListDS.h"
#import "PaymentHistoryDS.h"
#import "FileUtility.h"
#import "ContentFileUtility.h"
#import "ConfigViewController.h"
#import "ProductIdList.h"

@class SakuttoBookViewController;

@interface SakuttoBookAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SakuttoBookViewController *viewController;
	
	// Application License.
	License* license;
	
	// TOC infomation.
	NSMutableArray* tocDefine;
	NSMutableArray* bookmarkDefine;
	
	// InAppPurchase Payment Conductor.
	PaymentConductor* paymentConductor;
	
	// InAppPurchase data.
	ContentListDS* contentListDS;
	ServerContentListDS* serverContentListDS;
	PaymentHistoryDS* paymentHistoryDS;
	
	// ProductIdList -> use Singleton(sharedManager).
	//ProductIdList* productIdList;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SakuttoBookViewController *viewController;
//Application License.
@property (nonatomic, retain) License* license;
//for get value in TocViewController.
@property (nonatomic, retain) NSMutableArray* tocDefine;
@property (nonatomic, retain) NSMutableArray* bookmarkDefine;
// InAppPurchase Payment Conductor.
@property (nonatomic, retain) PaymentConductor* paymentConductor;
// InAppPurchase data.
@property (nonatomic, retain) ContentListDS* contentListDS;
@property (nonatomic, retain) ServerContentListDS* serverContentListDS;
@property (nonatomic, retain) PaymentHistoryDS* paymentHistoryDS;
// ProductIdList
//@property (nonatomic, retain) ProductIdList* productIdList;


/**
 * Functions in SakuttoBookViewController.
 */
//
//Copy KUMIKOMI contents to local directory.
- (BOOL)isFirstLaunchUp;
- (void)copyPdfFromResourceToFile;
- (void)copyOtherfileFromResourceToFile;
- (void)setDefaultUsernameAndPassword;
//Check/handle with changing device kind on simulator.
- (BOOL)isChangeDeviceOnSimulator;
- (void)setLastLaunchedDeviceOnSimulator;
- (void)alertWithDeviceChangedOnSimulator;
- (void)deleteAllSettings;
//
- (NSString*)getPageSmallFilenameFull:(int)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid;
//
- (void)switchToPage:(int)newPageNum;
//
- (void)showMenuBar;
- (void)hideMenuBar;
- (void)showTocView;
- (void)hideTocView;
- (bool)isShownTocView;
- (void)setIsShownTocView:(bool)status;
- (void)saveBookmark;
- (void)showBookmarkView;
- (void)hideBookmarkView;
- (void)showBookmarkModifyView;
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName;
- (void)showPageSmallView;
- (void)hidePageSmallView;
- (bool)isShownPageSmallView;
- (NSMutableArray*)getTocDefine;
- (void)showWebView:(NSString*)urlString;
- (void)showInfoView;
- (void)enterMarkerMode;
- (void)stopSound;
//
- (ContentId)getCurrentContentIdInContentPlayer;
@end

@interface SakuttoBookAppDelegate (InAppPurchase)
- (void)showContentListView;
- (void)showContentListTableView;
- (void)showContentListImageView;
- (void)hideContentListView;
- (void)showContentPlayerView:(ContentId)cid;
- (void)hideContentPlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end

@interface SakuttoBookAppDelegate (ServerContent)
- (void)showServerContentListView;
- (void)hideServerContentListView;
- (void)showServerContentDetailView:(NSString*)uuid;
- (void)hideServerContentDetailView;
- (void)showDownloadView:(NSString*)productId;
@end
