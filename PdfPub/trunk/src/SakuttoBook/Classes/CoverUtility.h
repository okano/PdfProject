//
//  CoverUtility.h
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SakuttoBookAppDelegate.h"
#import "InAppPurchaseDefine.h"
#import "FileUtility.h"
#import "Define.h"

@interface CoverUtility : NSObject {
    
}
+ (UIImage*)allocCoverImageWithContentId:(ContentId)cid;
+ (UIImage*)coverImageWithUuid:(NSString*)uuid;
//
+ (NSString*)getCoverLocalFilenameFull:(ContentId)cid;
+ (NSString*)getCoverCacheFilenameFullWithContentId:(ContentId)cid;
+ (NSString*)getCoverCacheFilenameFull:(NSString*)uuid;

@end
