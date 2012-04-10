//
//  URLDownload.m
//  AreeDic
//
//  Created by hisaboh on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "URLDownload.h"
#import "NSFileManager+Utility.h"


@implementation URLDownload
@synthesize filePath;

- (id)initWithRequest:(NSURLRequest *)req directory:(NSString *)dir delegate:(id<URLDownloadDeleagte, NSObject>)dg {
	if ((self = [super init]) != nil) {
		request = [req retain];
		directoryPath = [dir retain];
		delegate = [dg retain];
		
		con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
	return self;
}

- (void)dealloc {
	[request release];
	[directoryPath release];
	[filePath release];
	[file release];
	[delegate release];
	[con release];
	[super dealloc];
}

- (void)cancel {
	[con cancel];
}

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	filePath = [[response suggestedFilename] retain];
	if ([delegate respondsToSelector:@selector(download: didReceiveResponse:)])
		[delegate download:self didReceiveResponse:response];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
	if ([delegate respondsToSelector:@selector(download: didFailWithError:)])
		[delegate download:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	@try {
		if (file == nil) {
			NSFileManager *fm = [NSFileManager defaultManager];
			BOOL isDir;
			if (![fm fileExistsAtPath:directoryPath isDirectory:&isDir]) {
				NSError *error;
				if (![fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
					NSLog(@"%@", [error localizedDescription]);
					NSLog(@"%@", [error localizedFailureReason]);
					NSLog(@"%@", [error localizedRecoverySuggestion]);
					[NSException raise:@"Exception" format:@"%@", [error localizedDescription]];
				}
			} else if (!isDir) {
				[NSException raise:@"Exception" format:@"Failed to create directory at %@, because there is a file already.", directoryPath];
			}
			
			NSString *tmpFilePath = [fm suggestFilePath:[[directoryPath stringByAppendingPathComponent:filePath] stringByStandardizingPath]];
			[filePath release];
			filePath = [tmpFilePath retain];
			[fm createFileAtPath:filePath contents:[NSData data] attributes:nil];
			
			file = [[NSFileHandle fileHandleForWritingAtPath:filePath] retain];
		}
		[file writeData:data];
		if ([delegate respondsToSelector:@selector(download: didReceiveDataOfLength:)])
			[delegate download:self didReceiveDataOfLength:[data length]];
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e reason]);
		[connection cancel];
		[delegate download:self didCancelBecauseOf:e];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[delegate downloadDidFinish:self];
}
/*

 - (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
 - (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
 - (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
 - (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
*/
 
@end
