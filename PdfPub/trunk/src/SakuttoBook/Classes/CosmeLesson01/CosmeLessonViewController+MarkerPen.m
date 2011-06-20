//
//  CosmeLessonViewController+MarkerPen.m
//  CosmeLesson01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CosmeLessonViewController.h"


@implementation CosmeLessonViewController (MarkerPen)

//MARK: -
//MARK: Treat marker marker pen.
- (void)setupMarkerPenView:(CGRect)imageRect
{
	//Generate markerPenView.
	markerPenView = [[MarkerPenView alloc] initWithFrame:imageRect];
	//NSLog(@"markerPenView has %d recognizers", [[markerPenView gestureRecognizers] count]);
	[markerPenView clearLine];
	
	/*
	 //Add gesture to markerPenView.(drag for add line.)
	 panRecognizer21 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	 panRecognizer21.enabled = YES;
	 [markerPenView addGestureRecognizer:panRecognizer21];
	 NSLog(@"markerPenView has %d recognizers", [[markerPenView gestureRecognizers] count]);
	 for (id obj in [markerPenView gestureRecognizers]) {
	 NSLog(@"class=%@", [obj class]);
	 UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
	 NSLog(@"enabled=%d", r.enabled);
	 }
	 */
	
	//Set default line color, width with index 0.
	NSDictionary* tmpDict = [colorWidthInfoDS getColorWidthInfoAtIndex:0];
	currentLineColor_R = [[tmpDict objectForKey:MARKERPEN_COLOR_R] floatValue];
	currentLineColor_G = [[tmpDict objectForKey:MARKERPEN_COLOR_G] floatValue];
	currentLineColor_B = [[tmpDict objectForKey:MARKERPEN_COLOR_B] floatValue];
	currentLineColor_Alpha = [[tmpDict objectForKey:MARKERPEN_COLOR_ALPHA] floatValue];
	currentLineWidth = [[tmpDict objectForKey:MARKERPEN_WIDTH] floatValue];
}

- (void)setupMarkerPenMenu
{
	//LOG_CURRENT_METHOD;
	//MenuBar.
	CGFloat menuBarHeight = 44.0f;
    if (! menuBarForMakerPen) {
        menuBarForMakerPen = [[UIToolbar alloc] initWithFrame:CGRectZero];
		
		//Add Done button.
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
									   target:self 
									   action:@selector(exitMarkerMode)];
		//Add Delete button.
		UIImage* deleteButtonImage = [UIImage imageNamed:@"recycle32.png"];
		if (! deleteButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}
		UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]
										 initWithImage:deleteButtonImage
										 style:UIBarButtonItemStylePlain
										 target:self
										 action:@selector(prepareDeleteMarkerPenWithCurrentPage)];
		//Add undo button.
		UIImage* undoButtonImage = [UIImage imageNamed:@"undo_selected.png"];
		if (! undoButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}
		UIBarButtonItem* undoButton = [[UIBarButtonItem alloc]
									   initWithImage:undoButtonImage
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(deleteLastLine:)];
		//Add Color&Width select button.
		UIImage* colorWidthSelectButtonImage = [UIImage imageNamed:@"wand32.png"];
		if (! colorWidthSelectButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}
		UIBarButtonItem* colorWidthSelectButton = [[UIBarButtonItem alloc]
										 initWithImage:colorWidthSelectButtonImage
										 style:UIBarButtonItemStylePlain
										 target:self
										 action:@selector(showColorAndSizeSelector)];
		
		//Add title label.
		NSString* titleStr = @"";
		CGSize labelSize = [titleStr sizeWithFont:[UIFont boldSystemFontOfSize:24]];
		UIBarButtonItem* titleLabelButton = [UIBarButtonItem alloc];
		[titleLabelButton initWithTitle:titleStr
								  style:UIBarButtonItemStylePlain
								 target:nil
								 action:nil];
		[titleLabelButton setWidth:165.0f];
		[titleLabelButton setWidth:labelSize.width];
		
		//Add FlexibleSpace.
		UIBarButtonItem *fspace1 = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									target:nil
									action:nil];
		UIBarButtonItem *fspace2 = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									target:nil
									action:nil];
		UIBarButtonItem *fspace3 = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									target:nil
									action:nil];
		fspace3.width = 5.0f;
		
		[menuBarForMakerPen setItems:[NSArray arrayWithObjects:doneButton, fspace1, titleLabelButton, fspace2, colorWidthSelectButton, fspace2, fspace3, undoButton, deleteButton, nil]];
		[self.view addSubview:menuBarForMakerPen];
	}
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (interfaceOrientation == UIInterfaceOrientationPortrait
		||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect rect = CGRectMake(0.0f,
                                 0.0f,	//self.view.frame.size.height - menuBarHeight, 
                                 self.view.frame.size.width,
                                 menuBarHeight);
		menuBarForMakerPen.frame = rect;
	} else {
		CGRect rect = menuBarForMakerPen.frame;
		rect.size.width = self.view.frame.size.height;
		rect.origin.y = 0.0f;	//self.view.frame.size.width - menuBarHeight;
		menuBarForMakerPen.frame = rect;
	}
	[menuBarForMakerPen setNeedsDisplay];
}

