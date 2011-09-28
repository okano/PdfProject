//
//  CoverUtility.h
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pdf2iPadAppDelegate.h"
#import "InAppPurchaseDefine.h"
#import "FileUtility.h"

@interface CoverUtility : NSObject {
    
}
+ (UIImage*)thumbnailImageWithContentId:(ContentId)cid;
+ (UIImage*)thumbnailImageWithUuid:(NSString*)uuid;

@end
