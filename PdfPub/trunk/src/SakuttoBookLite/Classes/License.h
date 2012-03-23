//
//  License.h
//  SakuttoBook
//
//  Created by okano on 11/01/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

//Sample key(this is NOT valid but special key).
#define SAMPLE_LICENSE_KEY @"BE66C524-9DB7-44F0-B1FC-E8FDDFDAF7C2"

@interface License : NSObject {
	NSString* licenseKey;
}

- (BOOL)parseLicenseFile;
- (BOOL)isValidLicense;
- (BOOL)isSampleLicense;
- (NSString*)getLicenseKeyByString;
- (NSString*)getDummyKey;

@end