- (void)enterMarkerMode
{
	//LOG_CURRENT_METHOD;
    //Hide original menu.
    //[self hideMenuBar];
    
    //Show markerPen view.
    //[self.view bringSubviewToFront:markerPenView];
	
	//Show menu bar, label for MakerPen.
	[self setupMarkerPenMenu];
    [self showMenuBarForMarker];
    
    //Enable touch with view for maker.
    markerPenView.userInteractionEnabled = YES;
	scrollView.userInteractionEnabled = NO;
    
	panRecognizer1.enabled = YES;
	
	//Set Flag.
	isMarkerPenMode = YES;
}
- (void)exitMarkerMode
{
	//LOG_CURRENT_METHOD;
    //Hide menu bar for marker pen.
    if (menuBarForMakerPen != nil) {
        //menuBarForMakerPen.hidden = YES;
		[self hideMenuBarForMarker];
    }
	
	/*
	 //Disable gesture for add line.
	 panRecognizer21.enabled = NO;
	 */
	panRecognizer1.enabled = NO;
	
    //Disable touch with view for maker.
    markerPenView.userInteractionEnabled = NO;
	scrollView.userInteractionEnabled = YES;
	
	//Set Flag.
	isMarkerPenMode = NO;
}

#pragma mark - Pan Gesture.
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    //LOG_CURRENT_METHOD;
    //
	
    if (! markerPenArray) {
        markerPenArray = [[NSMutableArray alloc] init];
    }
    if (! pointsForSingleLine) {
        pointsForSingleLine = [[NSMutableArray alloc] init];
    }
    
    CGPoint touchedPoint;
	//LOG_CURRENT_METHOD;
	if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        //NSLog(@"Possible");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan Began");
		
		//Setup line info on markerPenView.
		[markerPenView willStartAddLineWithRed:currentLineColor_R
										 Green:currentLineColor_G
										  Blue:currentLineColor_B
										 Alpha:currentLineColor_Alpha
										  Size:currentLineWidth];
		
		//Create new array.
        pointsForSingleLine = [[NSMutableArray alloc] init];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Changed");
        touchedPoint = [gestureRecognizer locationInView:markerPenView];
		
		//Add line info on markerPenView.
		[markerPenView addLineWithPoint:touchedPoint];
		[markerPenView setNeedsDisplay];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan Ended");
        
        touchedPoint = [gestureRecognizer locationInView:markerPenView];
		
		//Add line info on markerPenView.
		[markerPenView addLineWithPoint:touchedPoint];
		[markerPenView didEndAddLine];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
		//Generate dictionary for add array.
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:currentPageNum]
				   forKey:MARKERPEN_PAGE_NUMBER];
		[tmpDict setValue:@"" forKey:MARKERPEN_COMMENT];
		[tmpDict setValue:pointsForSingleLine forKey:MARKERPEN_POINT_ARRAY];
		[tmpDict setValue:[NSNumber numberWithFloat:currentLineColor_R]
				   forKey:MARKERPEN_COLOR_R];
		[tmpDict setValue:[NSNumber numberWithFloat:currentLineColor_G]
				   forKey:MARKERPEN_COLOR_G];
		[tmpDict setValue:[NSNumber numberWithFloat:currentLineColor_B]
				   forKey:MARKERPEN_COLOR_B];
		[tmpDict setValue:[NSNumber numberWithFloat:currentLineColor_Alpha]
				   forKey:MARKERPEN_COLOR_ALPHA];
		[tmpDict setValue:[NSNumber numberWithFloat:currentLineWidth]
				   forKey:MARKERPEN_WIDTH];
		[markerPenArray addObject:tmpDict];
		
        //Save to UserDefault.
        [self saveMarkerPenToUserDefault];
		
        //Refresh marker view.
        [self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"pan gesture Cancelled");
	} else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"pan gesture Failed");
    }
}

