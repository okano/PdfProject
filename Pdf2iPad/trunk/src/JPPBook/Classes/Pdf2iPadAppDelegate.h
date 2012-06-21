//
//  Pdf2iPadAppDelegate.h
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseDefine.h"
#import "PaymentConductor.h"
#import "ContentListDS.h"
#import "ServerContentListDS.h"
#import "PaymentHistoryDS.h"
#import "FileUtility.h"
#import "ContentFileUtility.h"
#import "ConfigViewController.h"
#import "InAppPurchaseUtility.h"

@class Pdf2iPadViewController;
@class ContentPlayerViewController;

@interface Pdf2iPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    Pdf2iPadViewController *viewController;
	
	// TOC infomation.
	NSMutableArray* tocDefine;
	// Bookmark infomation.
	NSMutableArray* bookmarkDefine;
	
	// InAppPurchase Payment Conductor.
	PaymentConductor* paymentConductor;
	// InAppPurchase data.
	ContentListDS* contentListDS;
	ServerContentListDS* serverContentListDS;
	PaymentHistoryDS* paymentHistoryDS;
	
	// ProductIdList
	InAppPurchaseUtility* productIdList;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Pdf2iPadViewController *viewController;
//for get value in TocViewController.
@property (nonatomic, retain) NSMutableArray* tocDefine;
//
@property (nonatomic, retain) NSMutableArray* bookmarkDefine;
// InAppPurchase Payment Conductor.
@property (nonatomic, retain) PaymentConductor* paymentConductor;
// InAppPurchase data.
@property (nonatomic, retain) ContentListDS* contentListDS;
@property (nonatomic, retain) ServerContentListDS* serverContentListDS;
@property (nonatomic, retain) PaymentHistoryDS* paymentHistoryDS;
// ProductIdList
@property (nonatomic, retain) InAppPurchaseUtility* productIdList;

//Copy KUMIKOMI contents to local directory.
- (BOOL)isFirstLaunchUp;
- (void)copyPdfFromResourceToFile;
- (void)copyOtherfileFromResourceToFile;
- (void)setDefaultUsernameAndPassword;

//ContentId for download.
//- (ContentId)nextContentId;
//- (void)stepupContentIdToUserDefault:(ContentId)lastAssignedContentId;

//
- (NSString*)getThumbnailFilenameFull:(int)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid;
//
- (void)switchToPage:(int)newPageNum;
//
- (void)showMenuBar;
- (void)hideMenuBar;
//- (void)showTocView;
- (void)hideTocView;
- (bool)isShownTocView;
- (void)setIsShownTocView:(bool)status;
- (void)saveBookmark;
- (void)showBookmarkView;
- (void)hideBookmarkView;
- (void)showBookmarkModifyView;
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName;
- (void)showThumbnailScrollView;
- (void)hideThumbnailScrollView;
- (bool)iShownImageTocView;
- (NSMutableArray*)getTocDefine;
- (void)showInfoView;
- (void)gotoTopPage;
- (void)gotoCoverPage;
- (void)showHelpView;
- (void)enterMarkerMode;
@end

@interface Pdf2iPadAppDelegate (InAppPurchase)
- (void)showContentListView;
- (void)hideContentListView;
- (void)showContentPlayerView:(ContentId)cid;
- (void)hideContentPlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end

@interface Pdf2iPadAppDelegate (ServerContent)
- (void)showServerContentListView;
- (void)hideServerContentListView;
- (void)showServerContentDetailView:(NSString*)uuid;
- (void)hideServerContentDetailView;
- (void)showDownloadView:(NSString*)productId;
@end
