//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Utility.h"
#import "FileUtility.h"
#import "Define.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "PopoverScrollImageViewController.h"
#import "InfomationViewController.h"
#import "TocViewController.h"
//#import "BookmarkViewController.h"
//#import "BookmarkModifyViewController.h"
//#import "ThumbnailViewController.h"
@class TiledPDFView;
//#import "PDFScrollView.h"
//
#import "MyPdfScrollView.h"

#import "ImageGenerator.h"

@interface SakuttoBookViewController : UIViewController <UIActionSheetDelegate> {
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
	//NSMutableArray* inPageScrollViewDefine;
	//NSMutableArray* tocDefine;
	NSMutableArray* popoverScrollImageDefine;

	
	// Menu
	MenuViewController* menuViewController;
	// WebView
	WebViewController* webViewController;
	NSMutableString* urlForWeb;
	// TocView, ThumbnailView.
	TocViewController* tocViewController;
	//ThumbnailViewController* thumbnailViewController;
	// BookmarkView
	//BookmarkViewController* bookmarkViewController;
	bool isShownMenuBar;
	bool isShownTocView;
	//bool isShownThumbnailView;
	//bool isShownBookmarkView;
	//bool isTocWithBookmarkMode;
}
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView1;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView2;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView3;
//
@property (nonatomic, retain) NSURL* pdfURL;

//@property (nonatomic, retain) UIImageView* imageView1;
//@property (nonatomic, retain) UIImageView* imageView2;
//@property (nonatomic, retain) UIImageView* imageView3;
//@property (nonatomic, retain) UIImage* image1;
//@property (nonatomic, retain) UIImage* image2;
//@property (nonatomic, retain) UIImage* image3;
@property (nonatomic, retain) MenuViewController* menuViewController;
@property (nonatomic, retain) WebViewController* webViewController;
@property (nonatomic, retain) TocViewController* tocViewController;
//@property (nonatomic, retain) ThumbnailViewController* thumbnailViewController;
//@property (nonatomic, retain) BookmarkViewController* bookmarkViewController;
//
@property (nonatomic) bool isShownMenuBar;
@property (nonatomic) bool isShownTocView;
//@property (nonatomic) bool isShownThumbnailView;
//@property (nonatomic) bool isShownBookmarkView;
//@property (nonatomic) bool isTocWithBookmarkMode;

//for get value in TocViewController.
////@property (nonatomic, retain) UIImageView* currentImageView;

/**
 *Functions.
 */
// Treat PDF.
- (BOOL)setupPdfBasicInfo;
// Handle PDF infomation.
- (BOOL)isVerticalWriting;
- (BOOL)isMultiContents;
//- (void)getPdfDictionaryWithPageNum:(NSUInteger)pageNum;

// Draw PDF.
- (NSString*)getPageFilenameFull:(int)pageNum;
//- (NSString*)getThumbnailFilenameFull:(int)pageNum;
//
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
//- (void)generateThumbnailImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum;
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
//- (void) renderPageLinkAtIndex:(NSUInteger)index;

// Treat Movie.
//- (BOOL)parseMovieDefine;	// Parse Movie define in CSV.
//- (void)renderMovieLinkAtIndex:(NSUInteger)index;
//- (void)showMoviePlayer:(NSString*)filename;
// Treat InPage ScrollView.
//- (BOOL)parseInPageScrollViewDefine;	// Parse define in CSV.
//- (void)renderInPageScrollViewAtIndex:(NSUInteger)index;
// Treat Popover Scroll Image.
//- (BOOL)parsePopoverScrollImageDefine;	// Parse define in CSV.
//- (void)renderPopoverScrollImageLinkAtIndex:(NSUInteger)index;
//- (void)showPopoverScrollImagePlayer:(NSString*)filename;
// Treat TOC.
- (BOOL)parseTocDefine;			// Parse Table Of Contents define in CSV.
//- (BOOL)parseBookmarkDefine;	// get Bookmark infomation from UserDefault.
- (void)showTocView;
- (void)hideTocView;
//- (void)showThumbnailView;
//- (void)hideThumbnailView;
//- (void)showBookmarkView;
//- (void)hideBookmarkView;
//- (void)showBookmarkModifyView;
//- (void)addBookmarkWithCurrentPageWithName:(NSString*)bookmarkName;

// Menu.
- (void)toggleMenuBar;
- (void)showMenuBar;
- (void)hideMenuBar;
// Show other view.
- (IBAction)showInfoView;
- (void)showWebView:(NSString*)urlString;

// Utility for Handle Rotate.
- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation;

// Latest Read Page.
- (void)setLatestReadPage:(int)pageNum;
- (int)getLatestReadPage;

@end

