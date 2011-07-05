//
//  Pdf2iPadViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (movie)

#pragma mark -
#pragma mark Treat Movie.
//Parse Movie Define.
- (BOOL)parseMovieDefine
{
	movieDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"movieDefine" ofType:@"csv"];
	NSError* error;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	NSString* text2 = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	
	bool hasError = FALSE;
	NSArray* lines = [text2 componentsSeparatedByString:@"\n"];
	for (NSString* line in lines) {
		if ([line length] <= 0) {
			continue;	//Skip blank line.
		}
		if ([line characterAtIndex:0] == '#'
			||
			[line characterAtIndex:0] == ';') {
			continue;	//Skip comment line.
		}
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_HEIGHT];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:5];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
		NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
		//NSString* tmpStrURLEncoded = [tmpStrWithoutDoubleQuote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//[tmpDict setValue:tmpStrURLEncoded forKey:MD_MOVIE_FILENAME];
		[tmpDict setValue:tmpStrWithoutLF forKey:MD_MOVIE_FILENAME];
		
		[movieDefine addObject:tmpDict];
	}
	//
	
	return ! hasError;
}

- (void) renderMovieLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* movieInfo in movieDefine) {
		int targetPageNum = [[movieInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			//NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			CGRect rect;
			rect.origin.x	= [[movieInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[movieInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[movieInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[movieInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"rect for movie=%@", NSStringFromCGRect(rect));
			
			CGRect touchableArea;
			//if (self.view.frame.size.width < originalPageRect.size.width) {
			if (self.view.frame.size.width < currentPdfScrollView.originalPageWidth) {
				touchableArea = CGRectMake(rect.origin.x / pdfScale,
										   rect.origin.y / pdfScale,
										   rect.size.width / pdfScale,
										   rect.size.height / pdfScale);
			} else {
				//Arrange frame if PDF.Width < Screen.Width
				touchableArea = CGRectMake(rect.origin.x * pdfScale,
										   rect.origin.y * pdfScale,
										   rect.size.width * pdfScale,
										   rect.size.height * pdfScale);
			}
			//NSLog(@"rect for movie arranged=%@", NSStringFromCGRect(touchableArea));
			//NSLog(@"pdfScale=%f", pdfScale);
			
			
			//Show Movie link area with half-opaque.
			//UIView* areaView = [[UIView alloc] initWithFrame:rect];
			UIView* areaView = [[UIView alloc] initWithFrame:touchableArea];
			
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor yellowColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			
			//[currentPdfScrollView addSubview:areaView];
			//[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:rect];
			[currentPdfScrollView addScalableSubview:areaView withNormalizedFrame:touchableArea];
		}
	}
}

- (void)showMoviePlayer:(NSString*)filename
{
	LOG_CURRENT_METHOD;
	NSLog(@"filename=%@", filename);
	
	NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	if (!path) {
		NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", 
			  [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
			  [[NSBundle mainBundle] resourceURL]);
		NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
		return;
	}
	NSURL* url;
	
	if ((url = [NSURL fileURLWithPath:path]) != nil) {
		MPMoviePlayerViewController* mpview;
		if ((mpview = [[MPMoviePlayerViewController alloc] initWithContentURL:url]) != nil) {
			[self presentMoviePlayerViewControllerAnimated:mpview];
			[mpview.moviePlayer play];
			[mpview release];
		}
	}
}

- (void)showMoviePlayer:(NSString*)filename WithFrame:(CGRect)frame
{
	LOG_CURRENT_METHOD;
	NSLog(@"filename=%@", filename);
	
	NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	if (!path) {
		NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", 
			  [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
			  [[NSBundle mainBundle] resourceURL]);
		NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
		return;
	}
	//NSURL* url;
	
	
    mplayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    mplayer.scalingMode = MPMovieScalingModeNone;
	
    if([mplayer respondsToSelector:@selector(view)])
    {
		mplayer.repeatMode = NO;
		mplayer.endPlaybackTime = 0.0;
        mplayer.controlStyle = MPMovieControlStyleEmbedded;
		CGRect newFrame = CGRectMake((frame.origin.x * pdfScale),
									 (frame.origin.y * pdfScale),
									 frame.size.width * pdfScale,
									 frame.size.height * pdfScale);
		[mplayer.view setFrame:frame];
		//CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0f);
        //[player.view setTransform:transform];
        mplayer.view.backgroundColor = [UIColor blackColor];
        [currentPdfScrollView addScalableSubview:mplayer.view withNormalizedFrame:newFrame];
        [mplayer prepareToPlay];
        [mplayer play];
    }
    else
    {
		mplayer.controlStyle = MPMovieControlStyleEmbedded;
		mplayer.backgroundView.backgroundColor = [UIColor clearColor];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(myMovieFinishedCallback:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:mplayer];
}
- (void)myMovieFinishedCallback:(id)sender
{
	LOG_CURRENT_METHOD;
	[currentPdfScrollView cleanupSubviews];
	[self renderAllLinks];
	
	if (mplayer != nil) {
		[mplayer release];
		mplayer = nil;
	}
}
@end
