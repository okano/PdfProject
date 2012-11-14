//
//  Page2.m
//  Hello World
//
//  Created by Alex Muller on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Page2.h"

@implementation Page2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction)samePage {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"You Are Already In View 2!" 
                                                       delegate:self
                                              cancelButtonTitle:@"Ok" 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (IBAction)helloWorld {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Heya!" 
                                                    message:@"This is Hello from View 2"  
                                                   delegate:self 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil];
    [alert show];
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