#pragma mark - menubar.
- (void)showMenuBarForMarker {
	//LOG_CURRENT_METHOD;
	menuBarForMakerPen.hidden = NO;
	[self.view bringSubviewToFront:menuBarForMakerPen];
}
- (void)hideMenuBarForMarker {
	//LOG_CURRENT_METHOD;
 	menuBarForMakerPen.hidden = YES;
}

#pragma mark - show/hide Color and Width Selector.
- (void)showColorAndSizeSelector
{
	//Generate view for add.
	if (colorSelectorView == nil) {
		colorSelectorView = [[UIView alloc] initWithFrame:self.view.frame];
	}
	if (colorSelectorToolbar == nil) {
		colorSelectorToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
		//NSLog(@"colorSelectorToolbar frame=%@", NSStringFromCGRect(colorSelectorToolbar.frame));
		UIBarItem* cancelButton;
		cancelButton = [[UIBarButtonItem alloc]
						initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
						target:self
						action:@selector(hideColorAndSizeSelector)];
		NSArray* items = [NSArray arrayWithObjects:cancelButton, nil];
		[colorSelectorToolbar setItems:items];
	}
	[colorSelectorView addSubview:colorSelectorToolbar];
	
	//Generate TableView.
	if (colorSelectorTVC == nil) {
		colorSelectorTVC = [[ColorSelectorTableViewController alloc] init];
		[colorSelectorTVC.tableView setDataSource:colorWidthInfoDS];
	}
	colorSelectorTVC.parentViewController = self;
	
	CGRect frame = CGRectMake(0,
							  colorSelectorToolbar.frame.size.height,
							  self.view.frame.size.width,
							  self.view.frame.size.height - colorSelectorToolbar.frame.size.height);
	//NSLog(@"colorSelectorTVC.view.frame = %@", NSStringFromCGRect(frame));
	colorSelectorTVC.view.frame = frame;
	[colorSelectorView addSubview:colorSelectorTVC.view];
	
	//Show view.
	[self.view addSubview:colorSelectorView];
}
- (void)hideColorAndSizeSelector
{
	[colorSelectorView removeFromSuperview];
}
#pragma mark - Color and Width.
- (void)setLineColorAndWidthWithIndex:(NSInteger)index
{
	LOG_CURRENT_METHOD;
	if (colorSelectorTVC == nil) {
		colorSelectorTVC = [[ColorSelectorTableViewController alloc] init];
		//NSLog(@"colorWidthInfoDS count=%d", [colorWidthInfoDS count]);
		[colorSelectorTVC.tableView setDataSource:colorWidthInfoDS];
	}
	NSDictionary* tmpDict = [[NSDictionary alloc] initWithDictionary:[colorWidthInfoDS getColorWidthInfoAtIndex:index]];
	NSLog(@"tmpDict=%@", [tmpDict description]);
	
	//Color
	[self setLineColor:tmpDict];
	
	//Width
	CGFloat width	= [[tmpDict valueForKey:MARKERPEN_WIDTH] floatValue];
	[self setLineWidth:width];
}
- (void)setLineColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	//NSLog(@"line color=%4.2f,%4.2f,%4.2f alpha=%4.2f", red, green, blue, alpha);
 	currentLineColor_R = red;
	currentLineColor_G = green;
	currentLineColor_B = blue;
	currentLineColor_Alpha = alpha;
	//NSLog(@"line color=%4.2f,%4.2f,%4.2f alpha=%4.2f", currentLineColor_R, currentLineColor_G, currentLineColor_B, currentLineColor_Alpha);
}
- (void)setLineColor:(NSDictionary*)colorDict
{
	currentLineColor_R = [[colorDict valueForKey:MARKERPEN_COLOR_R] floatValue];
	currentLineColor_G = [[colorDict valueForKey:MARKERPEN_COLOR_G] floatValue];
	currentLineColor_B = [[colorDict valueForKey:MARKERPEN_COLOR_B] floatValue];
	currentLineColor_Alpha = [[colorDict valueForKey:MARKERPEN_COLOR_ALPHA] floatValue];
	NSLog(@"line color=%4.2f,%4.2f,%4.2f alpha=%4.2f", currentLineColor_R, currentLineColor_G, currentLineColor_B, currentLineColor_Alpha);
}
- (void)setLineWidth:(CGFloat)width
{
	currentLineWidth = width;
}

