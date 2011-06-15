//
//  PaymentHistoryListViewController.h
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "PaymentHistoryDS.h"

@interface PaymentHistoryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	SakuttoBookAppDelegate* appDelegate;
}

@end
