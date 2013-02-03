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
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
	}
    return self;
}
*/

- (void)viewDidLoad
{
	myTableView = nil;	/* no table view. */
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
	self.view.frame = [[UIScreen mainScreen] bounds];
	
	//appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	//if (appDelegate == nil) {
	//	NSLog(@"appDelegate is nil");
	//}
	
	//Setup data.
	if (appDelegate.serverContentListDS == nil) {
		appDelegate.serverContentListDS = [[ServerContentListDS alloc] init];
		appDelegate.serverContentListDS.targetTableVC = self;	/* for do didFinishParseOpdsElement method. */
	}

	//Show empty self before load.
	[self setupImagesWithDataSource:nil shelfImageName:@"shelf.png"];
	
	[MBProgressHUD showHUDAddedTo:scrollView animated:YES];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		// Do something...
		[appDelegate.serverContentListDS loadContentList:32];
		
		//Show cover image after data load.
		[self setupImagesWithDataSource:appDelegate.serverContentListDS shelfImageName:@"shelf.png"];
		
		//Get productIdList.
		[[ProductIdList sharedManager] refreshProductIdListFromNetwork];
		
		//Show cover image with product id list.
		[self setupImagesWithDataSource:appDelegate.serverContentListDS shelfImageName:@"shelf.png"];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
	});
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

#pragma mark - MyTableViewVCProtocol (Accessor for table)
//didStartParseOpdsElement
//- (void)didFailParseOpdsElement{}
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray
{
	[self setupImagesWithDataSource:appDelegate.serverContentListDS shelfImageName:@"shelf_my.png"];
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

@end
