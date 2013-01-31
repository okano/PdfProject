//
//  ServerContentListImageVC.m
//  SakuttoBook
//
//  Created by okano on 13/01/28.
//
//

#import "ServerContentListImageVC.h"

@interface ServerContentListImageVC ()

@end

@implementation ServerContentListImageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		//Setup network reachability.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:nil];
		status3G = YES;
		statusWifi = YES;
		internetActive = YES;
		internetReachable = [[Reachability reachabilityForInternetConnection] retain];
		[self updateInterfaceWithReachability:internetReachable];
		
		wifiReachable = [[Reachability reachabilityForLocalWiFi] retain];
		[self updateInterfaceWithReachability:wifiReachable];
		
		NSLog(@"internetEnable=%d, YES=%d, NO=%d", internetActive, YES, NO);
	}
    return self;
}
 
- (void)viewDidLoad
{
    //[super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
	self.view.frame = [[UIScreen mainScreen] bounds];
	
	appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate == nil) {
		NSLog(@"appDelegate is nil");
	}
	
	//Setup data.
	if (appDelegate.serverContentListDS == nil) {
		appDelegate.serverContentListDS = [[ServerContentListDS alloc] init];
		appDelegate.serverContentListDS.targetTableVC = nil;
	}

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		// Do something...
		[appDelegate.serverContentListDS loadContentList:32];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
	});
	
	//Get productIdList.
	[[ProductIdList sharedManager] refreshProductIdListFromNetwork];
	
	//Show cover image.
	[self setupImagesWithDataSource:appDelegate.serverContentListDS shelfImageName:@"shelf.png"];
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

#pragma mark - setup data.
- (IBAction)reloadFromNetwork:(id)sender
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		// Do something...
		//Get productIdList before get opds.
		[[ProductIdList sharedManager] refreshProductIdListFromNetwork];
		
		//Reload OPDS from network.
		[appDelegate.serverContentListDS removeAllObjects];
		[appDelegate.serverContentListDS loadContentListFromNetworkByOpds];

		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
	});
}

#pragma mark - show other view.
- (IBAction)showContentList:(id)sender
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showContentListView];
}
- (void)showServerContentDetailView:(NSString*)uuid
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d", cid);
	[appDelegate hideServerContentListView];
	[appDelegate showServerContentDetailView:uuid];
}

#pragma mark - handle push with cover image.
-(void)buttonEvent:(UIButton*)button
{
	ContentId targetCid = button.tag;
	LOG_CURRENT_METHOD;
	NSLog(@"touch cover image. targetCid = %d", targetCid);
	
	//Show detail view.
	NSString* targetUuid = [appDelegate.serverContentListDS uuidFromContentId:targetCid];
	[self showServerContentDetailView:targetUuid];
}



#pragma mark - Network reachability.
- (void)updateInterfaceWithReachability:(Reachability*)curReach
{
	//LOG_CURRENT_METHOD;
	NetworkStatus status = [curReach currentReachabilityStatus];
	
	if (curReach == hostReachable) {
		if (status == NotReachable) {
			NSLog(@"host failed");
			internetActive = NO;
		} else {
			NSLog(@"host success");
			internetActive = YES;
		}
	}
	
	if (curReach == internetReachable) {
		if (status == NotReachable) {
			NSLog(@"3G failed.");
			status3G = NO;
		} else {
			NSLog(@"3G success.");
			status3G = YES;
		}
	}
	
	if (curReach == wifiReachable) {
		if (status == NotReachable) {
			NSLog(@"Wi-Fi failed");
			statusWifi = NO;
		} else {
			NSLog(@"Wi-Fi success");
			statusWifi = YES;
		}
	}
	
	if ((status3G == NO) && (statusWifi == NO)) {
		internetActive = NO;
	} else {
		internetActive = YES;
	}
}

- (void)reachabilityChanged:(NSNotification*)note
{
	//LOG_CURRENT_METHOD;
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

@end
