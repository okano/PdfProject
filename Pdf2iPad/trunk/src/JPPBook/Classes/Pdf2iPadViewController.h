//
//  Pdf2iPadViewController.h
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Utility.h"
#import "Define.h"
#import "pdfDefine.h"
#import "MarkerPenView.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "PopoverImageViewController.h"
//#import "TocView.h"
#import "ThumbnailScrollViewController.h"
#import "BookmarkViewController.h"
#import "BookmarkModifyViewController.h"
#import "PDFScrollView.h"
#import "MyPdfScrollView.h"
#import "ImageGenerator.h"
@class TiledPDFView;
@class Pdf2iPadAppDelegate;


@interface Pdf2iPadViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate> {
	// Page number at current showing.
    int             currentPageNum;
	int				maxPageNum;

	// Views
	IBOutlet MyPdfScrollView* pdfScrolView1;
	IBOutlet MyPdfScrollView* pdfScrolView2;
	IBOutlet MyPdfScrollView* pdfScrolView3;
	//IBOutlet UIImageView* imageView1;
	//IBOutlet UIImageView* imageView2;
	//IBOutlet UIImageView* imageView3;
    MarkerPenView* markerPenView2;
    
	// Pointer for view.
	//UIImageView* prevImageView;
	//UIImageView* currentImageView;
	//UIImageView* nextImageView;
	MyPdfScrollView* prevPdfScrollView;
	MyPdfScrollView* currentPdfScrollView;
	MyPdfScrollView* nextPdfScrollView;
	
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
	// Gesture Recognizer for Marker Maker Pen.
    //UIPanGestureRecognizer* panRecognizer21;
	UIPanGestureRecognizer* panRecognizer1;
	UIPanGestureRecognizer* panRecognizer2;
	UIPanGestureRecognizer* panRecognizer3;
    CGPoint prevTouchPointForMakerPen;
    UIToolbar* menuBarForMakerPen;
    
	// MarkerPen.
    NSMutableArray* markerPenArray;
	NSMutableArray* pointsForSingleLine;
	bool isMarkerPenMode;

	// PDF structure.
	//CGPDFDocumentRef pdf;
	//CGPDFPageRef page;
	//CGRect pageRect;
	CGFloat pdfScale;
	
	//for pdf handle.
	NSURL* pdfURL;
	
	//
	NSMutableArray* linksInCurrentPage;
	NSMutableArray* movieDefine;
	NSMutableArray* pageJumpLinkDefine;
	NSMutableArray* inPageScrollViewDefine;
	NSMutableArray* inPagePdfDefine;
	NSMutableArray* inPagePngDefine;
	//NSMutableArray* tocDefine;
	NSMutableArray* popoverImageDefine;
	
	// Movie
	MPMoviePlayerController *mplayer;
	
	// Menu
	MenuViewController* menuViewController;
	bool isShownMenuBar;
	// WebView
	WebViewController* webViewController;
	// TocView/ThumbnailScrollView
	//TocView* tocViewController;
	bool isShownTocView;
	ThumbnailScrollViewController* thumbnailScrollViewController;
	bool isShownThumbnailScrollView;
	// BookmarkView
	BookmarkViewController* bookmarkViewController;
	bool isShownBookmarkView;
	//bool isTocWithBookmarkMode;
}

@property (nonatomic, retain) UIImageView* imageView1;
@property (nonatomic, retain) UIImageView* imageView2;
@property (nonatomic, retain) UIImageView* imageView3;
//@property (nonatomic, retain) UIScrollView* currentScrollView;
//
@property (nonatomic) bool isMarkerPenMode;
//
@property (nonatomic, retain) NSURL* pdfURL;
//
@property (nonatomic, retain) MenuViewController* menuViewController;
@property (nonatomic, retain) WebViewController* webViewController;
//@property (nonatomic, retain) TocView* tocViewController;
@property (nonatomic, retain) ThumbnailScrollViewController* thumbnailScrollViewController;
//
@property (nonatomic) bool isShownTocView;
@property (nonatomic) bool isShownThumbnailScrollView;
/**
 *Functions.
 */
