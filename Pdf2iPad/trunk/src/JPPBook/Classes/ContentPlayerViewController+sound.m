//
//  ContentPlayerViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (soundonpage)

#pragma mark -
#pragma mark Treat Sound on page.
//Parse Sound Define.
- (void)parseSoundOnPageDefine
{
	soundDefine = [[NSMutableArray alloc] init];
	
	
	
	//parse csv file.
	NSString* targetFilename = CSVFILE_SOUND;
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
		if ([tmpCsvArray count] < 2) {
			NSLog(@"illigal CSV data. item count=%d, line=%@", [tmpCsvArray count], line);
			continue;	//Skip illigal line.
		}
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:SD_PAGE_NUMBER];
		//Filename.
		NSString* tmpStr = [tmpCsvArray objectAtIndex:1];
		NSString* tmpStrWithoutDoubleQuote = [tmpStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete DoubleQuote. */
		NSString* tmpStrWithoutCR = [tmpStrWithoutDoubleQuote stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x0d] withString:@""];	/* delete CR. */
		NSString* tmpStrWithoutLF = [tmpStrWithoutCR stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x22] withString:@""];	/* delete LF. */
		[tmpDict setValue:tmpStrWithoutLF forKey:SD_SOUND_FILENAME];
		
		[soundDefine addObject:tmpDict];
		[tmpDict release]; tmpDict = nil;
	}
}

- (void)playSoundAtIndex:(NSUInteger)index
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"page=%d", index);
	//NSLog(@"soundDefine=%@", [soundDefine description]);
	
	for (NSMutableDictionary* soundInfo in soundDefine) {
		int targetPageNum = [[soundInfo valueForKey:SD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			NSString* filename = [soundInfo valueForKey:SD_SOUND_FILENAME];
			
			//Play sound. file from mainBundle.
			//NSString *soundPath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
			
			//Play sound. file from mainBundle.
			NSString* cidStr = [NSString stringWithFormat:@"%d", currentContentId];
			NSString *soundPath = [[ContentFileUtility getContentBodySoundDirectoryWithContentId:cidStr]
								   stringByAppendingPathComponent:filename];
			if (! soundPath) {
				//LOG_CURRENT_METHOD;
				NSLog(@"no sound file found. filename=%@", filename);
				continue;	//Skip to next file.
			}
			NSURL* soundURL = [NSURL fileURLWithPath:soundPath];
			if (! soundURL) {
				LOG_CURRENT_METHOD;
				NSLog(@"no sound file found. filePath=%@, soundURL=%@", soundPath, soundURL);
				continue;	//Skip to next file.
			}
			
			//CFURLRef soundURL = (CFURLRef)[NSURL fileURLWithPath:soundPath];
			//SystemSoundID soundID;
			//AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundID);
			//AudioServicesPlaySystemSound(soundID);
			
			if (audioPlayer != NULL) {
				[audioPlayer stop];
				[audioPlayer release];
				audioPlayer = NULL;
			}
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:NULL];
			[audioPlayer play];
		}
	}
}

@end
