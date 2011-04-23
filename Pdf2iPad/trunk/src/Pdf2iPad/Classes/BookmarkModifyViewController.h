//
//  BookmarkModifyViewController.h
//  SakuttoBook
//
//  Created by okano on 11/01/05.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "Utility.h"
#import "Define.h"

@interface BookmarkModifyViewController : UIViewController {
	IBOutlet UITextField* bookmarkNameField;
	IBOutlet UILabel* pageNumberLabel;
}
- (IBAction)addBookmark:(id)sender;
- (IBAction)closeThisView:(id)sender;
- (void)setPageNumberForPrint:(int)pageNum;

@end