// Treat PDF.
- (BOOL)setupPdfBasicInfo;
// Draw PDF.
- (NSString*)getPageFilenameFull:(int)pageNum;
- (NSString*)getPageFilenameFull:(int)pageNum;
- (NSString*)getThumbnailFilenameFull:(int)pageNum;
//
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
//
- (void)generateThumbnailImage:(CGFloat)newWidth;
- (void)generateThumbnailImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum;
//
- (void)drawPageWithNumber:(int)newPagenum;


// Move Page.
- (void)gotoNextPage;
- (void)gotoPrevPage;
- (void)switchToPage:(int)newPageNum;
- (void)switchNextImageWithAnimationType:(NSString*)animationType;
- (void)renderAllLinks;

// Handle Tap.
- (void)handleTapInLeftArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInRightArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInTopArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInBottomArea:(UIGestureRecognizer*)gestureRecognizer;
// Handle Swipe.
- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;

// Handle Pan(draw maker pen)
- (void)enterMarkerMode;
- (void)setupMarkerPenView;
- (void)setupMarkerPenMenu;
- (void)exitMarkerMode;
- (void)handlePan2:(UIPanGestureRecognizer*)gestureRecognizer;
- (void)showMenuBarForMarker;
- (void)hideMenuBarForMarker;
//
- (void)saveMarkerPenToUserDefault;
- (void)loadMarkerPenFromUserDefault;
//
- (void)renderMarkerPenFromUserDefaultAtPage:(NSUInteger)pageNum;
- (void)prepareDeleteMarkerPenWithCurrentPage;
- (void)deleteMarkerPenAtPage:(NSUInteger)pageNum;
- (void)clearMarkerPenView;
//Delete single line.
- (IBAction)deleteLastLine:(id)sender;

// Treat URL link.
- (void) renderPageLinkAtIndex:(NSUInteger)index;
- (BOOL)parseAndRenderUrlLinkDefine:(NSUInteger)index;

// Treat PageJumpLink.
- (BOOL)parsePageJumpLinkDefine;	// Parse PageJumpLink define in CSV.
- (void)renderPageJumpLinkAtIndex:(NSUInteger)index;
// Treat InPage ScrollView.
- (BOOL)parseInPageScrollViewDefine;	// Parse define in CSV.
- (void)renderInPageScrollViewAtIndex:(NSUInteger)index;
// Treat InPage Pdf.
- (BOOL)parseInPagePdfDefine;	// Parse define in CSV.
- (BOOL)renderInPagePdfAtIndex:(NSUInteger)index;
// Treat InPage Png image.
- (BOOL)parseInPagePngDefine;	// Parse define in CSV.
- (BOOL)renderInPagePngAtIndex:(NSUInteger)index;
// Treat PopoverImage.
- (BOOL)parsePopoverImageDefine;	// Parse PopoverImage define in CSV.
- (void)renderPopoverImageLinkAtIndex:(NSUInteger)index;
- (void)showPopoverImagePlayer:(NSString*)filename;
// Treat TOC.
- (BOOL)parseTocDefine;		// Parse Table Of Contents define in CSV.
//- (void)showTocView;
- (void)hideTocView;
- (void)showThumbnailScrollView;
//- (void)hideImageTocView;
- (void)hideThumbnailScrollView;
// Treat Bookmark.
- (BOOL)parseBookmarkDefine;	// get Bookmark infomation from UserDefault.
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
- (void)showWebView:(NSString*)urlString;
- (void)gotoTopPage;
- (void)gotoCoverPage;
- (void)showHelpView;

// Utility for Handle Rotate.
- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation;

@end

// Treat Movie.
@interface Pdf2iPadViewController (movie)
- (BOOL)parseMovieDefine;	// Parse Movie define in CSV.
- (void)renderMovieLinkAtIndex:(NSUInteger)index;
- (void)showMoviePlayer:(NSString*)filename;
- (void)showMoviePlayer:(NSString*)filename WithFrame:(CGRect)frame;
//
- (void)myMovieFinishedCallback:(id)sender;
@end
