//
//  opdsParser.m
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpdsParser.h"


@implementation OpdsParser
@synthesize targetTableVC;

- (void)getOpds:(NSURL*)rootUrl
{
	[self getOpdsRoot:rootUrl];
}

#pragma mark - parse opes-Root.
//@see:http://w.livedoor.jp/iphone_tricks/d/XML%A5%D5%A5%A1%A5%A4%A5%EB(NSXMLParser)
- (NSMutableDictionary*)getOpdsRoot:(NSURL*)rootUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [rootUrl description]);
	
	//load XML to text.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:rootUrl];
	NSLog(@"feed=%@", feed);

	//Setup parser.
	ParseEngine4OpdsRoot* parseEngine = [[ParseEngine4OpdsRoot alloc] init];
	parseEngine.parentParser = self;
	NSXMLParser *parser = [[[NSXMLParser alloc]
							initWithData:[feed dataUsingEncoding:NSUTF8StringEncoding]]
						   autorelease];
	[parser setDelegate:parseEngine];
	NSLog(@"parser=%@", [parser description]);
	
	//Do parse.
	[parser parse];

	return nil;
}

#pragma mark - OpdsParserProtocol for opds-Root.
- (void)didFinishParseOpdsRoot:(NSMutableArray*)resultArray
{
	LOG_CURRENT_METHOD;
	NSLog(@"resultArray=%@", [resultArray description]);
	
	
	//NSString* searchForMe = @"最新順";
	//NSString* searchForMe = @"\U00ca\U00fa\U00c4\U00ca\U00f1\U221e\U00c8\U2020\U00dc";
	//NSString* searchForMe = [NSString stringWithUTF8String:"¥123¥124"];
	NSString* searchForMe = @"%C3%8A%C3%BA%C3%84%C3%8A%C3%B1%E2%88%9E%C3%88%E2%80%A0%C3%9C";
	NSLog(@"searchForMe=%@ (%@)", searchForMe, [searchForMe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	NSString* resultUrlStr = nil;
	for (NSDictionary* tmpDict in resultArray) {
		NSString* searchThisString2 = [tmpDict valueForKey:OPDS_TAG_TITLE];
		//NSString* searchThisString = [NSString stringWithUTF8String:[tmpDict valueForKey:OPDS_TAG_TITLE]];
		//NSString* searchThisString = [searchThisString2 UTF8String];
		
		//NSString* searchThisString = (NSString *) CFURLCreateStringByAddingPercentEscapes
		//(NULL, (CFStringRef) searchThisString2, NULL, NULL, kCFStringEncodingMacJapanese);
		
		//NSString* searchThisString = 
		NSString* searchThisString = [searchThisString2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		
		//NSLog(@"searchThisString2=%@", searchThisString2);
		//NSLog(@"searchThisString=%@", searchThisString);

		NSRange range = [searchThisString rangeOfString : searchForMe];
	
		if (range.location != NSNotFound) {
			NSLog(@"I found something.");
			NSLog(@"title=%@, link=%@", [tmpDict valueForKey:OPDS_TAG_TITLE], [tmpDict valueForKey:OPDS_TAG_LINK]);
			resultUrlStr = [NSString stringWithString:[tmpDict valueForKey:OPDS_TAG_LINK]];
		}
	}
	if (resultUrlStr != nil) {
		NSLog(@"resultUrlStr=%@", resultUrlStr);
		NSString* fullUrlStr = [NSString stringWithFormat:@"%@%@", URL_BASE_OPDS, resultUrlStr];
		NSLog(@"fullUrlStr=%@", fullUrlStr);
		NSURL* elementUrl = [NSURL URLWithString:fullUrlStr];
		[self getOpdsElement:elementUrl];
	} else {
		NSLog(@"result URL not found.");
	}
}

#pragma mark - parse opds-Element.
- (NSMutableDictionary*)getOpdsElement:(NSURL *)elementUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [elementUrl description]);
	
	//load XML to text.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:elementUrl];
	NSLog(@"feed=%@", feed);
	
	//Setup parser.
	ParseEngine4OpdsElement* parseEngine = [[ParseEngine4OpdsElement alloc] init];
	parseEngine.parentParser = self;
	NSXMLParser *parser = [[[NSXMLParser alloc]
							initWithData:[feed dataUsingEncoding:NSUTF8StringEncoding]]
						   autorelease];
	[parser setDelegate:parseEngine];
	NSLog(@"parser=%@", [parser description]);
	
	//Do parse.
	[parser parse];
	
	return nil;
}

#pragma mark - OpdsParserProtocol for opds-Element.
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray
{
	LOG_CURRENT_METHOD;
	NSLog(@"resultArray=%@", [resultArray description]);
	
	if (targetTableVC != nil) {
		[targetTableVC didFinishParseOpds:resultArray];
	} else {
		NSLog(@"targetTableVC is nil!");
	}
}


@end
