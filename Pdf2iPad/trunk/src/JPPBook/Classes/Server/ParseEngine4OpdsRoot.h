//
//  OpdsRootDelegater.h
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "ProtocolDefine.h"

#define OPDS_TAG_TITLE @"feed/entry/title"
#define OPDS_TAG_LINK  @"feed/entry/link"

@interface ParseEngine4OpdsRoot : NSObject <NSXMLParserDelegate> {
	id <OpdsParserProtocol> parentParser;
	
	NSMutableArray *tags;
	
	NSMutableArray* resultArray;
	NSMutableDictionary* tmpDict;
	
	NSMutableString* nameStr;
	NSMutableString* valueStr;
	
	BOOL inTitleElement;
    BOOL inLinkElement;
	
}

@property (nonatomic, retain) id parentParser;

@end
