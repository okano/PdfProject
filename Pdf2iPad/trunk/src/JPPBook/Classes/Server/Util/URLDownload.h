//
//  URLDownload.h
//  AreeDic
//
//  Created by hisaboh on 08/12/06.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URLDownload;

@protocol URLDownloadDeleagte
- (void)downloadDidFinish:(URLDownload *)download;
- (void)download:(URLDownload *)download didCancelBecauseOf:(NSException *)exception;
- (void)download:(URLDownload *)download didFailWithError:(NSError *)error;
@optional
- (void)download:(URLDownload *)download didReceiveDataOfLength:(NSUInteger)length;
- (void)download:(URLDownload *)download didReceiveResponse:(NSURLResponse *)response;

@end

@interface URLDownload : NSObject {
	id <URLDownloadDeleagte, NSObject> delegate;
	NSString *directoryPath;
	NSString *filePath;
	NSURLRequest *request;
	NSFileHandle *file;
	NSURLConnection *con;
}
@property(readonly) NSString *filePath;

- (id)initWithRequest:(NSURLRequest *)req directory:(NSString *)dir delegate:(id<URLDownloadDeleagte, NSObject>)dg;
- (void)dealloc;
- (void)cancel;

// NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;

@end



