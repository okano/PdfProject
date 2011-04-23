//    File: PDFScrollView.h
//Abstract: UIScrollView subclass that handles the user input to zoom the PDF page.  This class handles swapping the TiledPDFViews when the zoom level changes.
#import <UIKit/UIKit.h>
#import "Utility.h"

@class TiledPDFView;

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate> {
	// The TiledPDFView that is currently front most
	TiledPDFView *pdfView;
	// The old TiledPDFView that we draw on top of when the zooming stops
	TiledPDFView *oldPDFView;
	
	// A low res image of the PDF page that is displayed until the TiledPDFView
	// renders its content.
	UIImageView *backgroundImageView;


	// current pdf zoom scale
	CGFloat pdfScale, originalPdfScale;
	
	CGPDFPageRef page;
	CGPDFDocumentRef pdf;
	//
	CGRect pageRect;
}
- (void)initPdfWithFilename:(NSString*)filename;
- (void)setupWithPageNum:(NSUInteger)newPageNum;

@end
