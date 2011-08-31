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
	

	// NSXMLParserオブジェクトを作ってURLを指定する。
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:rootUrl] autorelease];
	//
	ParseEngine4OpdsRoot* parseEngine = [[ParseEngine4OpdsRoot alloc] init];
	[parser setDelegate:parseEngine];
	parseEngine.parentClass = self;
	//[delegater setParent:self];
	//
	[parser parse];

	return nil;
}

- (void)difFinishParseOpdfRoot:(NSMutableArray*)resultArray
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

@end
