//
//  PageSmallViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "Utility.h"
#import "Define.h"
#import "FileUtility.h"

@interface PageSmallViewController : UIViewController {
	UIToolbar* toolBar;
	UIScrollView* scrollView;
}
@property (nonatomic, retain) UIToolbar* toolBar;
@property (nonatomic, retain) UIScrollView* scrollView;
//
- (IBAction)closeThisView:(id)sender;
- (void)setupImages;

@end
