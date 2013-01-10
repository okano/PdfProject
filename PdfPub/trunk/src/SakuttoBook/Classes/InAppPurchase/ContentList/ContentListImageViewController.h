//
//  ContentListImageViewController.h
//  SakuttoBook
//
//  Created by okano on 13/01/10.
//
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"	//for read "Define.h" (it cannot load directory...)
//#import "ContentListViewController.h"

@interface ContentListImageViewController : UIViewController /* :ContentListViewController */
{
	IBOutlet UIToolbar* toolbar;
	IBOutlet UIBarButtonItem *serverContentButton;
	IBOutlet UIBarButtonItem *paymentHistoryButton;
}
@end
