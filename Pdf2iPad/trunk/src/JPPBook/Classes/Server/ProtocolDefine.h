//
//  ProtocolDefine.h
//  JPPBook
//
//  Created by okano on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
@protocol MyTableViewVCProtocol
- (void)reloadData;
@end

@protocol ContentListProtocol
- (void)didFinishParseOpds:(NSMutableArray*)resultArray;
@end

@protocol OpdsParserProtocol
- (void)didFinishParseOpdsRoot:(NSMutableArray*)resultArray;
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray;
@end
