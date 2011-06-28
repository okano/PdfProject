//
//  Pdf2iPadViewController.m
//  Pdf2iPad
//
//  Created by okano on 10/12/04.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "Pdf2iPadViewController.h"

@implementation Pdf2iPadViewController (soundonpage)

#pragma mark -
#pragma mark Treat Sound on page.
//Parse Sound Define.
- (BOOL)parseSoundOnPageDefine
{
	soundDefine = [[NSMutableArray alloc] init];
	
	NSMutableDictionary* tmpDict;
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"soundDefine" ofType:@"csv"];
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
	}
	//
	
	return ! hasError;
}

- (void)playSoundAtIndex:(NSUInteger)index
{
	LOG_CURRENT_METHOD;
	NSLog(@"page=%d", index);
	//NSLog(@"soundDefine=%@", [soundDefine description]);
	
	for (NSMutableDictionary* soundInfo in soundDefine) {
		int targetPageNum = [[soundInfo valueForKey:SD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			NSString* filename = [soundInfo valueForKey:SD_SOUND_FILENAME];
			
			//Play sound.
			NSString *soundPath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
			NSURL* soundURL = [NSURL fileURLWithPath:soundPath];
			
			//CFURLRef soundURL = (CFURLRef)[NSURL fileURLWithPath:soundPath];
			//SystemSoundID soundID;
			//AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundID);
			//AudioServicesPlaySystemSound(soundID);
			
			if (audioPlayer == NULL) {
				audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:NULL];
				[audioPlayer play];
			} else {
				[audioPlayer stop];
				[audioPlayer initWithContentsOfURL:soundURL error:NULL];
				[audioPlayer play];
			}
		}
	}
}

@end
