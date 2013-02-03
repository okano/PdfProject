//
//  ContentListImageViewController.h
//  SakuttoBook
//
//  Created by okano on 13/01/10.
//
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"	//for read "Define.h" (it cannot load directory...)
#import "ContentListViewController.h"
#import "CoverUtility.h"
#import "FileUtility.h"				//for get device kind with iPad1&2 / new iPad.

@interface ContentListImageViewController : ContentListViewController
{
	IBOutlet UIToolbar* toolbar;
	IBOutlet UIBarButtonItem *serverContentButton;
	IBOutlet UIBarButtonItem *paymentHistoryButton;
}

//- (void)setupImagesWithDataSource:(ContentListDS*)contentListDS shelfImageName:(NSString*)shelfImageName;

@end
