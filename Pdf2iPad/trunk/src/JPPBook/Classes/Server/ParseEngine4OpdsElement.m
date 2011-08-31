//
//  OpdsRootDelegater.m
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParseEngine4OpdsElement.h"

@implementation ParseEngine4OpdsElement

@synthesize parentParser;


- (id)init {
    self = [super init];
    if (self) {
        tags = nil;
		resultArray = [[NSMutableArray alloc] init];
		tmpDict = [[NSMutableDictionary alloc] init];
		nameStr = [[NSMutableString alloc] init];
		valueStr = [[NSMutableString alloc] init];
    }
    return self;
}


//新しいタグが出てくるたびに、パス名を付け足していく。
- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	
	
	//　tagsがnilだったら作成する。    
	if (!tags) {
		tags = [[NSMutableArray alloc] init];
		NSLog(@"tags作成");
	}
	
	NSString *path = [tags lastObject];
	if (path) {
		path = [path stringByAppendingPathComponent:elementName];
	} else {
		path = elementName;
	}
	[tags addObject:path];
	
	NSLog(@"<%@> 開始", tags.lastObject);
	for (id key in attributeDict) {
		NSLog(@"%s line %d", __FILE__, __LINE__);
		NSLog(@"%@=%@, path=%@", key, [attributeDict objectForKey:key], path);
		
		if (([path compare:@"feed/entry/link"] == NSOrderedSame) 
			&&
			([key compare:@"href"
					 options:NSCaseInsensitiveSearch
					   range:NSMakeRange(0,4)]
			 == NSOrderedSame))
		{
			[tmpDict setValue:[attributeDict objectForKey:key] forKey:OPDS_TAG_LINK];
			[valueStr setString:[attributeDict objectForKey:key]];
			NSLog(@"%s line %d", __FILE__, __LINE__);

		}
	}
	
	//init.
	NSLog(@"path=%@", path);
	if ([path compare:@"feed/entry"] == NSOrderedSame) {
		NSLog(@"%s line %d", __FILE__, __LINE__);
		[nameStr setString:@""];
		[valueStr setString:@""];
	} else if ([path compare:@"feed/entry/title"] == NSOrderedSame) {
		NSLog(@"%s line %d", __FILE__, __LINE__);
		inTitleElement = YES;
		inLinkElement = NO;
	} else if ([path compare:@"feed/entry/link"] == NSOrderedSame) {
		NSLog(@"%s line %d", __FILE__, __LINE__);
		inTitleElement = NO;
		inLinkElement = YES;
	} else {
		inTitleElement = NO;
		inLinkElement = NO;
	}
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	NSLog(@"%@", string);
	
	
	NSString *path = [tags lastObject];
	if ([path compare:@"feed/entry/title"] == NSOrderedSame) {
		[nameStr appendString:string];	//get only last line.
		NSLog(@"nameStr=%@, path=%@", nameStr, path);
		//[tmpDict setValue:nameStr forKey:OPDS_TAG_TITLE];
	}
}


//タグの終了時にはパスを削除する。tagsが空になったらXMLファイルの処理が終了したのでtagsも解放する。
- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
	
	
	NSLog(@"<%@> 終了", tags.lastObject);
	
	NSString *path = [tags lastObject];
	if ([path compare:@"feed/entry"] == NSOrderedSame) {
		NSLog(@"%s line %d", __FILE__, __LINE__);
		//NSLog(@"tmpDict=%@", [tmpDict description]);
		NSLog(@"nameStr=%@, valueStr=%@", nameStr, valueStr);
		
		
		NSMutableDictionary* tmpDict2 = [[NSMutableDictionary alloc] init];
		[tmpDict2 setValue:[NSString stringWithString:nameStr] forKey:OPDS_TAG_TITLE];
		[tmpDict2 setValue:[NSString stringWithString:valueStr] forKey:OPDS_TAG_LINK];
		//[resultArray addObject:[[NSDictionary alloc] initWithDictionary:tmpDict]];
		[resultArray addObject:tmpDict2];
		//[tmpDict removeAllObjects];
		
		//NSLog(@"resultArray=%@", [resultArray description]);
		
	}

	
	
	// 最後のパスを削除
	[tags removeLastObject];        
	
	// tagsが空になったら解放する。     
	if (!tags.lastObject) {
		[tags release];
		tags = nil;
		NSLog(@"tags解放");
	}
	
	
	inTitleElement = NO;
	inLinkElement = NO;
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	LOG_CURRENT_METHOD;
	if (parentParser != nil) {
		[parentParser didFinishParseOpdsElement:resultArray];
	} else {
		NSLog(@"parent Parse is null!");
	}
}

@end
