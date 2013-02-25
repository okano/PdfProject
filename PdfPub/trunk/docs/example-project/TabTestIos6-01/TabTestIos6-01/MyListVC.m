//
//  MyListVC.m
//  TabTestIos6-01
//
//  Created by okano on 12/12/09.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import "MyListVC.h"

@interface MyListVC ()

@end

@implementation MyListVC
@synthesize label1;

- (void)setWithTabKind:(NSInteger)tabKind
{
	NSLog(@"setWithTabKind: tabKind=%d", tabKind);
	myTabKind = tabKind;
	
	UITabBarItem* tabBarItem = nil;

	switch (tabKind) {
		case 1:
			[self setTitle:@"title-1"];
			tabBarItem = [[UITabBarItem alloc]
						  initWithTitle:@"tabTitle1" image:nil tag:tabKind];
			[self setTabBarItem:tabBarItem];
			[label1 setText:@"this is view1 in tabBar."];
			break;
			
		case 2:
			[self setTitle:@"title-2"];
			tabBarItem = [[UITabBarItem alloc]
						  initWithTitle:@"tabTitle2" image:nil tag:tabKind];
			[self setTabBarItem:tabBarItem];
			[label1 setText:@"this is view2 in tabBar."];
			label1.text = @"view2";
			break;
			
		default:
			break;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	switch (myTabKind) {
		case 1:
			[label1 setText:@"this is tab1"];
			break;
			
		case 2:
			[label1 setText:@"this is tab2"];
			break;
			
		default:
			break;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
