//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentPlayerViewController.h"
#import "InAppPurchaseDefine.h"

@interface SakuttoBookViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;

- (void)showContentPlayerView;

@end

@interface SakuttoBookViewController (InAppPurchase)
- (void)showContentListView;
- (void)hideContentListView;
- (void)showImagePlayerView:(ContentId)cid;
- (void)hideImagePlayerView;
- (void)showContentDetailView:(ContentId)cid;
- (void)hideContentDetailView;
@end
