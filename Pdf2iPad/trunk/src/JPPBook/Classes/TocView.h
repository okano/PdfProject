//
//  TocView2.h
//  PdfPub
//
//  Created by okano on 10/12/14.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "Utility.h"
#import "Define.h"

@interface TocView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView* myTableView;
}
- (IBAction)closeThisView:(id)sender;

@end
