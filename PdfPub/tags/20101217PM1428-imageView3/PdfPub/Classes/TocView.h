//
//  TocView2.h
//  PdfPub
//
//  Created by okano on 10/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfPubAppDelegate.h"
#import "Utility.h"
#import "Define.h"

@interface TocView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView* myTableView;
}
- (IBAction)closeThisView:(id)sender;

@end
