//
//  InfomationViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/25.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"

@interface InfomationViewController : UIViewController {
	//ContentId.
	ContentId contentId;
	//Book infomation label.
	IBOutlet UILabel* bookTitleLabel;
	IBOutlet UILabel* bookAuthorLabel;
	IBOutlet UILabel* bookCopyrightLabel;
	NSString* bookSupportPageUrl;
	IBOutlet UIButton* bookSupportPageButton;	/* outlet for hidden. */
	//Program infomation label.
	IBOutlet UILabel* licenceNumberLabel;
}
@property (nonatomic) ContentId contentId;
//UI
@property (nonatomic, retain) UILabel* bookTitleLabel;
@property (nonatomic, retain) UILabel* bookAuthorLabel;
@property (nonatomic, retain) UILabel* bookCopyrightLabel;
@property (nonatomic, retain) NSString* bookSupportPageUrl;
@property (nonatomic, retain) UIButton* bookSupportPageButton;
@property (nonatomic, retain) UILabel* licenceNumberLabel;

- (IBAction)closeThisView:(id)sender;
- (void)setBookInfoFromDefineFile;
- (void)showWebView:(NSString*)urlString;
- (IBAction)openBookSupportPage:(id)sender;
- (IBAction)openProgramSupportPage:(id)sender;

@end
