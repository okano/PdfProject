//
//  ViewController.m
//  TabTestIos6-01
//
//  Created by okano on 12/12/09.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)pushButton1:(id)sender
{
	NSLog(@"button1 pushed");
	
	//
	MyTabListViewController* myListVC = [[MyTabListViewController alloc] initWithNibName:@"MyListViewController" bundle:[NSBundle mainBundle]];
	[self.view addSubview:myListVC.view];
	
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"view frame size=%@ in ViewController.m", NSStringFromCGRect(self.view.frame));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
