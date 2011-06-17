//
//  ContentPlayerView.h
//  SakuttoBook
//
//  Created by okano on 11/05/31.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SKBE_MainVC.h"
#import "Utility.h"
#import "FileUtility.h"
#import "Define.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "PopoverScrollImageViewController.h"
#import "InfomationViewController.h"
#import "TocViewController.h"
#import "BookmarkViewController.h"
#import "BookmarkModifyViewController.h"
#import "ThumbnailViewController.h"
@class TiledPDFView;
//#import "PDFScrollView.h"
//
#import "MyPdfScrollView.h"

#import "ImageGenerator.h"

@interface ContentPlayerViewController : SKBE_MainVC <UIActionSheetDelegate> {
	// Views.
	IBOutlet MyPdfScrollView* pdfScrollView1;
	IBOutlet MyPdfScrollView* pdfScrollView2;
	IBOutlet MyPdfScrollView* pdfScrollView3;
	
	//IBOutlet UIImageView* imageView1;
	//IBOutlet UIImageView* imageView2;
	//IBOutlet UIImageView* imageView3;
	//UIImage* image1;
	//UIImage* image2;
	//UIImage* image3;
	// Pointer for view.
	MyPdfScrollView* prevPdfScrollView;
	MyPdfScrollView* currentPdfScrollView;
	MyPdfScrollView* nextPdfScrollView;
	//UIImageView* prevImageView;
	//UIImageView* currentImageView;
	//UIImageView* nextImageView;
	
	// PDF structure.
	//CGPDFDocumentRef pdf;
	//CGPDFPageRef page;
	//CGRect originalPageRect;
	//CGRect pageRect;
	CGFloat pdfScale;
	
	//for pdf handle.
	NSURL* pdfURL;
	
	//
	ContentId currentContentId;
	//
	int currentPageNum;
	int maxPageNum;
	
	// Gesture Recognizer for imageView, imageScrollView.
	UITapGestureRecognizer* tapRecognizer1;
	UITapGestureRecognizer* tapRecognizer2;
	UITapGestureRecognizer* tapRecognizer3;
	UISwipeGestureRecognizer* swipeRecognizer1right;
	UISwipeGestureRecognizer* swipeRecognizer2right;
	UISwipeGestureRecognizer* swipeRecognizer3right;
	UISwipeGestureRecognizer* swipeRecognizer1left;
	UISwipeGestureRecognizer* swipeRecognizer2left;
	UISwipeGestureRecognizer* swipeRecognizer3left;
	//
	UIPanGestureRecognizer* panRecognizer1;
	UIPanGestureRecognizer* panRecognizer2;
	UIPanGestureRecognizer* panRecognizer3;
	CGPoint panStartPoint;
	CGPoint panEndPoint;
	id panTargetView;
	
	//
	NSMutableArray* linksInCurrentPage;
	NSMutableArray* movieDefine;
	NSMutableArray* pageJumpLinkDefine;
	NSMutableArray* inPageScrollViewDefine;
	//NSMutableArray* tocDefine;
	NSMutableArray* popoverScrollImageDefine;
	
	
	// Menu
	MenuViewController* menuViewController;
	// WebView
	WebViewController* webViewController;
	NSMutableString* urlForWeb;
	// TocView, ThumbnailView.
	TocViewController* tocViewController;
	ThumbnailViewController* thumbnailViewController;
	// BookmarkView
	BookmarkViewController* bookmarkViewController;
	bool isShownMenuBar;
	bool isShownTocView;
	bool isShownThumbnailView;
	bool isShownBookmarkView;
	//bool isTocWithBookmarkMode;
}
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView1;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView2;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView3;
//
@property (nonatomic, retain) NSURL* pdfURL;

@property (nonatomic) ContentId currentContentId;

