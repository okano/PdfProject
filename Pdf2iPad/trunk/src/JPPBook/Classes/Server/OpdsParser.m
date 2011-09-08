//
//  opdsParser.m
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpdsParser.h"


@implementation OpdsParser
//@synthesize targetTableVC;

/*
- (void)getOpds:(NSURL*)rootUrl
{
	[self getOpdsRoot:rootUrl];
}
*/

#pragma mark - parse opes-Root.
//using kissXML library.
- (NSURL*)getOpdsRoot:(NSURL*)rootUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [rootUrl description]);
	
	//load XML to text.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:rootUrl];
	//NSLog(@"feed=%@", feed);
	if (feed == nil) {
		NSLog(@"no feed found.");
		return nil;
	}
	
	NSError* error;
	
	NSData *_data = [NSData dataWithContentsOfURL:rootUrl];  
	
	//Prepare Parse.
    DDXMLDocument* doc = [[[DDXMLDocument alloc] initWithData:_data options:0 error:nil] autorelease];  
	DDXMLElement *rootElement = [doc rootElement];
	//NSLog(@"doc=%@", [doc description]);
	//NSLog(@"root=%@", [root description]);
	
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"dc" stringValue:@"http://purl.org/dc/terms/"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"opds" stringValue:@"http://opds-spec.org/2010/catalog"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"foo" stringValue:@"http://www.w3.org/2005/Atom"]];
	
	//Parse.
	NSArray *feedTitles = [rootElement nodesForXPath:@"//foo:source/foo:title" error:&error];
	NSArray *feedIds = [rootElement nodesForXPath:@"//foo:source/foo:id" error:&error];
	NSArray *entryTitles = [rootElement nodesForXPath:@"//foo:entry/foo:title" error:&error];
	NSArray *entryIds = [rootElement nodesForXPath:@"//foo:entry/foo:id" error:&error];
	NSArray *contents = [rootElement nodesForXPath:@"//foo:entry/foo:content" error:&error];
	NSArray *links = [rootElement nodesForXPath:@"//foo:entry/foo:link" error:&error];

	NSLog(@"feedTitles=%@", [feedTitles description]);
	NSLog(@"feedIds=%@", [feedIds description]);
	NSLog(@"entryTitles=%@", [entryTitles description]);
	NSLog(@"entryTitles=%@", [entryTitles description]);
	NSLog(@"entryIds=%@", [entryIds description]);
	NSLog(@"contents=%@", [contents description]);
	NSLog(@"links=%@", [links description]);
	
	
	NSString* resultStr;
	//NSString* searchForMe = @"%C3%8A%C3%BA%C3%84%C3%8A%C3%B1%E2%88%9E%C3%88%E2%80%A0%C3%9C";
	NSString* searchForMe = @"最新順";
	NSLog(@"searchForMe=%@ (%@)", searchForMe, [searchForMe stringByAddingPercentEscapesUsingEncoding:
												NSUTF8StringEncoding]);
	for (int cnt = 0; cnt < [entryTitles count]; cnt++) {
		
		NSString* searchThisString = [[entryTitles objectAtIndex:cnt] stringValue];
		NSLog(@"searchThisString=%@", searchThisString);
		NSRange range = [searchThisString rangeOfString : searchForMe];
		
		if (range.location != NSNotFound) {
			NSLog(@"cnt = %d", cnt);
			NSLog(@"title=%@", [[entryTitles objectAtIndex:cnt] stringValue]);
			NSLog(@"links=%@", [[links objectAtIndex:cnt] description]);
			
			//resultStr = [[[links objectAtIndex:cnt] description] substringFromIndex:12];
		
			NSArray* arr = [[[links objectAtIndex:cnt] description]
								   componentsSeparatedByString:[NSString stringWithFormat:@"%c", 0x22]];
			
			resultStr = [arr objectAtIndex:1];
		}
	}
	
	
	
	NSMutableArray* titles = [[NSMutableArray alloc] init];  
	NSMutableArray* date = [[NSMutableArray alloc] init];  
   	NSMutableArray* summary = [[NSMutableArray alloc] init];  
   	//NSMutableArray* imgData = [[NSMutableArray alloc] init];  
	
    // パースする  
    NSArray *titleArray = [rootElement nodesForXPath:@"/feed/entry/title" error:nil ];  
    NSArray *dateArray = [rootElement nodesForXPath:@"/feed/entry/date" error:nil];  
    NSArray *summaryArray = [rootElement nodesForXPath:@"/feed/entry/summary" error:nil];  
    //NSArray *imageArray = [root nodesForXPath:@"/feed/entry/image" error:nil];  
	NSArray* feed1 = [rootElement nodesForXPath:@"/" error:&error];
	NSArray* feed2 = [rootElement nodesForXPath:@"/feed" error:&error];
	NSLog(@"feed2=%@", [feed2 description]);
	feed2 = [rootElement nodesForXPath:@"/xml" error:&error];
	NSLog(@"feed2=%@", [feed2 description]);
	feed2 = [rootElement nodesForXPath:@"/feed" error:&error];
	NSLog(@"feed2=%@", [feed2 description]);
	feed2 = [rootElement nodesForXPath:@"/title" error:&error];
	NSLog(@"feed2=%@", [feed2 description]);
	feed2 = [rootElement nodesForXPath:@"/entry" error:&error];
	NSLog(@"feed2=%@", [feed2 description]);
	
	
	NSArray *mySnapShots = [rootElement nodesForXPath:@"//feed/entry" error:&error];
	NSLog(@"%@", mySnapShots);
	
	
	NSArray* feed3 = [rootElement elementsForName:@"title"];
	NSLog(@"feed3=%@", [feed3 description]);
	feed3 = [rootElement elementsForName:@"entry"];
	NSLog(@"feed3=%@", [feed3 description]);
	
	//feed3 = [root elementsForName:@"entry/title"];
	//NSLog(@"feed3=%@", [feed3 description]);
	for (DDXMLElement* singleEntry in feed3) {
		NSLog(@"singleEntry=%@", [singleEntry description]);
		
		NSArray* title1 = [singleEntry nodesForXPath:@"title" error:nil];
		NSLog(@"title1=%@", [title1 description]);
		NSArray* title2 = [singleEntry nodesForXPath:@"/title" error:nil];
		NSLog(@"title2=%@", [title2 description]);
		title2 = [singleEntry nodesForXPath:@"/entry" error:nil];
		NSLog(@"title2=%@", [title2 description]);
		title2 = [singleEntry nodesForXPath:@"entry" error:nil];
		NSLog(@"title2=%@", [title2 description]);
		
		
		feed3 = [singleEntry elementsForName:@"title"];
		NSLog(@"feed3=%@", [feed3 description]);
		feed3 = [singleEntry elementsForName:@"link"];
		NSLog(@"feed3=%@", [feed3 description]);

		
	}
	
	
	
	
    // パース結果を配列に格納  
    for (int cnt = 0; cnt < [titleArray count]; cnt++) {  
        [titles addObject:[[titleArray objectAtIndex:cnt] stringValue]];  
        [date addObject:[[dateArray objectAtIndex:cnt] stringValue]];  
        [summary addObject:[[summaryArray objectAtIndex:cnt] stringValue]];  
	}
	NSLog(@"titles=%@", [titles description]);
	NSLog(@"date=%@", [date description]);
	NSLog(@"summary=%@", [summary description]);
	NSLog(@"feed1=%@", [feed1 description]);
	
	/*
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
	 */
	
	
	return nil;
}

/*
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
*/

#pragma mark - parse opds-Element.
- (NSMutableArray*)getOpdsElement:(NSURL *)elementUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [elementUrl description]);
	
	//load XML to text.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:elementUrl];
	NSLog(@"feed=%@", feed);
	/*
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
	*/
	
	
	
	return nil;
}

@end
