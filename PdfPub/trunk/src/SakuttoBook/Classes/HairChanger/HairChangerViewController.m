//
//  HairChangerViewController.m
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HairChangerViewController.h"

@interface HairChangerViewController ()

@end

@implementation HairChangerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		currentHairNumber = 0;
		currentSceneNumber = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	buttonContainerView.backgroundColor = [UIColor clearColor];
	//hairImageView.backgroundColor = [UIColor blueColor];
	hairContainerView.backgroundColor = [UIColor clearColor];
	//faceImageView.backgroundColor = [UIColor yellowColor];
	
	/*
	NSString* faceImageFilename = [self getSceneFilename:currentSceneNumber];
	UIImage* faceImage = [UIImage imageNamed:faceImageFilename];
	if (faceImage == nil) {
		NSLog(@"file not found. filename=%@", faceImageFilename);
	}
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.imageForLessonBook = faceImage;
	 */
	
	//Setup Gesture Recognizer.(pinch in/out)
	hairImageView.userInteractionEnabled = YES;
	hairImageView.multipleTouchEnabled = YES;
	pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[hairContainerView addGestureRecognizer:pinchRecognizer];
	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[hairContainerView addGestureRecognizer:panRecognizer];
}

#pragma mark - setup View.
- (void)viewWillAppear:(BOOL)animated
{
	//LOG_CURRENT_METHOD;
	
	[self setupViewsWithDefault];
}

- (void)setupViewsWithDefault
{
	//LOG_CURRENT_METHOD;
	
	//Setup hair view.
	[self setupWithHairNumber:currentHairNumber];
	
}

- (void)setupWithHairNumber:(int)hairNumber
{
	NSString* foreSceneImageFilename = [self getHairFilename:hairNumber];
	UIImage* foreSceneImage = [UIImage imageNamed:foreSceneImageFilename];
	if (foreSceneImage == nil) {
		NSLog(@"file not found. filename=%@", foreSceneImageFilename);
	}
	hairImageView.image = foreSceneImage;
}



//Utility method.
- (NSString*)getHairFilename:(int)hairNumber
{
	return [NSString stringWithFormat:@"w%02d.png", hairNumber];
}
- (NSString*)getSceneFilename:(int)sceneNumber
{
	return [NSString stringWithFormat:@"b%02d.jpg", sceneNumber];
}


#pragma mark -

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Handle Gesture.
//scale big/small with image.
//@see: http://paulsolt.com/2011/03/limiting-uipinchgesturerecognizer-zoom-levels/
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
	if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		// Reset the last scale, necessary if there are multiple objects with different scales
		lastScale = [gestureRecognizer scale];
	}
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
		[gestureRecognizer state] == UIGestureRecognizerStateChanged) {
		
		CGFloat currentScale = [[hairImageView.layer valueForKeyPath:@"transform.scale"] floatValue];
		
		// Constants to adjust the max/min values of zoom
		const CGFloat kMaxScale = 1.00f;
		const CGFloat kMinScale = 0.60f;
		
		CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]); // new scale is in the range (0-1)
		newScale = MIN(newScale, kMaxScale / currentScale);
		newScale = MAX(newScale, kMinScale / currentScale);
		CGAffineTransform transform = CGAffineTransformScale([hairImageView transform], newScale, newScale);
		hairImageView.transform = transform;
		
		lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
	}
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
		lastOrigin = hairImageView.frame.origin;
		/*
		 LOG_CURRENT_METHOD;
		 NSLog(@"currentScale=%3.2f, lastScale=%3.2f, lastOrign = %@",
		 [[hairImageView.layer valueForKeyPath:@"transform.scale"] floatValue],
		 lastScale,
		 NSStringFromCGPoint(lastOrigin));
		 */
	}
}
//move image.
- (void)handlePan:(UIPanGestureRecognizer*)sender
{
	//LOG_CURRENT_METHOD;
	
	//Get position.
	UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)sender;  
	CGPoint location = [pan translationInView:self.view];
	//NSLog(@"pan x=%f, y=%f", location.x, location.y);
	
	CGRect frame = CGRectMake(lastOrigin.x + location.x,
							  lastOrigin.y + location.y,
							  hairImageView.frame.size.width,
							  hairImageView.frame.size.height);
	hairImageView.frame = frame;
	
	switch (pan.state) {
		case UIGestureRecognizerStateBegan:
			lastOrigin = CGPointMake(hairImageView.frame.origin.x,
									 hairImageView.frame.origin.y);
			break;
			
		case UIGestureRecognizerStateEnded:
			lastOrigin = CGPointMake(hairImageView.frame.origin.x,
									 hairImageView.frame.origin.y);
			//Check out of screen.
			CGRect interSection = CGRectIntersection(hairContainerView.frame, hairImageView.frame);
			if(CGRectIsNull(interSection)){
				//NSLog(@"out of rect. hairContainerView=%@, hairImageView=%@",
				//	  NSStringFromCGRect(hairContainerView.frame),
				//	  NSStringFromCGRect(hairImageView.frame));
				//NSLog(@"interSection=%@", NSStringFromCGRect(interSection));
				CGFloat newX = hairImageView.frame.origin.x;
				CGFloat newY = hairImageView.frame.origin.y;
				CGFloat merginX = 40.0f;
				CGFloat merginY = 40.0f;
				if (hairImageView.frame.origin.x - hairContainerView.frame.origin.x < -320) {
					newX = -320 + merginX;
				}
				if (320 < hairImageView.frame.origin.x - hairContainerView.frame.origin.x) {
					newX = 320 - merginX;
				}
				if (hairImageView.frame.origin.y - hairContainerView.frame.origin.y < -480) {
					newY = -480 + merginY;
				}
				if (480 < hairImageView.frame.origin.y - hairContainerView.frame.origin.y) {
					newY = 480 - merginY;
				}
				hairImageView.frame = CGRectMake(newX, 
												   newY, 
												   hairImageView.frame.size.width,
												   hairImageView.frame.size.height);
				lastOrigin = CGPointMake(newX, newY);
				//NSLog(@"new origin = %@", NSStringFromCGPoint(lastOrigin));
			}
			break;
			
		default:
			break;
	}
}



