//
//  OpdsRootDelegater.h
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define OPDS_TAG_TITLE @"feed/entry/title"
#define OPDS_TAG_LINK  @"feed/entry/link"

@protocol OpdsRootHandler
- (void)difFinishParseOpdfRoot:(NSMutableArray*)resultArray;
@end

@interface ParseEngine4OpdsRoot : NSObject <NSXMLParserDelegate> {
	id<OpdsRootHandler> parentClass;
	
	NSMutableArray *tags;
	
	NSMutableArray* resultArray;
	NSMutableDictionary* tmpDict;
	
	NSMutableString* nameStr;
	NSMutableString* valueStr;
	
	BOOL inTitleElement;
    BOOL inLinkElement;
	
}

@property (nonatomic, retain) id parentClass;

@end
