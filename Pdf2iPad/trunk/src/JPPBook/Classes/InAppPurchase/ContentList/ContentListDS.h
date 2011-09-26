//
//  ContentListDS.h
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "InAppPurchaseDefine.h"
#import "InAppPurchaseUtility.h"
#import "FileUtility.h"

@interface ContentListDS : NSObject {
    NSMutableArray* contentList;
}

@property (nonatomic, retain) NSMutableArray* contentList;

- (uint)count;
- (ContentId)contentIdAtIndex:(NSInteger)index;
- (ContentId)contentIdFromProductId:(NSString*)productId;
- (ContentId)contentIdFromUuid:(NSString*)uuid;
- (NSString*)productIdFromContentId:(ContentId)cid;
- (NSString*)uuidAtIndex:(NSInteger)index;
- (NSString*)uuidFromContentId:(ContentId)cid;

- (void)setupData;
- (NSString*)description;
- (NSMutableDictionary*)getMetadataByContentId:(ContentId)cid;
- (NSMutableDictionary*)getMetadataByUuid:(NSString*)uuid;

- (NSString*)titleAtIndex:(NSInteger)index;
- (NSString*)titleByContentId:(ContentId)cid;
- (NSString*)titleByUuid:(NSString*)uuid;
- (NSString*)authorAtIndex:(NSInteger)index;
- (NSString*)authorByContentId:(ContentId)cid;
- (NSString*)authorByUuid:(NSString*)uuid;
- (NSString*)descriptionAtIndex:(NSInteger)index;
- (NSString*)descriptionByContentId:(ContentId)cid;
- (NSString*)descriptionByUuid:(NSString*)uuid;
//
- (UIImage*)contentIconAtIndex:(NSInteger)index;
- (UIImage*)contentIconByContentId:(ContentId)cid;
- (UIImage*)contentIconByUuid:(NSString*)uuid;
//
- (NSURL*)acquisitionUrlAtIndex:(NSInteger)index;
- (NSURL*)acquisitionUrlByContentId:(ContentId)cid;
- (NSURL*)acquisitionUrlByUuid:(NSString*)uuid;
- (NSURL*)thumbnailUrlAtIndex:(NSInteger)index;
- (NSURL*)thumbnailUrlByContentId:(ContentId)cid;
- (NSURL*)thumbnailUrlByUuid:(NSString*)uuid;
- (NSURL*)coverUrlAtIndex:(NSInteger)index;
- (NSURL*)coverUrlByContentId:(ContentId)cid;
- (NSURL*)coverUrlByUuid:(NSString*)uuid;

#pragma mark - TestData.
- (void)setupTestData;

@end
