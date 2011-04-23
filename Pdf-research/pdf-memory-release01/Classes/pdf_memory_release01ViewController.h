//
//  pdf_memory_release01ViewController.h
//  pdf-memory-release01
//
//  Created by okano on 11/02/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pdf_memory_release01ViewController : UIViewController {
	//Label.
	IBOutlet UILabel* pageNumberLabel;
	IBOutlet UILabel* pdfDocumentAddressLabel;
	IBOutlet UILabel* pdfDocumentRetainCountLabel;
	IBOutlet UILabel* pdfPageAddressLabel;
	IBOutlet UILabel* pdfPageRetainLabel;
	IBOutlet UIImageView* imageView;
	//Page Number.
	int currentPageNum;
	// PDF structure.
	CGPDFDocumentRef pdfDocument;
	CGPDFPageRef pdfPage;
}

- (IBAction)openDocument;
- (IBAction)openPage;
- (IBAction)showPdf;
- (IBAction)gotoNextPage;
- (IBAction)gotoPrevPage;
- (IBAction)closePage;
- (IBAction)closeDocument;
- (void)refreshAllLabel;
- (void)refreshPageNumberLabel;
- (void)refreshPdfDocumentAddressLabel;
- (void)refreshPdfDocumentRetainCountLabel;
- (void)refreshPdfPageAddressLabel;
- (void)refreshPdfPageRetainCountLabel;

@end

#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#  define LOG_CURRENT_LINE NSLog(@"%s line %d", __FILE__, __LINE__);

