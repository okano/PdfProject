//
//  PdfPubViewController.h
//  PdfPub
//
//  Created by okano on 10/11/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfPubAppDelegate.h"
#import "TiledPDFView.h"
#import "TocViewController.h"

@interface PdfPubViewController : UIViewController <UIScrollViewDelegate> {

    // 現在のページインデックス
    int             _index;
    
    UIImageView*    _leftImageView;
    UIScrollView*   _centerScrollView;
    //UIImageView*    _centerImageView;
	TiledPDFView*	_centerPdfView;
    UIImageView*    _rightImageView;
    
	//3面鏡
    IBOutlet UIScrollView*  _rootScrollView;
	
	// Navigation Bar & Tool Bar.
	IBOutlet UINavigationBar* navigationBar;
	//IBOutlet UIToolbar* toolBarLower;
	// Button.
	IBOutlet UIBarButtonItem* indexButton;
	IBOutlet UINavigationItem* navigationItem;
	//IBOutlet UIBarButtonItem* settingButton;
	
	
	// PDF
	CGPDFDocumentRef pdf;
	CGPDFPageRef page;
	CGRect pageRect;
	CGFloat pdfScale;
	
	//TiledPDFView *pdfView;
	//uint currentPageNum;
}

// Appearance
- (void)_renewPageIndex;
- (void)drawPageWithCurrentIndex;
- (void)renewPageWithIndex:(int)newIndex;

//PDF
-(void)setDefaultPdfFile;
//-(void)drawPdf:(uint)pageNum;
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum;

- (IBAction)showTocView:(id)sender;
//- (void)closeTocView:(int)newHtmlFileNum;//treat in TocViewController.

- (void)toggleNavigationBar;

@end

#define IPHONE_SCREEN_WIDTH		320.0f
#define IPHONE_SCREEN_HEIGHT	480.0f

#define NAVIGATION_BAR_TITLE	@"春はあけぼの"
