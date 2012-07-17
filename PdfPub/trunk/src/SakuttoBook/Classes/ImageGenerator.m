//
//  MyImageGenerator.m
//  SakuttoBook
//
//  Created by okano on 11/02/21.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ImageGenerator.h"


@implementation ImageGenerator


- (void)generateImageWithPageNum:(NSUInteger)pageNum
							 fromUrl:(NSURL*)pdfURL
							minWidth:(CGFloat)minWidth
{
	//LOG_CURRENT_METHOD;
	if ((! pdfURL) || (minWidth < 0)) {
		return;
	}
	
	/*
	//get Screen point/pixel rate. (for "Ratina" display)
	// (with iOS4.0 method)
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if (1.0 < [[UIScreen mainScreen] scale]) {
			minWidth = minWidth * [[UIScreen mainScreen] scale];
		} else {
			minWidth = minWidth * 2.0f;	//draw with double size for pinch-out.
		}
	} else {
		//old iOS 3.2
		minWidth = minWidth * 2.0f;
	}
	*/

	
	id pool = [ [ NSAutoreleasePool alloc] init];
	//NSLog(@"pageNum=%d", pageNum);
	
	//get pdf document.
	CGPDFDocumentRef pdfDocument;
	pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	if (! pdfDocument) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"pdfDocument cannot get.");
		//NSLog(@"pdfURL=%@", [pdfURL standardizedURL]);
		return;
	}
	
	//(PDF is 1-start.)
	//pageNum = pageNum + 1;
	//get pdf page.
	CGPDFPageRef pdfPage;
	pdfPage = CGPDFDocumentGetPage(pdfDocument, pageNum);
	if (! pdfPage) {
		LOG_CURRENT_METHOD;
		NSLog(@"pdfPage cannot get. pageNum=%d", pageNum);
		return;
	}
	
	//Get page frame size.
	CGRect imageFrame;
	CGRect originalPageRect;
	originalPageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
	
	//get scale for fit screen.
	//(scale < 1.0)  = pdf is large than screen(minSize)
	//(scale ==1.0)  = pdf equal screen(minSize)
	//(1.0   < scale)= pdf is small than screen(minSize)
	CGFloat scaleToFitWidth = minWidth / originalPageRect.size.width;
	
	//set draw rect for image cache.
	if (originalPageRect.size.width < minWidth) {
		imageFrame = CGRectMake(0.0f,
								0.0f,
								originalPageRect.size.width * scaleToFitWidth,
								originalPageRect.size.height * scaleToFitWidth);
	} else {
		imageFrame = originalPageRect;
	}
	//LOG_CURRENT_METHOD;
	//NSLog(@"imageFrame=%@", NSStringFromCGRect(imageFrame));
	
	
	//
	UIGraphicsBeginImageContext(imageFrame.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context, imageFrame);
	
//	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, imageFrame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	//Scale PDF for fit Screen. (streatch only PDF smaller than Screen.)
	if (originalPageRect.size.width < minWidth) {
		//PDF.width <= Screen.width
		CGContextScaleCTM(context, scaleToFitWidth, scaleToFitWidth);
	}
	
	//setup for Draw PDF.
	//@see:http://stackoverflow.com/questions/2975240/cgcontextdrawpdfpage-taking-up-large-amounts-of-memory
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
	
	//Draw PDF into context.
	CGContextDrawPDFPage(context, pdfPage);
	
	CGPDFDocumentRelease(pdfDocument);

//	CGContextRestoreGState(context);
	
	//Get image from context.
	UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();
	//[pdfImage retain];//(needs count down in calling method.)
	if (! pdfImage) {
		NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
	}
	//NSLog(@"context retainCount=%d", CFGetRetainCount(context));
	
	UIGraphicsEndImageContext();
	//NSLog(@"context retainCount=%d", CFGetRetainCount(context));
	
	//Release PDFDocument.
	//if (pdfDocument) {
		//NSLog(@"pdfDocument reference count=%d", [pdfDocument retainCount]);
//		CGPDFDocumentRelease(pdfDocument);
		//pdfDocument = nil;
	//}
	
	
	//Save to file.
	NSString* targetFilenameFull = [self getPageFilenameFull:pageNum];
	NSData *data = UIImagePNGRepresentation(pdfImage);
	NSError* error = nil;
	[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
	if (error) {
		NSLog(@"page file write error. path=%@", targetFilenameFull);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		return;
	} else {
		//NSLog(@"wrote page file to %@", targetFilenameFull);
	}
	
	
	if (! pdfImage) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		//Release PDFDocument.
		if (pdfDocument) {
			CGPDFDocumentRelease(pdfDocument);
			pdfDocument = nil;
		}
		return;
	}
	
	//[pool drain];
	[pool release];
	
	
	return;
}


#pragma mark -
- (NSString*)getPageFilenameFull:(int)pageNum {
	NSString* filename = [NSString stringWithFormat:@"%@%d", PAGE_FILE_PREFIX, pageNum];
	NSString* targetFilenameFull = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:PAGE_FILE_EXTENSION];
	return targetFilenameFull;
}


@end
