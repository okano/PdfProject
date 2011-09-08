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
#import "ProtocolDefine.h"
#import "UrlDefine.h"
#import "DDXML.h"

@interface OpdsParser : NSObject {
}

//- (NSURL*)getOpds:(NSURL*)rootUrl;
- (NSURL*)getOpdsRoot:(NSURL*)rootUrl;
- (NSMutableArray*)getOpdsElement:(NSURL*)elementUrl;

@end

