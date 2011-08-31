//
//  opdsParser.h
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import "Utility.h"
#import "ParseEngine4OpdsRoot.h"
#import "ProtocolDefine.h"

@interface OpdsParser : NSObject <NSXMLParserDelegate, OpdsRootHandler> {
	id <ContentListProtocol> targetTableVC;
}
@property (nonatomic, retain) id targetTableVC;

- (void)getOpds:(NSURL*)rootUrl;
- (NSMutableDictionary*)getOpdsRoot:(NSURL*)rootUrl;

@end

