//
//  opdsParser.m
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpdsParser.h"


@implementation OpdsParser


//@see:http://w.livedoor.jp/iphone_tricks/d/XML%A5%D5%A5%A1%A5%A4%A5%EB(NSXMLParser)
- (NSMutableDictionary*)getOpdsRoot:(NSURL*)rootUrl
{
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [rootUrl description]);
	

	// NSXMLParserオブジェクトを作ってURLを指定する。
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:rootUrl] autorelease];
	//
	OpdsRootDelegater* delegater = [[OpdsRootDelegater alloc] init];
	[parser setDelegate:delegater];
	
	//
	[parser parse];

	return nil;
}


@end
