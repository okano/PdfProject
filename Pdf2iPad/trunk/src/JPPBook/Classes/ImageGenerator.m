//
//  MyImageGenerator.m
//  SakuttoBook
//
//  Created by okano on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageGenerator.h"


@implementation ImageGenerator


- (void)generateImageWithPageNum:(NSUInteger)pageNum
							 fromUrl:(NSURL*)pdfURL
							pdfScale:(CGFloat)pdfScale
						   viewFrame:(CGRect)viewFrame
{
	LOG_CURRENT_METHOD;
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
	
	
	
	
	
	//PDF is 1-start.
	//pageNum = pageNum + 1;
	//get pdf page.
	CGPDFPageRef pdfPage;
	pdfPage = CGPDFDocumentGetPage(pdfDocument, pageNum);
	if (! pdfPage) {
		LOG_CURRENT_METHOD;
		NSLog(@"pdfPage cannot get. pageNum=%d", pageNum);
		return;
	}
	
	//Generate PageImage.
	//UIImage* image;
	CGRect imageFrame = CGRectMake(0.0f, 0.0f, 960.0f, 640.0f);
	//image = [self generatePageImageFromPdfPage:pdfPage withSize:imageFrame.size pageNumForSave:pageNum pdfScale:pdfScale viewFrame:viewFrame];
	
	if (! pdfPage) {
		NSLog(@"illigal page. source line=%d", __LINE__);
		return;
	}
	if (imageFrame.size.width <= 0.0f || imageFrame.size.height <= 0.0f) {
		return;
	}
	
	//Get page frame size.
	CGRect originalPageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
	CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
	pdfScale = viewFrame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	LOG_CURRENT_METHOD;
	NSLog(@"pdfScale=%f", pdfScale);
	NSLog(@"originalPageRect in page 1 = %@", NSStringFromCGRect(originalPageRect));
	NSLog(@"pageRect in page %d = %@", pageNum, NSStringFromCGRect(pageRect));
	
	//Determin size for image.
	//CGRect imageFrame;
	if (originalPageRect.size.width <= viewFrame.size.width) {
		//PDF.width <= Screen.width
		imageFrame = pageRect;
	} else {
		imageFrame = originalPageRect;
	}
	LOG_CURRENT_METHOD;
	NSLog(@"imageFrame=%@", NSStringFromCGRect(imageFrame));
	
	
	
	//CGRect imageFrame;
	//imageFrame = CGRectMake(0.0f, 0.0f, newSize.width, newSize.height);

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
	if (originalPageRect.size.width <= viewFrame.size.width) {
		//PDF.width <= Screen.width
		CGContextScaleCTM(context, pdfScale, pdfScale);
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
	UIImage *pdfImage = UIGraphicsGetImageFromCurrentImageContext();	//autoreleased image object.
	//[pdfImage retain];//(needs count down in calling method.)
	if (! pdfImage) {
		NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
	}
	NSLog(@"context retainCount=%d", CFGetRetainCount(context));
	
	UIGraphicsEndImageContext();
	NSLog(@"context retainCount=%d", CFGetRetainCount(context));
	
	//Release PDFDocument.
	//if (pdfDocument) {
		//NSLog(@"pdfDocument reference count=%d", [pdfDocument retainCount]);
//		CGPDFDocumentRelease(pdfDocument);
		//pdfDocument = nil;
	//}
	
	
	//Save to file.
	NSString* targetFilenameFull = [self getPageFilenameFull:pageNum];
	NSData *data = UIImagePNGRepresentation(pdfImage);	//autoreleased data object.
	NSError* error = nil;
	[data writeToFile:targetFilenameFull options:NSDataWritingAtomic error:&error];
	if (error) {
		NSLog(@"page file write error. path=%@", targetFilenameFull);
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		return;
	} else {
		NSLog(@"wrote page file to %@", targetFilenameFull);
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