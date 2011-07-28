//
//  MyPdfScrollView.h
//  Pdf2iPad
//
//  Created by okano on 10/12/20.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBE_PdfScrollView2.h"
#import "Pdf2iPadAppDelegate.h"
#import "Utility.h"

@interface MyPdfScrollView : SKBE_PdfScrollView2 <UIScrollViewDelegate> {
	ContentId currentContentId;
}

- (void)setupUiScrollView;
- (void)setupCurrentPageWithSize:(CGSize)newSize;
- (void)setupWithPageNum:(NSUInteger)newPageNum;
- (void)setupWithPageNum:(NSUInteger)newPageNum ContentId:(ContentId)cid;
//- (UIImage*)getPdfImageWithRect:(CGRect)pageRect scale:(CGFloat)pdfScale;
//
- (void)cleanupSubviews;
- (void)resetScrollView;
//Treat subview.
- (void)addScalableSubview:(UIView *)view withNormalizedFrame:(CGRect)normalizedFrame;
@end
