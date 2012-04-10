/*
 *  UrlDefine.h
 *  DowntownTokyo
 *
 *  Created by okano on 09/08/22.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

//Debug server.
#define URL_BASE_OPDS_DEFAULT1			@"http://www5066ua.sakura.ne.jp:8080"
//JPPBook server.
//#define URL_BASE_OPDS_DEFAULT1			@"http://ns.jpp.co.jp:8080"
//Local server.
#define URL_BASE_OPDS_DEFAULT2			@"http://localhost:8080"


#define URL_SUFFIX_OPDS		@"/opds"
//
#define SUMMARY_DIR		@"contentList"
#define DETAIL_DIR		@"contentDetail"
#define BODY_DIR		@"contentBody"
#define THUMBNAIL_DIR	@"contentThumbnail"
#define COVER_CACHE_DIR	@"contentCoverCache"
//
#define CONTENT_LIST_NEWEST @"contentListNewest.xml"
#define CONTENT_LIST_FAVORITE @"contentListFavorite.xml"

//
//#define COMMENT_LIST_DIR	@"comment/view/"
#define COMMENT_LIST_DIR	@"comments/getByXml/"
#define COMMENT_POST_DIR	@"comments/postByXml/"
