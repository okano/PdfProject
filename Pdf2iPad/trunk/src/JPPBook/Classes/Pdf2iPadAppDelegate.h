//
//  Pdf2iPadAppDelegate.h
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentPlayerViewController;

@interface Pdf2iPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ContentPlayerViewController *viewController;
	
	// TOC infomation.
	NSMutableArray* tocDefine;
	// Bookmark infomation.
	NSMutableArray* bookmarkDefine;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContentPlayerViewController *viewController;
//for get value in TocViewController.
@property (nonatomic, retain) NSMutableArray* tocDefine;
//
@property (nonatomic, retain) NSMutableArray* bookmarkDefine;

//
- (NSString*)getThumbnailFilenameFull:(int)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
//
- (void)switchToPage:(int)newPageNum;
//
- (void)showMenuBar;
- (void)hideMenuBar;
//- (void)showTocView;
- (void)hideTocView;
- (bool)isShownTocView;
- (void)setIsShownTocView:(bool)status;
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

