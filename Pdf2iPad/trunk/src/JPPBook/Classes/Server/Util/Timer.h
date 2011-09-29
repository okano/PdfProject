//
//  Timer.h
//
//  Created by hisaboh on 08/11/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Timer : NSObject {
	NSString * name;
	NSTimeInterval total;
	NSTimeInterval startTime;
}
- (id)initWithName:(NSString *)aName;
- (void)dealloc;
- (void)start;
- (void)stop;
- (void)log;
+ (void)start:(NSString *)name;
+ (void)stop:(NSString *)name;
+ (void)logAll;

@end
