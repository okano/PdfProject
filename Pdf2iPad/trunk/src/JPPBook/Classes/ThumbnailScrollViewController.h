//
//  ThumbnailScrollViewController.h
//  PdfPub
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "Utility.h"
#import "Define.h"

@interface ThumbnailScrollViewController : UIViewController {
	ContentId currentContentId;
	UIScrollView* scrollView;
}
@property (nonatomic, retain) UIScrollView* scrollView;
@property ContentId currentContentId;
//
- (IBAction)closeThisView:(id)sender;
- (void)setupViewFrame:(CGRect)frame;
- (void)setupScrollViewFrame:(CGRect)frame;
- (void)setupImages;

@end
