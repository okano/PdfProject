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

@interface InAppPurchaseUtility : NSObject {
    
}
//Get id from file.
+ (NSString*)getProductIdentifier:(ContentId)cid;

@end
