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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

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


- (IBAction)switchToContentPlayerView
{
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToContentPlayerView];
}

@end
