//
//  Hello_WorldViewController.m
//  Hello World
//
//  Created by Alex Muller on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Hello_WorldViewController.h"

@implementation Hello_WorldViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction)samePage {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"You Are Already In View 1!" 
                                                       delegate:self
                                              cancelButtonTitle:@"Ok" 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (IBAction)helloWorld {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Heya!" 
                                                    message:@"This is Hello from View 1"  
                                                   delegate:self 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
