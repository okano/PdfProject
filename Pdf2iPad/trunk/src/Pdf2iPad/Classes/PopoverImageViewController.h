//
//  PopoverImageViewController.h
//  Pdf2iPad
//
//  Created by okano on 11/02/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBEngine_PopoverScrollImageViewController.h"
#import "Utility.h"

@interface PopoverImageViewController : SKBEngine_PopoverScrollImageViewController <UIScrollViewDelegate> {
	UIScrollView* scrollView;
	UIImageView* imageView;
}

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIImageView* imageView;
//- (void)setupWithImage:(UIImage*)image;
- (id)initWithImageFilename:(NSString*)filename;
- (void)toggleZoom:(UITapGestureRecognizer*)gesture;

@end
