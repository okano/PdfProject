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
		currentPose = 0;
		currentScene = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	buttonContainerView.backgroundColor = [UIColor clearColor];
	//personImageView.backgroundColor = [UIColor blueColor];
	personContainerView.backgroundColor = [UIColor clearColor];
	sceneImageView.backgroundColor = [UIColor yellowColor];
}

#pragma mark - setup View.
- (void)viewWillAppear:(BOOL)animated
{
	//LOG_CURRENT_METHOD;
	
	[self setupSceneView:currentScene];
}

- (void)reScalePersonImageView
{
	//[self setupWithCharactorId:charactorId];
	//Setup default scale.
	lastScale = 2.0f;
	CGAffineTransform transform = CGAffineTransformScale([personImageView transform], lastScale, lastScale);
	personImageView.transform = transform;
	
}

- (void)setupSceneView:(int)sceneNumber
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"sceneNumber=%d", sceneNumber);
	NSString* foreSceneImageFilename = [self getHairFilename:sceneNumber];
	NSString* backSceneImageFilename = [self getSceneFilename:sceneNumber];
	
	UIImage* backSceneImage = [UIImage imageNamed:backSceneImageFilename];
	if (backSceneImage == nil) {
		NSLog(@"file not found. filename=%@", backSceneImageFilename);
	}
	sceneImageView.image = backSceneImage;
	
	UIImage* foreSceneImage = [UIImage imageNamed:foreSceneImageFilename];
	if (foreSceneImage == nil) {
		NSLog(@"file not found. filename=%@", foreSceneImageFilename);
	}
	personImageView.image = foreSceneImage;	
	
	//(for called directory.)
	currentScene = sceneNumber;
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
