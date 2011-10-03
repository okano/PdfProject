//
//  ConfigView.h
//  JPPBook
//
//  Created by okano on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface ConfigViewController : UIViewController {
	IBOutlet UITextField* textField;   
}
- (IBAction)handleDoneButton:(id)sender;
- (void)saveUrlToUserDefault:(NSString*)urlStr;
- (IBAction)closeThisView:(id)sender;

@end