#pragma mark - save/load
- (void)saveMarkerPenToUserDefault
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"before save: markerPenArray=%@", [markerPenArray description]);
	
	if (! markerPenArray) {
		return;
	}
	
	//Store marker pen infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:markerPenArray forKey:MARKERPEN_ARRAY];
}

- (NSArray*)loadMarkerWithCurrentPage
{
	//LOG_CURRENT_METHOD;
    //load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:MARKERPEN_ARRAY];
	if (!obj) {		//no markerpen exists.
        NSLog(@"no markerpen infomation in UserDefault.");
		return nil;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal marker pen infomation. class=%@", [obj class]);
		return NO;
	}
    
	//Pickup only line in this page.
	NSMutableArray* resultArray =[[NSMutableArray alloc] init];
	//Add line info from UserDefault to markerPenView.
	for (NSMutableDictionary* markerInfo in obj) {
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == currentPageNum) {
			[resultArray addObject:markerInfo];
		}
	}
	//NSLog(@"%d object in page %d", [resultArray count], currentPageNum);
	
    return resultArray;
}

- (void)loadMarkerPenFromUserDefault
{
	//LOG_CURRENT_METHOD;
	if (! markerPenArray) {
		markerPenArray = [[NSMutableArray alloc] init];
	}
	
	//load from UserDefault.
    NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	
	id obj = [settings valueForKey:MARKERPEN_ARRAY];
	if (!obj) {		//no markerpen exists.
        NSLog(@"no markerpen infomation in UserDefault.");
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal marker pen infomation. class=%@", [obj class]);
		return;
	}
	
	[markerPenArray addObjectsFromArray:obj];
	
	//NSLog(@"loaded. markerPenArray=%@", [markerPenArray description]);
}

- (void)renderMarkerPenFromUserDefaultAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"markerPenView has %d recognizers", [[markerPenView gestureRecognizers] count]);
	for (id obj in [markerPenView gestureRecognizers]) {
		UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
		NSLog(@"enabled=%d", r.enabled);
	}
	
    //has been Readed marker pen infomation.
	if (! markerPenArray) {
		LOG_CURRENT_LINE;
		NSLog(@"markerPenArray not initialized.(no marker pen info at page %d.)", pageNum);
		return;
	}
	
	//
	[markerPenView clearLine];
	
	//Add line info from UserDefault to markerPenView.
    for (id obj in markerPenArray) {
		if (!obj) {
			continue;
		}
		if (! [obj isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Illigal markerPenArray.");
			continue;
		}
		
		NSMutableDictionary* markerInfo = [[NSMutableDictionary alloc] initWithDictionary:obj];
		
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == pageNum) {
			[markerPenView addLinesWithDictionary:markerInfo];
		}
    }
	
	//Draw line dragging.(use nowDraggingLine).
	
	//
	//CGRect rect = self.view.frame;
	CGRect rect = markerPenView.frame;
	NSLog(@"add Scalable Subview: frame=%@", NSStringFromCGRect(rect));
	[self addScalableSubview:markerPenView withNormalizedFrame:rect];
	[markerPenView setNeedsDisplay];
}

#pragma mark - delete marker.
- (void)prepareDeleteMarkerPenWithCurrentPage
{
	//Show ActionSheet
	UIActionSheet *sheet;
	sheet = [[[UIActionSheet alloc]
			  initWithTitle:@"ページ内のマーカーを削除しますか？"
			  delegate: self 
			  cancelButtonTitle: NSLocalizedString(@"Cancel", nil) 
			  destructiveButtonTitle: nil
			  otherButtonTitles:NSLocalizedString(@"削除する", nil), NSLocalizedString(@"キャンセル", nil), nil]
			 autorelease];
	[sheet showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)index
{
	//NSLog(@"action sheet: index=%d", index);
    if( index == [sheet cancelButtonIndex])
    {
        // Do Nothing
    }
    else if( index == [sheet destructiveButtonIndex] )
    {
        // Do Nothing
    }
    else if(index == 0) {
        // Delete line in current page.
		[self deleteMarkerPenAtPage:currentPageNum];
		[self saveMarkerPenToUserDefault];
		[self renderMarkerPenFromUserDefaultAtPage:currentPageNum];
    }
}

- (void)deleteMarkerPenAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"pageNum=%d", pageNum);
	
	if (! markerPenArray) {
		LOG_CURRENT_LINE;
		NSLog(@"markerPenArray not initialized.(no marker pen info at page %d.)", pageNum);
		return;
	}
	
	//Delete line info.
	for (id obj in [markerPenArray reverseObjectEnumerator]) {
		if (!obj) {
			continue;
		}
		if (! [obj isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Illigal markerPenArray.");
			continue;
		}
		
		NSMutableDictionary* markerInfo = [[NSMutableDictionary alloc] initWithDictionary:obj];
		
		int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
		if (targetPageNum == pageNum) {
			[markerPenArray removeObject:obj];
		}
    }
	//NSLog(@"after  line number=%d", [markerPenArray count]);
}


/*
 - (void)setupMarkerPenViewAtPage:(NSUInteger)pageNum
 {
 //LOG_CURRENT_METHOD;
 //NSLog(@"markerPenArray=%@", [markerPenArray description]);
 
 
 //[markerPenView clearLine];
 
 //Add line info from UserDefault to markerPenView.
 for (id obj in markerPenArray) {
 if (!obj) {
 continue;
 }
 if (! [obj isKindOfClass:[NSDictionary class]]) {
 NSLog(@"Illigal markerPenArray.");
 continue;
 }
 
 NSMutableDictionary* markerInfo = [[NSMutableDictionary alloc] initWithDictionary:obj];
 
 int targetPageNum = [[markerInfo valueForKey:MARKERPEN_PAGE_NUMBER] intValue];
 if (targetPageNum == pageNum) {
 //[markerPenView addLinesWithDictionary:markerInfo];
 }
 }
 }
 */


- (void)clearMarkerPenView 
{
	[markerPenView clearLine];
	[markerPenView setNeedsDisplay];
}

- (IBAction)deleteLastLine:(id)sender
{
	if (0 <	[markerPenArray count]) {
		[markerPenArray removeLastObject];
	}
	[markerPenView deleteLastLine];
	[markerPenView setNeedsDisplay];
}


@end
