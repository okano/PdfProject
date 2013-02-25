//
//  ContentPlayerViewController+mailSend.m
//  SakuttoBook
//
//  Created by okano on 12/10/20.
//  Copyright 2010,2011,2012 Katsuhiko Okano All rights reserved.
//

#import "ContentPlayerViewController.h"

@implementation ContentPlayerViewController (mailSend)

// Parse Mail define in CSV.
- (void)parseMailDefine
{
	mailDefine = [[NSMutableArray alloc] init];
	
	//parse csv file.
	NSString* targetFilename = @"mailDefine";
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
		
		tmpDict = [[NSMutableDictionary alloc] init];
		//Page Number.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:0] intValue]] forKey:MD_PAGE_NUMBER];
		//Position.
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:1] intValue]] forKey:MD_AREA_X];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:2] intValue]] forKey:MD_AREA_Y];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:3] intValue]] forKey:MD_AREA_WIDTH];
		[tmpDict setValue:[NSNumber numberWithInt:[[tmpCsvArray objectAtIndex:4] intValue]] forKey:MD_AREA_HEIGHT];
		//To field.
		NSString* toAddressesStr = [tmpCsvArray objectAtIndex:5];
		NSArray* toAddresses = [toAddressesStr componentsSeparatedByString:@" "];
		if (1 <= [toAddresses count]) {
			[tmpDict setValue:toAddresses forKey:MS_TO_ADDESSES];
		}
		//Subject field.
		if (7 <= [tmpCsvArray count]) {
			NSString* subjectStr = [tmpCsvArray objectAtIndex:6];
			[tmpDict setValue:subjectStr forKey:MS_SUBJECT];
		}
		//Body field.
		if (8 <= [tmpCsvArray count]) {
			NSString* bodyStr = [tmpCsvArray objectAtIndex:7];
			[tmpDict setValue:bodyStr forKey:MS_BODY];
		}
		//Cc field.
		if (9 <= [tmpCsvArray count]) {
			NSString* ccAddressesStr = [tmpCsvArray objectAtIndex:8];
			NSArray* ccAddresses = [ccAddressesStr componentsSeparatedByString:@" "];
			if (1 <= [ccAddresses count]) {
				[tmpDict setValue:ccAddresses forKey:MS_CC_ADDESSES];
			}
		}
		//Bcc field.
		if (10 <= [tmpCsvArray count]) {
			NSString* bccAddressesStr = [tmpCsvArray objectAtIndex:9];
			NSArray* bccAddresses = [bccAddressesStr componentsSeparatedByString:@" "];
			if (1 <= [bccAddresses count]) {
				[tmpDict setValue:bccAddresses forKey:MS_BCC_ADDESSES];
			}
		}
		
		//Check page range.
		if (maxPageNum < [[tmpDict objectForKey:MD_PAGE_NUMBER] intValue]) {
			continue;	//skip to next object. not add to define.
		}
		
		//Add to mail define.
		[mailDefine addObject:tmpDict];
	}
}

- (void)renderMailLinkAtIndex:(NSUInteger)index
{
	for (NSMutableDictionary* mailInfo in mailDefine) {
		int targetPageNum = [[mailInfo valueForKey:MD_PAGE_NUMBER] intValue];
		if (targetPageNum == index) {
			CGRect linkRectInOriginalPdf;
			linkRectInOriginalPdf.origin.x	= [[mailInfo valueForKey:MD_AREA_X] floatValue];
			linkRectInOriginalPdf.origin.y	= [[mailInfo valueForKey:MD_AREA_Y] floatValue];
			linkRectInOriginalPdf.size.width	= [[mailInfo valueForKey:MD_AREA_WIDTH] floatValue];
			linkRectInOriginalPdf.size.height= [[mailInfo valueForKey:MD_AREA_HEIGHT] floatValue];
			//NSLog(@"linkRectInOriginalPdf for mail=%@", NSStringFromCGRect(linkRectInOriginalPdf));
			
			//Show Mail link area with half-opaque.
			UIView* areaView = [[UIView alloc] initWithFrame:CGRectZero];
#if TARGET_IPHONE_SIMULATOR
			//Only show on Simulator.
			[areaView setBackgroundColor:[UIColor greenColor]];
			[areaView setAlpha:0.2f];
#else
			[areaView setAlpha:0.0f];
#endif
			//LOG_CURRENT_METHOD;
			//NSLog(@"render mail link. rect=%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
			//[currentPdfScrollView addSubview:areaView];
			[currentPdfScrollView addScalableSubview:areaView withPdfBasedFrame:linkRectInOriginalPdf];
		}
	}
}

- (void)showMailComposerWithSubject:(NSString*)subject
						toRecipient:(NSArray*)toRecipient
						ccRecipient:(NSArray*)ccRecipient
					   bccRecipient:(NSArray*)bccRecipient
						messageBody:(NSString*)messageBody;
{
	//Show mail compose view.
	MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
	[controller setSubject:subject];
	[controller setToRecipients:toRecipient];
	[controller setCcRecipients:ccRecipient];
	[controller setBccRecipients:bccRecipient];
	[controller setMessageBody:messageBody isHTML:NO];
	controller.mailComposeDelegate = self;
	[self presentModalViewController:controller animated:YES ];
}


#pragma mark - MFMailComposeViewControllerDelegate Protocol.
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{
	//Check error.
	if(error != nil) {
		NSLog(@"Mail send error. code=%d, error=%@", [error code], [error localizedDescription]);
		[controller dismissModalViewControllerAnimated:YES];
		return;
	}
	
	switch(result) {
		case MFMailComposeResultSent:
			NSLog(@"mail sent." );
			break;
		case MFMailComposeResultSaved:
			NSLog(@"mail saved.");
			break;
		case MFMailComposeResultCancelled:
			NSLog(@"mail cancelled");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"mail failed");
			break;
		default:
			NSLog(@"mail unknown result.");
			break;
	}
	[controller dismissModalViewControllerAnimated:YES];
}

@end
