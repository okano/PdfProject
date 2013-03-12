//
//  ContentPlayerViewController+markerPen.m
//  SakuttoBook
//
//  Created by okano on 13/03/12.
//
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (markerPen)



//MARK: -
//MARK: Treat marker marker pen.
- (void)setupMarkerPenView
{
	//Generate markerPenView-2.
	markerPenView2 = [[MarkerPenView alloc] initWithFrame:self.view.frame];
	//NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	[markerPenView2 clearLine];
	
	/*
	 //Add gesture to markerPenView.(drag for add line.)
	 panRecognizer21 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
	 panRecognizer21.enabled = YES;
	 [markerPenView2 addGestureRecognizer:panRecognizer21];
	 NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	 for (id obj in [markerPenView2 gestureRecognizers]) {
	 NSLog(@"class=%@", [obj class]);
	 UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
	 NSLog(@"enabled=%d", r.enabled);
	 }
	 */
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
		UIImage* deleteButtonImage = [UIImage imageNamed:@"icon_recycle.png"];
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
		UIImage* undoButtonImage = [UIImage imageNamed:@"icon_undo.png"];
		if (! undoButtonImage) {
			LOG_CURRENT_LINE;
			return;
		}
		UIBarButtonItem* undoButton = [[UIBarButtonItem alloc]
									   initWithImage:undoButtonImage
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(deleteLastLine:)];
		
		//Add title label.
		NSString* titleStr = @"Marker Mode";
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
		
		[menuBarForMakerPen setItems:[NSArray arrayWithObjects:doneButton, fspace1, titleLabelButton, fspace2, undoButton, deleteButton, nil]];
		[self.view addSubview:menuBarForMakerPen];
	}
	
	//Setup menu bar frame.
	/*
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
	 rect.size.width = self.view.frame.size.width;
	 rect.origin.y = 0.0f;	//self.view.frame.size.width - menuBarHeight;
	 menuBarForMakerPen.frame = rect;
	 }
	 */
	
	CGRect rect = CGRectMake(0.0f,
							 0.0f,
							 self.view.frame.size.width,
							 menuBarHeight);
	menuBarForMakerPen.frame = rect;
}

- (void)enterMarkerMode
{
	//LOG_CURRENT_METHOD;
    //Hide original menu.
    [self hideMenuBar];
    
    //Show markerPen view.
    //[self.view bringSubviewToFront:markerPenView];
	
	//Show menu bar, label for MakerPen.
	[self setupMarkerPenMenu];
    [self showMenuBarForMarker];
    
    //Enable touch with view for maker.
    markerPenView2.userInteractionEnabled = YES;
	currentPdfScrollView.userInteractionEnabled = NO;
    
	/*
	 //Enable gesture for add line.
	 panRecognizer21.enabled = YES;
	 NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	 for (id obj in [markerPenView2 gestureRecognizers]) {
	 NSLog(@"class=%@", [obj class]);
	 UIPanGestureRecognizer* r = (UIPanGestureRecognizer*)obj;
	 NSLog(@"enabled=%d", r.enabled);
	 }
	 */
	panRecognizer1.enabled = YES;
	panRecognizer2.enabled = YES;
	panRecognizer3.enabled = YES;
	
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
	panRecognizer2.enabled = NO;
	panRecognizer3.enabled = NO;
	
    //Disable touch with view for maker.
    markerPenView2.userInteractionEnabled = NO;
	currentPdfScrollView.userInteractionEnabled = YES;
	
	//Set Flag.
	isMarkerPenMode = NO;
}

- (void)handlePan2:(UIPanGestureRecognizer *)gestureRecognizer
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
		
		//Setup line info on markerPenView2.
		[markerPenView2 willStartAddLine];
		
		//Create new array.
        pointsForSingleLine = [[NSMutableArray alloc] init];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Changed");
        touchedPoint = [gestureRecognizer locationInView:markerPenView2];
		
		//Add line info on markerPenView2.
		[markerPenView2 addLineWithPoint:touchedPoint];
		[markerPenView2 setNeedsDisplay];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan Ended");
        
        touchedPoint = [gestureRecognizer locationInView:markerPenView2];
		
		//Add line info on markerPenView2.
		[markerPenView2 addLineWithPoint:touchedPoint];
		[markerPenView2 didEndAddLine];
		
		//Add Point into array.
		CGPoint p = [gestureRecognizer locationInView:markerPenView2];
        [pointsForSingleLine addObject:NSStringFromCGPoint(p)];
		
		//Generate dictionary for add array.
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:[NSNumber numberWithInt:currentPageNum] forKey:MARKERPEN_PAGE_NUMBER];
		[tmpDict setValue:@"" forKey:MARKERPEN_COMMENT];
		[tmpDict setValue:pointsForSingleLine forKey:MARKERPEN_POINT_ARRAY];
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

#pragma mark -
- (void)showMenuBarForMarker {
	//LOG_CURRENT_METHOD;
	menuBarForMakerPen.hidden = NO;
	[self.view bringSubviewToFront:menuBarForMakerPen];
}
- (void)hideMenuBarForMarker {
	//LOG_CURRENT_METHOD;
 	menuBarForMakerPen.hidden = YES;
}

#pragma mark -
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

#pragma mark -
- (void)renderMarkerPenFromUserDefaultAtPage:(NSUInteger)pageNum
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"markerPenView2 has %d recognizers", [[markerPenView2 gestureRecognizers] count]);
	for (id obj in [markerPenView2 gestureRecognizers]) {
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
	[markerPenView2 clearLine];
	
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
			[markerPenView2 addLinesWithDictionary:markerInfo];
		}
    }
	
	//Draw line dragging.(use nowDraggingLine).
	
	//
	CGRect rect = self.view.frame;
	//[currentPdfScrollView addScalableSubview:markerPenView2 withNormalizedFrame:rect];
	[currentPdfScrollView addScalableSubview:markerPenView2 withPdfBasedFrame:rect];

	[markerPenView2 setNeedsDisplay];
}

#pragma mark -
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
	
	if (maxPageNum < pageNum) {
		LOG_CURRENT_LINE;
		NSLog(@"illigal page number. pageNum=%d, maxPageNum=%d", pageNum, maxPageNum);
		return;
	}
	
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


- (IBAction)deleteLastLine:(id)sender
{
	if (0 <  [markerPenArray count]) {
		[markerPenArray removeLastObject];
	}
 	[markerPenView2 deleteLastLine];
	[markerPenView2 setNeedsDisplay];
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
	[markerPenView2 clearLine];
	[markerPenView2 setNeedsDisplay];
}


@end
