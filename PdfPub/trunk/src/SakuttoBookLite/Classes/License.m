//
//  License.m
//  SakuttoBook
//
//  Created by okano on 11/01/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "License.h"


@implementation License

- (id)init {
	self = [super init];
	if (self) {
		licenseKey = nil;
		[self parseLicenseFile];
	}
	return self;
}

/**
 * parse license key from license file.
 * returns TRUE if key or something found. FALSE if no text found.
 */
- (BOOL)parseLicenseFile {
	licenseKey = [[NSString alloc] initWithString:LICENSE_KEY];
	return TRUE;
}

/**
 *License key format/validate check.
 *License key is UUID format. 32-charactor plus 4-hyphens.
 *ex:
 *000000000011111111112222222222333333
 *012345678901234567890123456789012345
 *--------+----+----+----+------------
 *550e8400-e29b-41d4-a716-446655440000
 *--------+----+----+----+------------
 *    8      4    4    4      12
 */
-(BOOL)isValidLicense {
	//NULL check.
	if (licenseKey == nil) {
		return FALSE;
	}
	//Class check.(program miss)
	if (![licenseKey isKindOfClass:[NSString class]]) {
		return FALSE;
	}
	//Length check.
	if ([licenseKey length] != 36) {
		return FALSE;
	}
	
	/* check with each part. */
	NSArray* items = [licenseKey componentsSeparatedByString:@"-"];
	if ([items count] != 5) {
		return FALSE;
	}
	if ([[items objectAtIndex:0] length] != 8
		||
		[[items objectAtIndex:1] length] != 4
		||
		[[items objectAtIndex:2] length] != 4
		||
		[[items objectAtIndex:3] length] != 4
		||
		[[items objectAtIndex:4] length] != 12) {
		return FALSE;
	}
	
	
	
	//Format check.
	CFUUIDRef tmpUuid = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)licenseKey);
	NSString* tmpStr = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, tmpUuid);
	if ([tmpStr caseInsensitiveCompare:licenseKey] != NSOrderedSame) {
		[tmpStr release];
		return FALSE;
	}
	[tmpStr release];
	
	
	//Check validate.
	NSString* key3 = [items objectAtIndex:3];
	if (([key3 intValue] % 7) != 1) {
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL)isSampleLicense {
	if ([licenseKey caseInsensitiveCompare:SAMPLE_LICENSE_KEY] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
}

- (NSString*)getLicenseKeyByString {
	return licenseKey;
}

- (NSString*)getDummyKey {
	return @"00000000-0000-0000-0000-000000000001";
}


@end
