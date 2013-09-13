//
//  ViewController.m
//  socialFramework-2
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

- (IBAction)showActivityVC:(id)sender
{
    NSLog(@"line %d", __LINE__);
    
    NSArray* actItems = [NSArray arrayWithObjects:@"hello", nil];
    UIActivityViewController *activityView = [[UIActivityViewController alloc]
                                              initWithActivityItems:actItems
                                              applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:^{}];
}

@end
