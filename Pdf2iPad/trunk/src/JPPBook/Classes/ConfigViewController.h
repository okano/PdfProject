//
//  ConfigView.h
//  JPPBook
//
//  Created by okano on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Define.h"
#import "UrlDefine.h"

@interface ConfigViewController : UIViewController {
	IBOutlet UITextField* textField;   
}
- (IBAction)handleDoneButton:(id)sender;
- (IBAction)closeThisView:(id)sender;
//
- (IBAction)setDefaultUrl1:(id)sender;
- (IBAction)setDefaultUrl2:(id)sender;
//
- (void)saveUrlToUserDefault:(NSString*)urlStr;
+ (NSString*)getUrlBaseWithOpds;

@end
