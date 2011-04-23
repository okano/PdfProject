//
//  TocViewController.h
//  PdfPub
//
//  Created by okano on 10/11/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfPubAppDelegate.h"
#import "PdfPubViewController.h"

@interface TocViewController : UITableViewController {
	NSMutableArray* tocText;
}
@property (nonatomic, retain) NSMutableArray* tocText;
@end
