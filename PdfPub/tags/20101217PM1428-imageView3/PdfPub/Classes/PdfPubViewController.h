//
//  PdfPubViewController.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Utility.h"
#import "Define.h"
#import "pdfDefine.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "TocView.h"

@interface PdfPubViewController : UIViewController {
	// View
	IBOutlet UIImageView* imageView1;
	IBOutlet UIImageView* imageView2;
	IBOutlet UIImageView* imageView3;
	UIImage* image1;
	UIImage* image2;
	UIImage* image3;
	// Pointer
	UIImageView* prevImageView;
	UIImageView* currentImageView;
	UIImageView* nextImageView;
	
	// PDF structure.
	CGPDFDocumentRef pdf;
	CGPDFPageRef page;
	CGRect pageRect;
	CGFloat pdfScale;
	
	// 
	int currentPageNum;
	int maxPageNum;
	
	// Gesture Recognizer for imageView, imageScrollView.
	UITapGestureRecognizer* tapRecognizer1;
	UITapGestureRecognizer* tapRecognizer2;
	UITapGestureRecognizer* tapRecognizer3;
	
	//
	NSMutableArray* linksInCurrentPage;
	NSMutableArray* movieDefine;
	//NSMutableArray* tocDefine;
	
	// Menu
	MenuViewController* menuViewController;
	// WebView
	WebViewController* webViewController;
	// TocView
	TocView* tocViewController;
}

@property (nonatomic, retain) UIImageView* imageView1;
@property (nonatomic, retain) UIImageView* imageView2;
@property (nonatomic, retain) UIImageView* imageView3;
@property (nonatomic, retain) UIImage* image1;
@property (nonatomic, retain) UIImage* image2;
@property (nonatomic, retain) UIImage* image3;
@property (nonatomic, retain) MenuViewController* menuViewController;
@property (nonatomic, retain) WebViewController* webViewController;
@property (nonatomic, retain) TocView* tocViewController;
//for get value in TocViewController.
@property (nonatomic, retain) UIImageView* currentImageView;

/**
 *Functions.
 */
// Treat PDF.
- (BOOL)initPdfWithFilename:(NSString*)filename;
// Handle PDF infomation.
- (BOOL)isVerticalWriting;
//- (void)getPdfDictionaryWithPageNum:(NSUInteger)pageNum;
- (void) renderPageLinkAtIndex:(NSUInteger)index;

// Draw PDF.
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;
- (void)drawPageWithNumber:(int)newPagenum;

// Move Page.
- (void)gotoNextPage;
- (void)gotoPrevPage;
- (void)switchToPage:(int)newPageNum;
- (void)switchNextImageWithAnimationType:(NSString*)animationType;
// Handle Tap.
- (void)handleTapInLeftArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInRightArea:(UIGestureRecognizer*)gestureRecognizer;
- (void)handleTapInTopArea:(UIGestureRecognizer*)gestureRecognizer;
// Treat Movie.
- (BOOL)parseMovieDefine;	// Parse Movie define in CSV.
- (void)renderMovieLinkAtIndex:(NSUInteger)index;
- (void)showMoviePlayer:(NSString*)filename;
// Treat TOC.
- (BOOL)parseTocDefine;		// Parse Table Of Contents define in CSV.
- (void)showTocView;

// Menu.
- (void)toggleMenuBar;
- (void)showMenuBar;
- (void)hideMenuBar;
// Show other view.
- (IBAction)showInfoView;
- (void)showWebView:(NSString*)urlString;

@end

