//
//  ViewController.m
//  socialFramework-1
//
//  Created by okano on 2013/09/13.
//  Copyright (c) 2013年 okano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSocialPostView:(id)sender
{
    NSLog(@"aa");
    SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterPostVC setInitialText:@"aa"];
    [self presentViewController:twitterPostVC animated:YES completion:nil];
}

@end
