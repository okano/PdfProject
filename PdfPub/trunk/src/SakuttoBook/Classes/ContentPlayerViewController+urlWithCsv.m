//
//  ContentPlayerViewController+urlWithCsv.m
//  SakuttoBook
//
//  Created by okano on 13/01/19.
//
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (urlWithCsv)

// Parse Url Link define in CSV.
- (void)parseUrlLinkWithCsvDefine
{
	urlDefineWithCsv = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_URLLINK;
	NSArray* lines;
	if ([self isMultiContents] == TRUE) {
		lines = [FileUtility parseDefineCsv:targetFilename contentId:currentContentId];
	} else {
		lines = [FileUtility parseDefineCsv:targetFilename];
	}
	
	//parse each line.
	NSMutableDictionary* tmpDict;
	for (NSString* line in lines) {
		NSArray* tmpCsvArray = [line componentsSeparatedByString:@","];
		if ([tmpCsvArray count] < 6) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		//Check page range.
		int candidatePageNumber = [NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]];
		if (maxPageNum < candidatePageNumber) {
			continue;	//skip to next object. not add to define.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_HEIGHT];
		//URL field.
		[tmpDict setValue:[tmpCsvArray objectAtIndex:5] forKey:ULWC_URL];
		
		//Check page range.
		//if (maxPageNum < [[tmpDict objectForKey:MD_PAGE_NUMBER] intValue]) {
		//	continue;	//skip to next object. not add to define.
		//}
		
		//Add to url link with csv define.
		[urlDefineWithCsv addObject:tmpDict];
		[tmpDict release]; tmpDict = nil;
	}
}

- (void)renderUrlLinkWithCsvAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* urlLinkInfo in urlDefineWithCsv) {
		int targetPageNum = [[urlLinkInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect linkRectInOriginalPdf;
			linkRectInOriginalPdf.origin.x	= [[urlLinkInfo valueForKey:MD_AREA_X] floatValue];
			linkRectInOriginalPdf.origin.y	= [[urlLinkInfo valueForKey:MD_AREA_Y] floatValue];
			linkRectInOriginalPdf.size.width	= [[urlLinkInfo valueForKey:MD_AREA_WIDTH] floatValue];
			linkRectInOriginalPdf.size.height= [[urlLinkInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"linkRectInOriginalPdf for url=%@", NSStringFromCGRect(linkRectInOriginalPdf));
			
			//Show link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor blueColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			//LOG_CURRENT_METHOD;
			//NSLog(@"render url link. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			//[currentPdfScrollView addSubview:areaView];
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRectInOriginalPdf];
		}
	}
}


@end
