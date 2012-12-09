//
//  MyListViewController.m
//  TabTestIos6-01
//
//  Created by okano on 12/12/09.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import "MyTabListViewController.h"

@interface MyTabListViewController ()

@end

@implementation MyTabListViewController
@synthesize myListVC1, myListVC2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		myListVC1 = [[MyListVC alloc]initWithNibName:@"MyListVC" bundle:[NSBundle mainBundle]];
		[myListVC1 setWithTabKind:1];
		myListVC2 = [[MyListVC alloc]initWithNibName:@"MyListVC" bundle:[NSBundle mainBundle]];
		[myListVC2 setWithTabKind:2];
		
		//Setting TabBar.
		tabBarController = [[UITabBarController alloc]init];
		tabBarController.viewControllers =[NSArray arrayWithObjects:myListVC1, myListVC2, nil];
		
		NSLog(@"original tabBarController.view.frame=%@", NSStringFromCGRect(tabBarController.view.frame));
		
		CGRect rect = self.view.frame;
		float tabBarHeight = 49.0;
		float statusBarHeight = 20.0;
		//rect.size.height = rect.size.height - tabBarHeight - statusBarHeight;
		//rect.size.height = rect.size.height - statusBarHeight;
		[tabBarController.view setFrame:rect];
		NSLog(@"new tabBarController.view.frame=%@", NSStringFromCGRect(tabBarController.view.frame));
		  
		  
		
		//Show TabBar.
		[self.view addSubview:tabBarController.view];
		
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	NSLog(@"view frame size=%@ in MyTabListViewController.m", NSStringFromCGRect(self.view.frame));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