#pragma mark -
- (IBAction)showImageSelectorSheet
{
	//Check Camera available.
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		//show picture selector directory.
		[self openImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
	} else {
		//show select sheet.
		UIActionSheet*  sheet;
		sheet = [[[UIActionSheet alloc] 
				  initWithTitle:@"Select Soruce Type" 
				  delegate:self 
				  cancelButtonTitle:@"Cancel" 
				  destructiveButtonTitle:nil 
				  otherButtonTitles:@"カメラで撮影", @"アルバムから選択", nil]
				 autorelease];
		
		[sheet showInView:self.view];
	}
}


- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}

	switch (buttonIndex)
	{
		case 0:
			[self openImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
			break;
			
		case 1:
		default:
			[self openImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
    }
}






#pragma mark -
#pragma mark -
//@see: http://kinsentansa.blogspot.com/2010/04/iphone2.html
- (IBAction)saveImageToAlbum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"save start.");
	
	//Hide button.
	buttonContainerView.hidden = YES;
	
	//Get image from screen.
	CGRect rect = [[UIScreen mainScreen] bounds];  
	UIGraphicsBeginImageContext(rect.size);
	UIApplication *app = [UIApplication sharedApplication];  
	
	[app.keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];  
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();  
	UIGraphicsEndImageContext();
	
	//Save to PhotoAlbum.
	UIImageWriteToSavedPhotosAlbum(img,
								   self,
								   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), 
								   nil);
}



// called when save finished.
- (void) savingImageIsFinished:(UIImage *)_image
	  didFinishSavingWithError:(NSError *)_error
				   contextInfo:(void *)_contextInfo
{
	//Show button.
	buttonContainerView.hidden = NO;
	
	//NSLog(@"save finished");
	//NSString* message = @"The image are saved in album.";
	NSString* message = @"画像をアルバムに保存しました";
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:nil
						  message:message
						  delegate:nil
						  cancelButtonTitle:nil
						  otherButtonTitles:@"OK", nil
						  ];
	[alert show];
}


#pragma mark -
- (IBAction)switchHairNext
{
	currentHairNumber = currentHairNumber + 1;
	if (MAX_HAIR <= currentHairNumber) {
		currentHairNumber = 0;
	}
	[self switchHairAtIndex:currentHairNumber];
}
- (void)switchHairAtIndex:(int)index
{
	[self setupWithHairNumber:currentHairNumber];
}




#pragma mark - View change.
- (IBAction)switchToContentPlayerView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToContentPlayerView];
}

- (void)hideHairChangerView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate hideHairChangerView];
}
- (void)switchToHairChangerView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToCosmeLessonView];
}


@end
