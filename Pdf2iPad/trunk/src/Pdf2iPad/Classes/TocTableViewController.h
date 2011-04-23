//
//  TocTableViewController.h
//  Pdf2iPad
//
//  Created by okano on 10/12/18.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "Define.h"
#import "Utility.h"


@interface TocTableViewController : UITableViewController {
	NSMutableArray* tocDefine;
}
@property (nonatomic, retain) NSMutableArray* tocDefine;

@end
