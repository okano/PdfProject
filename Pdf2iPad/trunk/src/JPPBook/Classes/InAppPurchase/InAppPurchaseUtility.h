//
//  InAppPurchaseUtility.h
//  SakuttoBook
//
//  Created by okano on 11/06/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "Utility.h"
#import "InAppPurchaseDefine.h"
#import "FileUtility.h"

@interface InAppPurchaseUtility : NSObject {
    
}
//Get id from file.
+ (NSString*)getProductIdentifier:(ContentId)cid;
+ (ContentId)getContentIdentifier:(NSString*)pid;
+ (NSArray*)getAllProductIdentifier;
//Convert productId with/without Full.
+ (NSString*)productIdWithFullQualifier:(NSString*)sinpleProductId;
+ (NSString*)productIdWithoutFullQualifier:(NSString*)fullProductId;
//Judge free comtent.
+ (BOOL)isFreeContent:(NSString*)productId;
//+ (NSString*)getBookDefineFilename:(ContentId)cid;

@end
