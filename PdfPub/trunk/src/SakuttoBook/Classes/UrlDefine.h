/*
 *  UrlDefine.h
 *  DowntownTokyo
 *
 *  Created by okano on 09/08/22.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

//Server.
//#define URL_BASE_OPDS_DEFAULT1		@"http://www2058uf.sakura.ne.jp:8080"
#define URL_BASE_OPDS_DEFAULT1		@"http://www5066ua.sakura.ne.jp"		/* Demo Server. */
//#define URL_BASE_OPDS_DEFAULT1		@"http://www7200uj.sakura.ne.jp"		/* Demo Server. */

//#define CREDENTIAL_REALM				@"Authorization Required"			/* Calibre. */
#define CREDENTIAL_REALM				@"Application"						/* SakuttoBook Server. */
//#define CREDENTIAL_REALM				@"Authentication"	/* DebugSakuttoBook Server(new). */

//
#define DEBUG_CREDENTIAL 0	/* 0:not debug, 1:show URL and credential infomation for OPDS. */

//
#define URL_SUFFIX_OPDS		@"/opds"
//
#define SUMMARY_DIR		@"contentList"
#define DETAIL_DIR		@"contentDetail"
#define BODY_DIR		@"contentBody"
//#define THUMBNAIL_CACHE_DIR	@"contentThumbnailCache"
#define COVER_CACHE_DIR	@"contentCoverCache"
//
#define CONTENT_LIST_NEWEST @"contentListNewest.xml"
#define CONTENT_LIST_FAVORITE @"contentListFavorite.xml"

//
//#define COMMENT_LIST_DIR	@"comment/view/"
#define COMMENT_LIST_DIR	@"comments/getByXml/"
#define COMMENT_POST_DIR	@"comments/postByXml/"
