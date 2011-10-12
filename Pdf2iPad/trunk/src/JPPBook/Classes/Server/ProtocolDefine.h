//
//  ProtocolDefine.h
//  JPPBook
//
//  Created by okano on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
@protocol MyTableViewVCProtocol
- (void)reloadData;
//
- (void)didFinishParseOpdsRoot:(NSURL*)elementUrl;
- (void)didFailParseOpdsRoot;
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsElement;
@optional
- (void)didStartParseOpdsRoot;
- (void)didStartParseOpdsElement;
@end
/*
@protocol ContentListProtocol
- (void)didFinishParseOpds:(NSMutableArray*)resultArray;
@end

@protocol OpdsParserProtocol
- (void)didFinishParseOpdsRoot:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsRoot:(NSMutableArray*)resultArray;
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsElement:(NSMutableArray*)resultArray;
@end
*/