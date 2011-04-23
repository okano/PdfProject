//
//  GetPdfHyperlinkViewController.h
//  GetPdfHyperlink
//
//  Created by okano on 10/12/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetPdfHyperlinkViewController : UIViewController {
	// PDF
	CGPDFDocumentRef pdf;
	CGPDFPageRef page;
	CGRect pageRect;
	CGFloat pdfScale;
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx;

@end

