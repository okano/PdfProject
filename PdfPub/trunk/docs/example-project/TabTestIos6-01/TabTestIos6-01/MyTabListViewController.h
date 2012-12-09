//
//  MyListViewController.h
//  TabTestIos6-01
//
//  Created by okano on 12/12/09.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyListVC.h"

@interface MyTabListViewController : UIViewController {
	UITabBarController* tabBarController;
	MyListVC* listVC1;
	MyListVC* listVC2;
}
@property (nonatomic, retain) MyListVC* myListVC1;
@property (nonatomic, retain) MyListVC* myListVC2;

@end
