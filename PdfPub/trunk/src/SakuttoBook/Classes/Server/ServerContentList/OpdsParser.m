//
//  opdsParser.m
//  JPPBook
//
//  Created by okano on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpdsParser.h"


@implementation OpdsParser
//@synthesize targetTableVC;

/*
- (void)getOpds:(NSURL*)rootUrl
{
	[self getOpdsRoot:rootUrl];
}
*/

#pragma mark - parse opes-Root.
//using kissXML library.
- (NSURL*)getOpdsRoot:(NSURL*)rootUrl
{
#if defined(DEBUG_CREDENTIAL) && DEBUG_CREDENTIAL != 0
	LOG_CURRENT_METHOD;
	NSLog(@"rootUrl=%@", [rootUrl description]);
#endif
	
	//Check network connection.
	if ([self networkReachability] == FALSE) {
		/*
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"no network connection."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		*/
		
		return nil;
	}
	
	NSError* error = nil;
	
#if 0==1
	//check XML exists.
	NSString* feed = [[NSString alloc] initWithContentsOfURL:rootUrl encoding:NSUTF8StringEncoding error:&error];
	if (feed == nil) {
		NSLog(@"no feed found.");
		NSLog(@"rootUrl=%@", rootUrl);
		/*
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"no content list(Root) found."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		*/
		return nil;
	}
	//NSLog(@"feed=%@", feed);
#endif
	
	
	//Set security infomation.
	NSDictionary* dict = [[ConfigViewController alloc] loadUsernameAndPasswordFromUserDefault];
	NSString* username = [dict valueForKey:USERNAME];
	NSString* password = [dict valueForKey:PASSWORD];
	
	//Get XML data from network.
	NSData *_data =[self getXmlFromUrl:rootUrl username:username password:password];
	if (_data == nil) {
		LOG_CURRENT_METHOD;
		NSLog(@"cannot get data. url=%@", rootUrl);
		return nil;
	}
	
	//Prepare Parse.
    DDXMLDocument* doc = [[[DDXMLDocument alloc] initWithData:_data options:0 error:nil] autorelease];  
	DDXMLElement *rootElement = [doc rootElement];
	//NSLog(@"doc=%@", [doc description]);
	//NSLog(@"root=%@", [root description]);
	
	//Add namespace to parser.
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"dc" stringValue:@"http://purl.org/dc/terms/"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"opds" stringValue:@"http://opds-spec.org/2010/catalog"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"foo" stringValue:@"http://www.w3.org/2005/Atom"]];
	
	//Parse.
	/*
	NSArray *feedTitles = [rootElement nodesForXPath:@"//foo:title" error:&error];
	NSArray *feedIds = [rootElement nodesForXPath:@"//foo:id" error:&error];
	NSArray *feedAuthors = [rootElement nodesForXPath:@"//foo:author" error:&error];
	*/
	NSArray *entryTitles = [rootElement nodesForXPath:@"//foo:entry/foo:title" error:&error];
	/*
	NSArray *entryIds = [rootElement nodesForXPath:@"//foo:entry/foo:id" error:&error];
	NSArray *contents = [rootElement nodesForXPath:@"//foo:entry/foo:content" error:&error];
	*/
	NSArray *links = [rootElement nodesForXPath:@"//foo:entry/foo:link" error:&error];

	/*
	NSLog(@"feedTitles=%@", [feedTitles description]);
	NSLog(@"feedIds=%@", [feedIds description]);
	NSLog(@"feedAuthors=%@", [feedAuthors description]);
	NSLog(@"entryTitles=%@", [entryTitles description]);
	NSLog(@"entryIds=%@", [entryIds description]);
	NSLog(@"contents=%@", [contents description]);
	NSLog(@"links=%@", [links description]);
	*/
	
	
	//Get BASE URL for link.
	NSString* baseUrlStr = [ConfigViewController getUrlBaseWithOpds];
	
	//Find specify feed.
	NSString* resultStr = nil;
	//NSString* searchForMe = @"%C3%8A%C3%BA%C3%84%C3%8A%C3%B1%E2%88%9E%C3%88%E2%80%A0%C3%9C";
	NSString* searchForMe = @"最新順";
	//NSLog(@"searchForMe=%@ (%@)", searchForMe, [searchForMe stringByAddingPercentEscapesUsingEncoding:
	//											NSUTF8StringEncoding]);
	for (int cnt = 0; cnt < [entryTitles count]; cnt++) {
		
		NSString* searchThisString = [[entryTitles objectAtIndex:cnt] stringValue];
		//NSLog(@"searchThisString=%@", searchThisString);
		NSRange range = [searchThisString rangeOfString : searchForMe];
		
		if (range.location != NSNotFound) {
			/*
			NSLog(@"cnt = %d", cnt);
			NSLog(@"title=%@", [[entryTitles objectAtIndex:cnt] stringValue]);
			NSLog(@"links=%@", [[links objectAtIndex:cnt] description]);
			*/
			
			//resultStr = [[[links objectAtIndex:cnt] description] substringFromIndex:12];
		
			NSArray* arr = [[[links objectAtIndex:cnt] description]
								   componentsSeparatedByString:[NSString stringWithFormat:@"%c", 0x22]];
			
			resultStr = [NSString stringWithFormat:@"%@%@", baseUrlStr, [arr objectAtIndex:1]];
		}
	}
	//NSLog(@"resultStr=%@", resultStr);
	if (resultStr == nil) {
		LOG_CURRENT_METHOD;
		NSLog(@"no root file found.");
		return nil;
	}
	
	return [NSURL URLWithString:resultStr];
}


