//
//  ColorWidthInfoDS.h
//  CosmeLesson01
//
//  Created by okano on 11/06/06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "DefineCosmeLesson.h"
#import "Utility.h"

@interface ColorWidthInfoDS : NSObject <UITableViewDataSource> {
	NSMutableArray* colorWidthInfo;
}
- (void)setupColorWidthInfo;
- (NSDictionary*)getColorWidthInfoAtIndex:(NSInteger)index;
- (NSUInteger)count;
@end
