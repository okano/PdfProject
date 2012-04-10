//
//  Define.h
//
//  Created by hisaboh on 08/12/06.
//  Copyright 2008 "Hisanaga MAKINO"<hisaboh@yher.net>. All rights reserved.
//

/*
#ifdef DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#  define LOG_CURRENT_METHOD NSLog(NSStringFromSelector(_cmd))
#else
#  define LOG(...) ;
#  define LOG_CURRENT_METHOD ;
#endif
*/

#define APPLICATION_TMP_DIR	[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define APPLICATION_DOC_DIR	[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"]