#pragma mark - parse opds-Element.
- (NSMutableArray*)getOpdsElement:(NSURL *)elementUrl
{
#if defined(DEBUG_CREDENTIAL) && DEBUG_CREDENTIAL != 0
	LOG_CURRENT_METHOD;
	NSLog(@"elementUrl=%@", [elementUrl description]);
#endif
	
	//Set security infomation.
	NSDictionary* dict = [[ConfigViewController alloc] loadUsernameAndPasswordFromUserDefault];
	NSString* username = [dict valueForKey:USERNAME];
	NSString* password = [dict valueForKey:PASSWORD];
	
	//Get XML data from network.
	NSData *_data =[self getXmlFromUrl:elementUrl username:username password:password];
	
	//Prepare Parse.
	//NSError* error;
    DDXMLDocument* doc = [[[DDXMLDocument alloc] initWithData:_data options:0 error:nil] autorelease];  
	DDXMLElement *rootElement = [doc rootElement];
	//NSLog(@"doc=%@", [doc description]);
	//NSLog(@"root=%@", [root description]);
	
	//Add namespace to parser.
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"dc" stringValue:@"http://purl.org/dc/terms/"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"opds" stringValue:@"http://opds-spec.org/2010/catalog"]];
	[rootElement addNamespace:[DDXMLNode namespaceWithName:@"foo" stringValue:@"http://www.w3.org/2005/Atom"]];
	
	//Get each entry.
	NSError* error = nil;
	NSArray* entries = [rootElement nodesForXPath:@"//foo:entry" error:&error];
	//NSLog(@"entries=%@", [entries description]);
	
	//Get BASE URL for link.
	NSString* baseUrlStr = [ConfigViewController getUrlBaseWithOpds];
	
	//Parse.
	NSString* acquisitionLink = nil;
	NSString* sampleLink = nil;
	NSString* thumbnailLink = nil;
	NSMutableArray* thumbnailLinks = nil;
	NSString* coverLink = nil;
	NSUInteger contentId;
	NSMutableArray* linksUrlArray = [[NSMutableArray alloc] init];
	for (DDXMLElement* singleElement in entries){
		//NSLog(@"singleElement=%@", [singleElement description]);
		
		//Title
		NSArray* titleElement = [singleElement elementsForName:@"title"];
		NSString* titleStrTagged = [[titleElement objectAtIndex:0] description];
		NSString* titleStr = [[titleStrTagged stringByReplacingOccurrencesOfString:@"<title>" withString:@""]
							  stringByReplacingOccurrencesOfString:@"</title>" withString:@""];
		//NSLog(@"title=%@", titleStr );
		
		//Author
		NSArray* authorElement = [singleElement elementsForName:@"author"];
		NSString* authorStrTagged = [[authorElement objectAtIndex:0] description];
		NSString* authorStr = [[[[authorStrTagged stringByReplacingOccurrencesOfString:@"<author>" withString:@""]
								 stringByReplacingOccurrencesOfString:@"</author>" withString:@""]
								stringByReplacingOccurrencesOfString:@"<name>" withString:@""]
							   stringByReplacingOccurrencesOfString:@"</name>" withString:@""];
		//NSLog(@"author=%@", authorStr );
		
		//Description
		NSArray* descElement = [singleElement elementsForName:@"content"];
		NSString* descStrTagged = [[descElement objectAtIndex:0] description];
		NSString* descStr = [[descStrTagged stringByReplacingOccurrencesOfString:@"<content type=\"xhtml\"><div xmlns=\"http://www.w3.org/1999/xhtml\"><p>" withString:@""]
							 stringByReplacingOccurrencesOfString:@"</p></div></content>" withString:@""];
		//NSLog(@"desc=%@", descStr);
		
		//UUID
		//<id>urn:6cf3730c-7afb-441a-847f-d0bc84666b07</id>			<-Original server by Ruby On Rails. (incorrect format)
		//<id>urn:uuid:6cf3730c-7afb-441a-847f-d0bc84666b07</id>	<-Calibre. (correct format)
		NSArray* uuidElement = [singleElement elementsForName:@"id"];
		NSString* uuidStrTagged = [[uuidElement objectAtIndex:0] description];
		NSString* uuidStr = [[uuidStrTagged stringByReplacingOccurrencesOfString:@"<id>" withString:@""]
							  stringByReplacingOccurrencesOfString:@"</id>" withString:@""];
		NSArray* uuidTmp = [uuidStr componentsSeparatedByString:@":"];
		uuidStr = [uuidTmp lastObject];
		//NSLog(@"uuid=%@", uuidStr );
		
		//CID(only from RoR server)
		NSArray* cidElement = [singleElement elementsForName:@"contentid_in_server"];
		if (0 < [cidElement count]) {
			NSString* cidStrTagged = [[cidElement objectAtIndex:0] description];
			NSString* cidStr = [[cidStrTagged stringByReplacingOccurrencesOfString:@"<contentid_in_server>" withString:@""]
								stringByReplacingOccurrencesOfString:@"</contentid_in_server>" withString:@""];
			contentId = [cidStr intValue];
			//NSLog(@"contentId=%d", contentId);
		}
		
		//Links
		NSArray* links = [singleElement elementsForName:@"link"];
		thumbnailLinks = [[NSMutableArray alloc] init];
		sampleLink = nil;
		//NSLog(@"links=%@", [links description]);
		for (id e in links){
			NSString* relAttribute = [[e attributeForName:@"rel"] stringValue];
			NSString* hrefAttribute = [[e attributeForName:@"href"] stringValue];
			//NSLog(@"relAttribute=%@", relAttribute);
			//NSLog(@"hrefAttribute=%@", hrefAttribute);
			
			//Link for Acquisition.(buy)
			NSString* searchForMe = @"http://opds-spec.org/acquisition/buy";
			NSRange range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				acquisitionLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
			//Link for Sample Acquisition.(preview)
			searchForMe = @"http://opds-spec.org/acquisition/sample";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				sampleLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
			//Link for Acquisition.(old style)
			searchForMe = @"http://opds-spec.org/acquisition";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				acquisitionLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
			
			//Link for Thumbnail.
			searchForMe = @"http://opds-spec.org/thumbnail/";		// "thumbnail/{1..4}"
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				if ([hrefAttribute caseInsensitiveCompare:@"/assets/content/thumb_default.gif"] != NSOrderedSame) {
					[thumbnailLinks addObject:[NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute]];
				}
				continue;	//skip to next tag.
			}
			searchForMe = @"http://opds-spec.org/thumbnail";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				thumbnailLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
			searchForMe = @"http://opds-spec.org/image/thumbnail";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				thumbnailLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
			
			//Link for Cover.(old format server)
			searchForMe = @"http://opds-spec.org/cover";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				//get cover.
				coverLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				//get Cid.
				//convert "http://localhost/path/to/1.jpg" -> "1.jpg" -> "1"
				//
				NSString* coverFilename = [hrefAttribute lastPathComponent];
				NSString* coverId = [coverFilename stringByDeletingPathExtension];
				if ([coverId intValue] != 0) {
					contentId = [coverId intValue];
				}
				continue;	//skip to next tag.
			}
			//Link for Cover.(new format server)
			searchForMe = @"http://opds-spec.org/image/cover";
			range = [relAttribute rangeOfString : searchForMe];
			if (range.location != NSNotFound) {
				//get cover.
				coverLink = [NSString stringWithFormat:@"%@%@", baseUrlStr, hrefAttribute];
				continue;	//skip to next tag.
			}
		}
		
		//Store to Array.
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setValue:titleStr			forKey:CONTENT_TITLE];
		[tmpDict setValue:authorStr			forKey:CONTENT_AUTHOR];
		[tmpDict setValue:descStr			forKey:CONTENT_DESCRIPTION];
		[tmpDict setValue:sampleLink		forKey:CONTENT_SAMPLE_LINK];
		[tmpDict setValue:acquisitionLink	forKey:CONTENT_ACQUISITION_LINK];
		[tmpDict setValue:thumbnailLink		forKey:CONTENT_THUMBNAIL_LINK];
		[tmpDict setValue:thumbnailLinks	forKey:CONTENT_THUMBNAILS_LINK];
		[tmpDict setValue:coverLink			forKey:CONTENT_COVER_LINK];
		[tmpDict setValue:[NSNumber numberWithInteger:contentId] forKey:CONTENT_CID];
		[tmpDict setValue:uuidStr			forKey:CONTENT_UUID];
		[linksUrlArray addObject:tmpDict];
		[tmpDict release];
	}
	//NSLog(@"linksUrlArray=%@", [linksUrlArray description]);
	
	return linksUrlArray;
}

