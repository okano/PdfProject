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
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Utility.h"
#import "FileUtility.h"
#import "Define.h"
#import "MarkerPenView.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "PopoverScrollImageViewController.h"
#import "InfomationViewController.h"
#import "TocViewController.h"
#import "BookmarkViewController.h"
#import "BookmarkModifyViewController.h"
#import "PageSmallViewController.h"

@class TiledPDFView;
//#import "PDFScrollView.h"
//
#import "MyPdfScrollView.h"

#import "ImageGenerator.h"

@interface ContentPlayerViewController : UIViewController <UIActionSheetDelegate, AVAudioPlayerDelegate> {
	// Views.
	IBOutlet MyPdfScrollView* pdfScrollView1;
	IBOutlet MyPdfScrollView* pdfScrollView2;
	IBOutlet MyPdfScrollView* pdfScrollView3;
	
	//Marker pen.
	MarkerPenView* markerPenView2;

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
	bool isVerticalWriting;
	
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
	
	// MarkerPen.
    NSMutableArray* markerPenArray;
	NSMutableArray* pointsForSingleLine;
	bool isMarkerPenMode;
	CGPoint prevTouchPointForMakerPen;
    UIToolbar* menuBarForMakerPen;
	
	//
	NSMutableArray* linksInCurrentPage;
	NSMutableArray* urlDefineWithCsv;
	NSMutableArray* movieDefine;
	NSMutableArray* mailDefine;
	NSMutableArray* soundDefine;
	NSMutableArray* pageJumpLinkDefine;
	NSMutableArray* inPageScrollViewDefine;
	//NSMutableArray* tocDefine;
	NSMutableArray* popoverScrollImageDefine;
	
	
	// Menu
	MenuViewController* menuViewController;
	MenuViewController* menuBottomViewController;	//	UIToolbar* bottomToolBar;
	
	// WebView
	WebViewController* webViewController;
	NSMutableString* urlForWeb;
	// TocView, PageSmallView.
	TocViewController* tocViewController;
	PageSmallViewController* pageSmallViewController;
	// BookmarkView
	BookmarkViewController* bookmarkViewController;
	bool isShownMenuBar;
	bool isShownTocView;
	bool isShownPageSmallView;
	bool isShownBookmarkView;
	//bool isTocWithBookmarkMode;
	
	
	// Audio(sound for page open)
	AVAudioPlayer* audioPlayer;
	NSTimer* soundDelayTimer;
}
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView1;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView2;
@property (nonatomic, retain) MyPdfScrollView* pdfScrollView3;
//
@property (nonatomic, retain) NSURL* pdfURL;
@property (nonatomic) bool isVerticalWriting;

@property (nonatomic) ContentId currentContentId;

@property (nonatomic) bool isMarkerPenMode;

//@property (nonatomic, retain) UIImageView* imageView1;
//@property (nonatomic, retain) UIImageView* imageView2;
//@property (nonatomic, retain) UIImageView* imageView3;
//@property (nonatomic, retain) UIImage* image1;
//@property (nonatomic, retain) UIImage* image2;
//@property (nonatomic, retain) UIImage* image3;
@property (nonatomic, retain) MenuViewController* menuViewController;
@property (nonatomic, retain) MenuViewController* menuBottomViewController;
//@property (nonatomic, retain) UIToolbar* bottomToolBar;
@property (nonatomic, retain) WebViewController* webViewController;
@property (nonatomic, retain) TocViewController* tocViewController;
@property (nonatomic, retain) PageSmallViewController* pageSmallViewController;
@property (nonatomic, retain) BookmarkViewController* bookmarkViewController;
//
@property (nonatomic) bool isShownMenuBar;
@property (nonatomic) bool isShownTocView;
@property (nonatomic) bool isShownPageSmallView;
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
/* - (BOOL)isVerticalWriting; */
- (BOOL)isTransitionWithCurl;
- (BOOL)isMultiContents;
//- (void)getPdfDictionaryWithPageNum:(NSUInteger)pageNum;

// Draw PDF.
- (NSString*)getPageFilenameFull:(int)pageNum;
- (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
- (NSString*)getPageSmallFilenameFull:(int)pageNum;
- (NSString*)getPageSmallFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
//
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithContentId:(ContentId)cid;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum WithTargetFilenameFull:(NSString*)filename;
//- (void)generatePageSmallImageFromImage:(UIImage*)baseImage width:(CGFloat)newWidth pageNumForSave:(NSUInteger)pageNum;
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
// Treat Mail send. -> implement with Category.
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
- (void)showPageSmallView;
- (void)hidePageSmallView;
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
- (void)showWebView:(NSString*)urlString;
- (void)showWebViewSelector:(NSString*)urlString;
- (void)showWebViewInThisApp:(NSString*)urlString;
- (void)showWebWithSafari:(NSString*)urlString;

// Utility for Handle Rotate.
- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation;

// Utility for filename.
- (NSString*)formatStringWithAlphaNumeric:(NSString*)originalStr;

// Latest Read Page.
- (void)setLatestReadPage:(int)pageNum;
- (int)getLatestReadPage;

@end


// Treat Sound.
@interface ContentPlayerViewController (soundonpage)
- (void)parseSoundOnPageDefine;
- (bool)isContainSountAtIndex:(NSUInteger)index;
- (void)playSoundAtIndex:(NSUInteger)index;
- (void)playSoundWithUrl:(NSURL*)soundURL;
- (void)playSoundWithUrl:(NSURL*)soundURL withDelay:(NSNumber*)delayTime;
- (void)timerHandlerForPlaySound:(NSTimer*)timer;
- (void)stopSound;
@end


// Treat Mail send.
@interface ContentPlayerViewController (mailSend) <MFMailComposeViewControllerDelegate>
- (void)parseMailDefine;	// Parse Mail define in CSV.
- (void)renderMailLinkAtIndex:(NSUInteger)index;
- (void)showMailComposerWithSubject:(NSString*)subject
						toRecipient:(NSArray*)toRecipient
						ccRecipient:(NSArray*)ccRecipient
					   bccRecipient:(NSArray*)bccRecipient
						messageBody:(NSString*)messageBody;
@end

// Treat bottom menu bar.
@interface ContentPlayerViewController (bottomMenu)
- (void)showBottomMenu;
- (void)hideBottomMenu;
@end

// Treat Url link specified in CSV file.
@interface ContentPlayerViewController (urlWithCsv)
- (void)parseUrlLinkWithCsvDefine;	// Parse Url Link define in CSV.
- (void)renderUrlLinkWithCsvAtIndex:(NSUInteger)index;
@end

// Treat Url link specified in CSV file.
@interface ContentPlayerViewController (markerPen)
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
@end


//#define EPUB_RESOURCES_DIRECTORY	@"content/resources"
//#define CONTENT_DETAIL_DIRECTORY	@"contentDetail"
#define CONTENT_BODY_DIRECTORY		@"contentBody"
#define CONTENT_TMP_DIRECTORY		@"tmp"
//#define CONTENT_DONWLOAD_DIRECTORY  @"downloads"
//#define CONTENT_EXTRACT_DIRECTORY	@"extract"

#define ACTIONSHEET_TAG_SHOW_WEBVIEW_SELECTOR		201
#define ACTIONSHEET_TAG_PREPARE_DELETE_MARKERPEN	202
