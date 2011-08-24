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
#import "OpdsRootDelegater.h"

@interface OpdsParser : NSObject <NSXMLParserDelegate> {
}

- (NSMutableDictionary*)getOpdsRoot:(NSURL*)rootUrl;

@end
