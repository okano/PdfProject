//
//  ServerContentListImageVC.h
//  SakuttoBook
//
//  Created by okano on 13/01/28.
//
//

#import <UIKit/UIKit.h>
//#import "ServerContentListVC.h"
#import "ContentListImageViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface ServerContentListImageVC : ContentListImageViewController {
	//IBOutlet UIBarButtonItem *localContentButton;
	//IBOutlet UIBarButtonItem *reloadButton;
	
	//to check with NetworkReachable.
	//@see:Apple sample "Reachability - Apple Developer"
	Reachability* internetReachable;
    Reachability* hostReachable;
	Reachability* wifiReachable;
	BOOL status3G;
	BOOL statusWifi;
	BOOL internetActive;
}
//Setup data.
//- (void)setupData;
- (IBAction)reloadFromNetwork:(id)sender;

//Switch view.
- (IBAction)showContentList:(id)sender;
- (void)showServerContentDetailView:(NSString*)uuid;

//Network Reachability.
- (void)reachabilityChanged:(NSNotification*)note;
- (void)updateInterfaceWithReachability:(Reachability*)curReach;

@end
