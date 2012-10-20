//
//  ViewController.m
//  mailSendTest01
//
//  Created by okano on 12/10/20.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//@see: http://www.mikamiz.jp/dev/iphone/a0005.html
//
- (IBAction)pushMailButton:(id)sender
{
	NSLog(@"mail button pushed");
	if( [MFMailComposeViewController canSendMail ] == NO ) {
		NSLog(@"mail cannot send.");
		
		[ [ [ [ UIAlertView alloc ] initWithTitle:@"エラー" message:@"メールアカウントを設定してください" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil ] autorelease ] show ];
		return;
	}
	

	//
	MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
	
	[ controller setSubject:@"テストメール" ];
	[ controller setToRecipients:[ NSArray arrayWithObject:@"main@example.com" ] ];
	[ controller setCcRecipients:[ NSArray arrayWithObjects:@"cc1@example.com", @"cc2@excample.com", nil ] ];
	[ controller setBccRecipients:[ NSArray arrayWithObjects:@"bcc1@example.com", @"bcc2@excample.com", nil ] ];
	[ controller setMessageBody:@"サンプルメールn２行目n３行目" isHTML:NO ];
	controller.mailComposeDelegate = self;
	
	[ self presentModalViewController:controller animated:YES ];

}


//<MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{
	
	if( error != nil )
	{
		NSLog( @"エラーが発生しました。" );
		[controller dismissModalViewControllerAnimated:YES];
		return;
	}
	
	switch( result )
	{
		case MFMailComposeResultSent: NSLog( @"メールを送信" ); break;
		case MFMailComposeResultSaved: NSLog( @"メールを保存" ); break;
		case MFMailComposeResultCancelled: NSLog( @"キャンセル" ); break;
		case MFMailComposeResultFailed: NSLog( @"失敗" ); break;
		default: NSLog( @"不明な結果" ); break;
	}
	[controller dismissModalViewControllerAnimated:YES];
	
}

@end