#pragma mark - common method.
//Needs port number for generate credential(NSURLProtectionSpace class).
- (NSData*)getXmlFromUrl:(NSURL*)url username:(NSString*)username password:(NSString*)password;
{
	NSNumber* targetPort = [url port];
	if (targetPort == 0) {
		targetPort = [NSNumber numberWithInt:HTTP_PORT_DEFAULT];
	}
	
#if defined(DEBUG_CREDENTIAL) && DEBUG_CREDENTIAL != 0
	LOG_CURRENT_METHOD;
	NSLog(@"url=%@, port=%d", [url description], [targetPort intValue]);
#endif
	
	//check XML exists.
	/*
	 NSString* feed = [[NSString alloc] initWithContentsOfURL:url];
	 if (feed == nil) {
	 NSLog(@"no feed found.");
	 return nil;
	 }
	 //NSLog(@"feed=%@", feed);
	 */
	NSHTTPURLResponse* res = nil;
	NSError* error = nil;
	
	//NSLog(@"username=%@", username);
	//NSLog(@"password=%@", password);
	//NSLog(@"host=%@", [url host]);
	if (username == nil || password == nil){
		NSLog(@"username or password is nil.");
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"username or password is nil."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		
		return nil;
	}
	
	NSURLCredential* credential = [NSURLCredential credentialWithUser:username //@"AbCd"
															 password:password //@"pass"
														  persistence:NSURLCredentialPersistencePermanent];
	
	/*
	 NSURLCredential* credential = [NSURLCredential credentialWithUser:@"AbCd"
	 password:@"pass"
	 persistence:NSURLCredentialPersistencePermanent];
	 */
	NSURLProtectionSpace* protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:[url host] //@"192.168.1.6" //@"192.168.1.8" //[url host] //@"localhost"
																				  port:[targetPort intValue]
																			  protocol:NSURLProtectionSpaceHTTP //@"http"
																				 realm:CREDENTIAL_REALM
																  authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
														forProtectionSpace:protectionSpace];
