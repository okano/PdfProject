//
//  pdf_memory_release01ViewController.m
//  pdf-memory-release01
//
//  Created by okano on 11/02/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "pdf_memory_release01ViewController.h"

@implementation pdf_memory_release01ViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	pdfDocument = nil;
	pdfPage = nil;
	[self refreshAllLabel];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)openDocument
{
	//LOG_CURRENT_METHOD;

	
	//Open pdf file.
	NSString* pdfFilename = [NSString stringWithFormat:@"document.pdf"];
	NSURL* pdfURL = [[NSBundle mainBundle] URLForResource:pdfFilename withExtension:nil];
	if (!pdfURL) {
		NSLog(@"PDF file not exist. filename=%@", pdfFilename);
		return;
	}
	pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	currentPageNum = 1;	//1-start.
	[self refreshAllLabel];
}
- (IBAction)openPage
{
	//LOG_CURRENT_METHOD;
	
	pdfPage = CGPDFDocumentGetPage(pdfDocument, currentPageNum);
	[self refreshAllLabel];
}
- (IBAction)showPdf
{
	//Generate PageImage.
	CGRect imageFrame = CGRectMake(0.0f, 0.0f, 960.0f, 640.0f);

	UIGraphicsBeginImageContext(imageFrame.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context, imageFrame);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, imageFrame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	//Draw PDF into context.
	CGContextDrawPDFPage(context, pdfPage);
	CGContextRestoreGState(context);
	
	//Get image from context.
	UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	imageView.image = pdfImage;
}
- (IBAction)gotoNextPage
{
	//LOG_CURRENT_METHOD;
	currentPageNum = currentPageNum + 1;
	[self refreshAllLabel];
}
- (IBAction)gotoPrevPage
{
	//LOG_CURRENT_METHOD;
	currentPageNum = currentPageNum - 1;
	[self refreshAllLabel];
}
- (IBAction)closePage
{
	/*
	//LOG_CURRENT_METHOD;
	if (pdfPage) {
		CGPDFPageRelease(pdfPage);
		pdfPage = nil;
	}
	[self refreshAllLabel];
	*/
	
	//
	//
	//
	//
	//CGPDFPage got by CGPDFDocumentGetPage() is Autorelease-Object.
	//@see:http://stackoverflow.com/questions/3871524/stop-drawing-of-catiledlayer
	//
	//
	//
	//
}
- (IBAction)closeDocument
{
	//LOG_CURRENT_METHOD;
	LOG_CURRENT_LINE;
	if (pdfDocument) {
		LOG_CURRENT_LINE;
		CGPDFDocumentRelease(pdfDocument);
		LOG_CURRENT_LINE;
		pdfDocument = nil;
		LOG_CURRENT_LINE;
	}
	LOG_CURRENT_LINE;
	[self refreshAllLabel];
	LOG_CURRENT_LINE;
}

- (void)refreshAllLabel {
	[self refreshPageNumberLabel];
	[self refreshPdfDocumentAddressLabel];
	[self refreshPdfDocumentRetainCountLabel];
	[self refreshPdfPageAddressLabel];
	[self refreshPdfPageRetainCountLabel];
}
- (void)refreshPageNumberLabel {
	pageNumberLabel.text = [NSString stringWithFormat:@"%d", currentPageNum];
}
- (void)refreshPdfDocumentAddressLabel {
	pdfDocumentAddressLabel.text = [NSString stringWithFormat:@"%p", pdfDocument];
}
- (void)refreshPdfDocumentRetainCountLabel {
	if (pdfDocument) {
		pdfDocumentRetainCountLabel.text = [NSString stringWithFormat:@"%d", CFGetRetainCount(pdfDocument)];
	} else {
		pdfDocumentRetainCountLabel.text = @"(nil)";
	}

}
- (void)refreshPdfPageAddressLabel {
		pdfPageAddressLabel.text = [NSString stringWithFormat:@"%p", pdfPage];
}
- (void)refreshPdfPageRetainCountLabel {
	return;
	if (pdfPage) {
		int n1 = CFGetRetainCount(pdfPage);
		pdfPageRetainLabel.text = [NSString stringWithFormat:@"%d", n1];
	} else {
		pdfPageRetainLabel.text = @"(nil)";
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
