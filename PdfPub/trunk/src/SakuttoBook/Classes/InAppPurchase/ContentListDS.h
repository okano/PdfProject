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

@interface ContentListDS : NSObject {
    NSMutableArray* contentList;
}

@property (nonatomic, retain) NSMutableArray* contentList;

- (uint)count;
- (ContentId)contentIdAtIndex:(NSInteger)index;
- (ContentId)contentIdFromProductId:(NSString*)productId;

- (NSString*)titleAtIndex:(NSInteger)index;
- (NSString*)titleByContentId:(ContentId)cid;
- (NSString*)authorAtIndex:(NSInteger)index;
- (NSString*)authorByContentId:(ContentId)cid;
- (NSString*)descriptionAtIndex:(NSInteger)index;
- (NSString*)descriptionByContentId:(ContentId)cid;
- (UIImage*)thumbnailImageAtIndex:(NSInteger)index;
- (UIImage*)thumbnailImageByContentId:(ContentId)cid;

#pragma mark - Payment Infomation Check.
- (NSUInteger)checkPaymentStatusByContentId:(ContentId)cid;

#pragma mark - TestData.
- (void)setupTestData;

@end
