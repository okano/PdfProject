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
	//LOG_CURRENT_METHOD;
	//NSLog(@"rootUrl=%@", [rootUrl description]);
	
	//check XML exists.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:rootUrl];
	if (feed == nil) {
		NSLog(@"no feed found.");
		return nil;
	}
	//NSLog(@"feed=%@", feed);
	
	//load XML to NSData.
	NSData *_data = [NSData dataWithContentsOfURL:rootUrl];  
	
	//Prepare Parse.
	NSError* error;
    DDXMLDocument* doc = [[[DDXMLDocument alloc] initWithData:_data options:0 error:nil] autorelease];  
	DDXMLElement *rootElement = [doc rootElement];
	//NSLog(@"doc=%@", [doc description]);
	//NSLog(@"root=%@", [root description]);
	
	//Add namespace to parser.
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"dc" stringValue:@"http://purl.org/dc/terms/"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"opds" stringValue:@"http://opds-spec.org/2010/catalog"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"foo" stringValue:@"http://www.w3.org/2005/Atom"]];
	
	//Parse.
	NSArray *feedTitles = [rootElement nodesForXPath:@"//foo:title" error:&error];
	NSArray *feedIds = [rootElement nodesForXPath:@"//foo:id" error:&error];
	NSArray *feedAuthors = [rootElement nodesForXPath:@"//foo:author" error:&error];
	NSArray *entryTitles = [rootElement nodesForXPath:@"//foo:entry/foo:title" error:&error];
	NSArray *entryIds = [rootElement nodesForXPath:@"//foo:entry/foo:id" error:&error];
	NSArray *contents = [rootElement nodesForXPath:@"//foo:entry/foo:content" error:&error];
	NSArray *links = [rootElement nodesForXPath:@"//foo:entry/foo:link" error:&error];

	NSLog(@"feedTitles=%@", [feedTitles description]);
	NSLog(@"feedIds=%@", [feedIds description]);
	NSLog(@"feedAuthors=%@", [feedAuthors description]);
	NSLog(@"entryTitles=%@", [entryTitles description]);
	NSLog(@"entryIds=%@", [entryIds description]);
	NSLog(@"contents=%@", [contents description]);
	NSLog(@"links=%@", [links description]);
	
	//Find specify feed.
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
			
			resultStr = [NSString stringWithFormat:@"%@%@", URL_BASE_OPDS, [arr objectAtIndex:1]];
		}
	}
	NSLog(@"resultStr=%@", resultStr);
	
	
	return [NSURL URLWithString:resultStr];
}


#pragma mark - parse opds-Element.
- (NSMutableArray*)getOpdsElement:(NSURL *)elementUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"elementUrl=%@", [elementUrl description]);
	
	//check XML exists.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:elementUrl];
	if (feed == nil) {
		NSLog(@"no feed found.");
		return nil;
	}
	//NSLog(@"feed=%@", feed);
	
	//load XML to NSData.
	NSData *_data = [NSData dataWithContentsOfURL:elementUrl];  
	
	//Prepare Parse.
	NSError* error;
    DDXMLDocument* doc = [[[DDXMLDocument alloc] initWithData:_data options:0 error:nil] autorelease];  
	DDXMLElement *rootElement = [doc rootElement];
	//NSLog(@"doc=%@", [doc description]);
	//NSLog(@"root=%@", [root description]);
	
	//Add namespace to parser.
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"dc" stringValue:@"http://purl.org/dc/terms/"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"opds" stringValue:@"http://opds-spec.org/2010/catalog"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"foo" stringValue:@"http://www.w3.org/2005/Atom"]];
	
	//Parse.
	NSArray *feedTitles = [rootElement nodesForXPath:@"//foo:title" error:&error];
	NSArray *feedIds = [rootElement nodesForXPath:@"//foo:id" error:&error];
	NSArray *feedAuthors = [rootElement nodesForXPath:@"//foo:author" error:&error];
	NSArray *entryTitles = [rootElement nodesForXPath:@"//foo:entry/foo:title" error:&error];
	NSArray *entryIds = [rootElement nodesForXPath:@"//foo:entry/foo:id" error:&error];
	NSArray *contents = [rootElement nodesForXPath:@"//foo:entry/foo:content" error:&error];
	NSArray *links = [rootElement nodesForXPath:@"//foo:entry/foo:link" error:&error];
	
	NSLog(@"feedTitles=%@", [feedTitles description]);
	NSLog(@"feedIds=%@", [feedIds description]);
	NSLog(@"feedAuthors=%@", [feedAuthors description]);
	NSLog(@"entryTitles=%@", [entryTitles description]);
	NSLog(@"entryIds=%@", [entryIds description]);
	NSLog(@"contents=%@", [contents description]);
	NSLog(@"links=%@", [links description]);
	

	
	return nil;
}

@end
