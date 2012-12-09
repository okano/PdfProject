//
//  MyListVC.h
//  TabTestIos6-01
//
//  Created by okano on 12/12/09.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyListVC : UIViewController {
	IBOutlet UILabel* label1;
	NSInteger myTabKind;
}
@property (nonatomic, retain) UILabel* label1;

- (void)setWithTabKind:(NSInteger)tabKind;

@end
