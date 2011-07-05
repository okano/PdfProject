//
//  MenuViewController.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Pdf2iPadAppDelegate.h"
@class ContentPlayerViewController;
#import "TocTableViewController.h"

@interface MenuViewController : UIViewController <UIPopoverControllerDelegate> {
	UIPopoverController* aPopover;
}
- (IBAction)showTocView:(id)sender;
- (IBAction)showImageTocView:(id)sender;
- (IBAction)showInfoView:(id)sender;
- (IBAction)gotoTopPage:(id)sender;
- (IBAction)gotoCoverPage:(id)sender;
- (IBAction)showHelpView:(id)sender;
//
- (IBAction)showBookmarkView:(id)sender;
- (void)hideBookmarkView;
- (IBAction)showBookmarkModifyView:(id)sender;
//- (IBAction)addBookmarkWithCurrentPage:(id)sender;
//
- (IBAction)enterMarkerMode:(id)sender;
//
- (void)hideTocView;
//
- (IBAction)closeThisView:(id)sender;

@end