#if defined(DEBUG_CREDENTIAL) && DEBUG_CREDENTIAL != 0
	NSLog(@"credential = %@", [credential description]);
	NSLog(@"protectionSpace=%@, host=%@, port=%d", [protectionSpace description],
		  [protectionSpace host], [protectionSpace port]);
	NSLog(@"realm in protectionSpace=%@", [protectionSpace realm]);
	NSLog(@"protocol=%@", [protectionSpace protocol]);
	NSLog(@"receivesCredentialSecurely=%d(YES=%d,NO=%d)", [protectionSpace receivesCredentialSecurely], YES, NO);
	NSLog(@"distinguishedNames=%@", [[protectionSpace distinguishedNames] description]);
	NSLog(@"all credential=%@", [[[NSURLCredentialStorage sharedCredentialStorage] allCredentials] description]);
#endif
	
	[protectionSpace release];
	
	
	//Set timeout = 10s.
	NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	//
	NSData* data = [NSURLConnection sendSynchronousRequest:req
										 returningResponse:&res
													 error:&error];
	
	if (!data || error)
	{
		NSLog(@"url=%@", [url description]);
		NSLog(@"failed to get data. error=%@", [error localizedDescription]);
		
		NSString* errorMsg;
		if ([[error domain] isEqualToString:@"NSURLErrorDomain"]) {
			NSLog(@"error code=%d", [error code]);
			switch ([error code]) {
				case NSURLErrorCannotFindHost:
					errorMsg = NSLocalizedString(@"Cannot find specified host. Retype URL.", nil);
					break;
				case NSURLErrorCannotConnectToHost:
					errorMsg = NSLocalizedString(@"Cannot connect to specified host. Server may be down.", nil);
					break;
				case NSURLErrorNotConnectedToInternet:
					errorMsg = NSLocalizedString(@"Cannot connect to the internet. Service may not be available.", nil);
					break;
				case NSURLErrorUserCancelledAuthentication:
					errorMsg = [NSString stringWithFormat:@"Returned when an asynchronous request for authentication is cancelled by the user."];
					break;
				case NSURLErrorUserAuthenticationRequired:
					errorMsg = [NSString stringWithFormat:@"Returned when authentication is required to access a resource."];
					break;
				case NSURLErrorTimedOut:
					errorMsg = [error localizedDescription];
				default:
					errorMsg = [error localizedDescription];
					break;
			}
			return nil;	//Return nothing.
		} else {
			errorMsg = [error localizedDescription];
		}
		
		NSLog(@"error message=%@", errorMsg);
		NSLog(@"error domain=%@", [error domain]);
		return nil;
	}
	
	if (res) {
		NSLog(@"stat = %d", [(NSHTTPURLResponse*)res statusCode]);
	} else {
		NSLog(@"res is null");
	}
	
	return data;
	
	/*
	//load XML to NSData.
	NSData *_data = [NSData dataWithContentsOfURL:url];  

	return _data;
	*/
}


#pragma mark - Utility method.
- (BOOL)networkReachability
{
	return TRUE;	//
}
@end
