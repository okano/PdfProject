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

#pragma mark - OpdsParserProtocol
- (void)didFinishParseOpdsRoot:(NSMutableArray*)resultArray
{
	LOG_CURRENT_METHOD;
	NSLog(@"resultArray=%@", [resultArray description]);
	
	
	NSString* searchForMe = @"最新順";
	for (NSDictionary* tmpDict in resultArray) {
		NSString* searchThisString = [tmpDict valueForKey:OPDS_TAG_TITLE];
		NSRange range = [searchThisString rangeOfString : searchForMe];
	
		if (range.location != NSNotFound) {
			NSLog(@"I found something.");
			NSLog(@"title=%@, link=%@", [tmpDict valueForKey:OPDS_TAG_TITLE], [tmpDict valueForKey:OPDS_TAG_LINK]);
		}
	}
}

- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray
{
	LOG_CURRENT_METHOD;
	NSLog(@"resultArray=%@", [resultArray description]);
}


@end
