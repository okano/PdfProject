//
//  MenuViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "SakuttoBookAppDelegate.h"
@class SakuttoBookViewController;
//@class TocViewController;
//#import "SakuttoBookViewController.h"
//#import "TocViewController.h"

@interface MenuViewController : UIViewController {

}
- (IBAction)showTocView:(id)sender;
- (void)hideTocView;
//- (IBAction)showBookmarkView:(id)sender;
//- (void)hideBookmarkView;
//- (IBAction)showThumbnailView:(id)sender;
- (IBAction)closeThisView:(id)sender;
- (IBAction)showInfoView:(id)sender;
//- (IBAction)showBookmarkModifyView:(id)sender;
//- (IBAction)addBookmarkWithCurrentPage:(id)sender;

@end