//@property (nonatomic, retain) UIImageView* imageView1;
//@property (nonatomic, retain) UIImageView* imageView2;
//@property (nonatomic, retain) UIImageView* imageView3;
//@property (nonatomic, retain) UIImage* image1;
//@property (nonatomic, retain) UIImage* image2;
//@property (nonatomic, retain) UIImage* image3;
@property (nonatomic, retain) MenuViewController* menuViewController;
@property (nonatomic, retain) WebViewController* webViewController;
@property (nonatomic, retain) TocViewController* tocViewController;
@property (nonatomic, retain) ThumbnailViewController* thumbnailViewController;
@property (nonatomic, retain) BookmarkViewController* bookmarkViewController;
//
@property (nonatomic) bool isShownMenuBar;
@property (nonatomic) bool isShownTocView;
@property (nonatomic) bool isShownThumbnailView;
@property (nonatomic) bool isShownBookmarkView;
//@property (nonatomic) bool isTocWithBookmarkMode;

//for get value in TocViewController.
////@property (nonatomic, retain) UIImageView* currentImageView;

/**
 *Functions.
 */
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle contentId:(ContentId)cid;
// Treat PDF.
- (ContentId)getCurrentContentIdFromUserDefault;
- (BOOL)setupPdfBasicInfo:(ContentId)cid;
// Handle PDF infomation.
- (BOOL)isVerticalWriting;
- (BOOL)isTransitionWithCurl;
- (BOOL)isMultiContents;
//- (void)getPdfDictionaryWithPageNum:(NSUInteger)pageNum;

// Draw PDF.
- (NSString*)getPageFilenameFull:(int)pageNum;
- (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
- (NSString*)getThumbnailFilenameFull:(int)pageNum;
- (NSString*)getThumbnailFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
//
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithTargetFilenameFull:(NSString*)filename;
- (void)generateThumbnailImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum;
- (void)removeAllImageCache;
//
- (void)drawPageWithNumber:(int)newPagenum;



// Move Page.
- (void)gotoNextPage;
- (void)gotoPrevPage;
- (void)switchToPage:(int)newPageNum;
- (void)switchNextImageWithAnimationType:(NSString*)animationType;
////- (void)resetView;

// Handle Tap.
- (void)handleTapInLeftArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInRightArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInTopArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInBottomArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;
- (void)enableAllPanGesture;
- (void)disableAllPanGesture;

// Treat URL link.
- (void) renderPageLinkAtIndex:(NSUInteger)index;

// Treat Movie.
- (void)parseMovieDefine;	// Parse Movie define in CSV.
- (void)renderMovieLinkAtIndex:(NSUInteger)index;
- (void)showMoviePlayer:(NSString*)filename;
// Treat PageJumpLink.
- (void)parsePageJumpLinkDefine;	// Parse PageJumpLink define in CSV.
- (void)renderPageJumpLinkAtIndex:(NSUInteger)index;
// Treat InPage ScrollView.
- (void)parseInPageScrollViewDefine;	// Parse define in CSV.
- (void)renderInPageScrollViewAtIndex:(NSUInteger)index;
// Treat Popover Scroll Image.
- (void)parsePopoverScrollImageDefine;	// Parse define in CSV.
- (void)renderPopoverScrollImageLinkAtIndex:(NSUInteger)index;
- (void)showPopoverScrollImagePlayer:(NSString*)filename;
// Treat TOC.
- (void)parseTocDefine;			// Parse Table Of Contents define in CSV.
- (void)showTocView;
- (void)hideTocView;
- (void)showThumbnailView;
- (void)hideThumbnailView;
// Treat Bookmark.
- (BOOL)loadBookmark;	// get Bookmark infomation from UserDefault.
- (void)saveBookmark;
- (void)showBookmarkView;
- (void)hideBookmarkView;
- (void)showBookmarkModifyView;
- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName;

// Menu.
- (void)toggleMenuBar;
- (void)showMenuBar;
- (void)hideMenuBar;
// Show other view.
- (IBAction)showInfoView;
- (void)showWebViewSelector:(NSString*)urlString;
- (void)showWebView:(NSString*)urlString;
- (void)showWebWithSafari:(NSString*)urlString;

// Utility for Handle Rotate.
- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation;

// Utility for filename.
- (NSString*)formatStringWithAlphaNumeric:(NSString*)originalStr;

// Latest Read Page.
- (void)setLatestReadPage:(int)pageNum;
- (int)getLatestReadPage;

@end

