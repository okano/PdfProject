//
//  ViewController.h
//  mailSendTest01
//
//  Created by okano on 12/10/20.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)pushMailButton:(id)sender;
@end
