//
//  Timer.m
//
//  Created by hisaboh on 08/11/17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"

static NSMutableDictionary * timers;


@implementation Timer
- (id)initWithName:(NSString *)aName;
{
	self = [super init];
	if (self != nil) {
		if (name != aName) {
			[name release];
			name = [aName retain];
		}
		total = 0;
		startTime = 0;
	}
	return self;
}
- (void)dealloc
{
	[name release];
	[super dealloc];
}
- (void)start
{
	startTime = [NSDate timeIntervalSinceReferenceDate];
}
- (void)stop {
	if (startTime > 0) {
		total = [NSDate timeIntervalSinceReferenceDate] - startTime;
	}
	startTime = 0;
}
- (void)log
{
	[self stop];
	NSLog(@"TIME[%@]: %f\n", name, total);
}

+ (void)start:(NSString *)key
{
	@try {
	if (timers == nil) {
		timers = [[NSMutableDictionary alloc] init];
	}
	Timer * t = [timers objectForKey:key];
	if (t == nil) {
		t = [[[Timer alloc] initWithName:key] autorelease];
		[timers setObject:t forKey:key];
	}
	[t start];
	}
	@catch (NSException * e) {
		NSLog(@"Name: %@\n", [e name]);
		NSLog(@"Reason: %@\n", [e reason]);
	}
}
+ (void)stop:(NSString *)key
{
	if (timers != nil) {
		Timer* timer = [timers objectForKey:key];
		if (timer != nil) [timer stop];
	}
}
+ (void)logAll
{
	if (timers != nil) {
		NSEnumerator * e = [[timers allValues] objectEnumerator];
		Timer * timer;
		while (timer = [e nextObject]) {
			[timer log];
		}
		[timers removeAllObjects];
		[timers release];
		timers = nil;
	}
}

@end
