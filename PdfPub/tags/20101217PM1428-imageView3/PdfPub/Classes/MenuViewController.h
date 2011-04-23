//
//  MenuViewController.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "PdfPubAppDelegate.h"
@class PdfPubViewController;
@class TocViewController;
//#import "PdfPubViewController.h"
//#import "TocViewController.h"

@interface MenuViewController : UIViewController {

}
- (IBAction)showTocView:(id)sender;
- (IBAction)closeThisView:(id)sender;

@end
