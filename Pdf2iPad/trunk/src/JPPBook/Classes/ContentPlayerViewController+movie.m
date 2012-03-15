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
- (void)parseMovieDefine
{
	movieDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_MOVIE;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
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
		
		//Delay time. (optional)
		if (7 <= [tmpCsvArray count]) {
			NSString* tmpStrForDelayTime = [tmpCsvArray objectAtIndex:6];
			NSNumber* delayTimeNumber = [NSNumber numberWithFloat:[tmpStrForDelayTime floatValue]];
			NSLog(@"delay time for movie=%@(%f)", tmpStrForDelayTime, [delayTimeNumber floatValue]);
			[tmpDict setValue:delayTimeNumber forKey:MD_DELAY_TIME];
		}
		
		[movieDefine addObject:tmpDict];
		[tmpDict release]; tmpDict = nil;
	}
}

- (void) renderMovieLinkAtIndex:(NSUInteger)index
{
#if ! TARGET_IPHONE_SIMULATOR
	return;
#endif
	
	for (NSMutableDictionary* movieInfo in movieDefine) {
		int targetPageNum = [[movieInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect rect;
			rect.origin.x	= [[movieInfo valueForKey:MD_AREA_X] floatValue];
			rect.origin.y	= [[movieInfo valueForKey:MD_AREA_Y] floatValue];
			rect.size.width	= [[movieInfo valueForKey:MD_AREA_WIDTH] floatValue];
			rect.size.height= [[movieInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"rect for movie=%@", NSStringFromCGRect(rect));
			
			NSString* filename = [movieInfo valueForKey:MD_MOVIE_FILENAME];
			//NSLog(@"filename=%@", filename);
			
			UIColor* targetColor = [UIColor yellowColor];
			[currentPdfScrollView addScalableColorView:targetColor
												 alpha:0.2f
									 withPdfBasedFrame:rect];
			//play when open page with no touch.
			NSNumber* delayTime = [movieInfo valueForKey:MD_DELAY_TIME];
			if (delayTime != nil) {
				NSLog(@"delayTime=%f", [delayTime floatValue]);
				[self showMoviePlayer:filename WithFrame:rect];
			}
		}
	}
}

- (void)showMoviePlayer:(NSString*)filename
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	//NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	//if (!path) {
	//	NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", 
	//		  [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
	//		  [[NSBundle mainBundle] resourceURL]);
	//	NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
	//	return;
	//}
	
	NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
	NSString* path = [[ContentFileUtility getContentBodyMovieDirectoryWithContentId:cidStr]
					  stringByAppendingPathComponent:filename];
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
	//LOG_CURRENT_METHOD;
	//NSLog(@"filename=%@", filename);
	
	//NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	//if (!path) {
	//	NSLog(@"illigal filename. filename=%@, bundle_resourceURL=%@", 
	//		  [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
	//		  [[NSBundle mainBundle] resourceURL]);
	//	NSLog(@"f = %@ %@", [filename stringByDeletingPathExtension], [filename pathExtension]);
	//	return;
	//}
	//NSURL* url;
	
	NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
	NSString* path = [[ContentFileUtility getContentBodyMovieDirectoryWithContentId:cidStr]
					  stringByAppendingPathComponent:filename];
    mplayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    mplayer.scalingMode = MPMovieScalingModeNone;
	
    if([mplayer respondsToSelector:@selector(view)])
    {
		mplayer.repeatMode = NO;
		mplayer.endPlaybackTime = 0.0;
        mplayer.controlStyle = MPMovieControlStyleEmbedded;
		[mplayer.view setFrame:frame];
		mplayer.view.backgroundColor = [UIColor blackColor];
        
		//CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0f);
        //[player.view setTransform:transform];
		
        [currentPdfScrollView addScalableSubview2:mplayer.view withPdfBasedFrame:frame];
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
