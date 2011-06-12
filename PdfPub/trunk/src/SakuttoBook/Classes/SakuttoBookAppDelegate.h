//
//  SakuttoBookAppDelegate.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "License.h"
#import "InAppPurchaseDefine.h"
#import "PaymentConductor.h"
#import "ContentListDS.h"
#import "PaymentHistoryDS.h"

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
	PaymentHistoryDS* paymentHistoryDS;
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
@property (nonatomic, retain) PaymentHistoryDS* paymentHistoryDS;


/**
 * Functions in SakuttoBookViewController.
 */
//
- (NSString*)getThumbnailFilenameFull:(int)pageNum;
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
- (void)showBookmarkView;
- (void)hideBookmarkView;
- (void)showBookmarkModifyView;
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName;
- (void)showThumbnailView;
- (void)hideThumbnailView;
- (bool)isShownThumbnailView;
- (NSMutableArray*)getTocDefine;
- (void)showWebView:(NSString*)urlString;
- (void)showInfoView;
//
- (ContentId)getCurrentContentIdInContentPlayer;
@end

@interface SakuttoBookAppDelegate (InAppPurchase)
- (void)showContentListView;
- (void)hideContentListView;
- (void)showContentPlayerView:(ContentId)cid;
- (void)hideContentPlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end
