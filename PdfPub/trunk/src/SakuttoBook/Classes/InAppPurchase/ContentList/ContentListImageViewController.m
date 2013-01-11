//
//  ContentListImageViewController.m
//  SakuttoBook
//
//  Created by okano on 13/01/10.
//
//

#import "ContentListImageViewController.h"

@interface ContentListImageViewController ()

@end

@implementation ContentListImageViewController


#pragma mark - View lifecycle
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
	
	//Fit view size with screen. (iPhone-3.5inch/iPhone-4inch/iPad/iPad-Retina)
	self.view.frame = [[UIScreen mainScreen] bounds];
	
#if defined(HIDE_SERVER_BUTTON) && HIDE_SERVER_BUTTON != 0
	//Hide Server Button.
#define STORE_BUTTON_TAG 300
	serverContentButton.tag = STORE_BUTTON_TAG;
	NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolbar items]];
	for (UIBarButtonItem* item in [toolbarItems reverseObjectEnumerator]) {
		if (item.tag == STORE_BUTTON_TAG) {
			[toolbarItems removeObject:item];
		}
	}
	toolbar.items = toolbarItems;
#endif
	
	[self setupImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setupImages
{
	CGFloat maxWidth = self.view.frame.size.width;
	
	CGFloat currentOriginX = 0.0f, currentOriginY = 0.0f;
	CGFloat maxHeightInLine;
	//
	CGFloat spacerX = 4.0f, spacerY = 4.0f;
	
	currentOriginX += spacerX;
	currentOriginY += spacerY;
	
	//
	int maxCount = [appDelegate.contentListDS count];
	for (int i = 0; i < maxCount; i = i + 1)
	{
		ContentId targetCid = [appDelegate.contentListDS contentIdAtIndex:i];
		NSLog(@"contentCid=%d", targetCid);
		
		//Get cover image.
		UIImage* imageOriginal = nil;
		UIImage* image = nil;
		
		//(Get from coverUrl.)
		NSURL* coverImageUrl = [appDelegate.contentListDS coverUrlAtIndex:i];
		if (coverImageUrl == nil) {
			NSLog(@"cannot get coverUrl. targetCid=%d", targetCid);
			//(Get from thumbnailUrl.)
			coverImageUrl = [appDelegate.contentListDS thumbnailUrlAtIndex:i];
			if (coverImageUrl == nil) {
				NSLog(@"cannot get thumbnailUrl. targetCid=%d", targetCid);
			}
		}
		NSData *coverImageData = [NSData dataWithContentsOfURL:coverImageUrl];
		if (coverImageData == nil) {
			NSLog(@"coverImageData is nil. targetCid=%d", targetCid);
		}
		imageOriginal = [[UIImage alloc]  initWithData:coverImageData];
		if (imageOriginal == nil) {
			NSLog(@"error: no cover image. cid=%d", targetCid);
			//(Get from contentIcon.(included in project file) )
			imageOriginal = [appDelegate.contentListDS contentIconAtIndex:i];
			if (imageOriginal == nil) {
				NSLog(@"cannot get cover image with contentIcon. targetCid=%d", targetCid);
			}
		}
		
		//Resize cover image for fit in scroll view.
		NSUInteger imageInEachLine = 3;
		CGFloat newImageWidth = ((self.view.frame.size.width - spacerX) / imageInEachLine) - spacerX;
		CGFloat newImageHeight = imageOriginal.size.height * (newImageWidth / imageOriginal.size.width);
		UIGraphicsBeginImageContext(CGSizeMake(newImageWidth, newImageHeight));
		[imageOriginal drawInRect:CGRectMake(0, 0, newImageWidth, newImageHeight)];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		
		// Check width.
		if (maxWidth < image.size.width) {
			LOG_CURRENT_METHOD;
			LOG_CURRENT_LINE;
			NSLog(@"image is too huge width. width=%f", image.size.width);
			continue;	//skip to next object.
		}
		
		// Locate.
		CGRect rect = CGRectZero;
		rect.origin.x = currentOriginX;
		rect.origin.y = currentOriginY;
		rect.size = image.size;
		if (maxHeightInLine < rect.size.height) {
			maxHeightInLine = rect.size.height;
		}
		
		// Check locate. feed line.
		if (maxWidth < currentOriginX + image.size.width) {
			//feed line.
			currentOriginX = 0.0f + spacerX;
			currentOriginY += maxHeightInLine;
			currentOriginY += spacerY;
			maxHeightInLine = image.size.height;
			
			rect.origin.x = currentOriginX;
			rect.origin.y = currentOriginY;
		}
		// Positioning to next position.
		currentOriginX += rect.size.width;
		currentOriginX += spacerX;
		//NSLog(@"pageNum=%d, rect for button=%@", pageNum, NSStringFromCGRect(rect));
		
		// Add to subview.
		UIButton* button = [[UIButton alloc] init];
		[button setImage:image forState:UIControlStateNormal];
		button.frame = rect;
		button.tag = targetCid;
		[button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:button];
		
		// Set contentSize to scrollView.
		scrollView.contentSize = CGSizeMake(maxWidth, currentOriginY + maxHeightInLine);
	}
}

-(void)buttonEvent:(UIButton*)button
{
	//LOG_CURRENT_METHOD;
	
	ContentId targetCid = button.tag;
	NSLog(@"touch cover image. targetCid = %d", targetCid);
	
	[appDelegate hideContentListView];
	[appDelegate showContentPlayerView:targetCid];
}

@end
