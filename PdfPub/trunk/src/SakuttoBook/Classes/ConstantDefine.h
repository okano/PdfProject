//
//  ConstantDefine.h
//  SakuttoBook
//
//  Created by okano on 12/12/09.
//  Copyright 2012 Katsuhiko Okano All rights reserved.
//
//

#ifndef SakuttoBook_ConstantDefine_h
#define SakuttoBook_ConstantDefine_h

// for Page Animation.
#define MY_ANIMATION_KIND					@"MyAnimationKind"
#define MY_ANIMATION_KIND_PAGE_FROM_LEFT	@"PushFromLeft"
#define MY_ANIMATION_KIND_PAGE_FROM_RIGHT	@"PushFromRight"
#define MY_ANIMATION_KIND_FADE				@"Fade"
#define PAGE_ANIMATION_DURATION_NEXT	0.2f
#define PAGE_ANIMATION_DURATION_PREV	0.2f

#define PAGE_PROGRESSION_DIRECTION	@"page-progression-direction"
#define PAGE_PROGRESSION_DIRECTION_RTL	@"rtl"	/* 左から右（横組、 左綴じ）。通常、横書きの本の場合に指定（left-to-right）*/
#define PAGE_PROGRESSION_DIRECTION_LTR	@"ltr"	/*
rtl：右から左（縦組、右綴じ）。通常、縦書きの本の場合に指定（right-to-left） */

// for Pan Gesture.
#define PAN_DISTANCE_MINIMUM	100.0f

// for Page Image.
#define PAGE_FILE_PREFIX			@"Page_p"
#define PAGE_FILE_EXTENSION			@"png"

// for Page Image(small).
#define PAGE_FILE_SMALL_PREFIX		@"Page_Small_p"
#define PAGE_FILE_SMALL_EXTENSION	@"png"

// for Marker Pen.
#define MARKERPEN_ARRAY             @"MarkerPen_Array"  /* Top of data */
#define MARKERPEN_PAGE_NUMBER       @"MarkerPen_PageNumber"
#define MARKERPEN_POINT_ARRAY        @"MarkerPen_Line_Array" /* array of CGPointValue. */
#define MARKERPEN_LINE_POSITION_X	@"x"
#define MARKERPEN_LINE_POSITION_Y	@"y"
#define MARKERPEN_COMMENT           @"MarkerPen_Comment"

// for Thumnail Image.
#define THUMBNAIL_FILE_PREFIX		@"thumb_"
#define THUMBNAIL_FILE_EXTENSION	@"png"
#define THUMBNAIL_FILE_EXTENSION2	@"jpg"
#define THUMBNAIL_FILE_EXTENSION3	@"gif"

// for Cover Image.
#define COVER_FILE_PREFIX			@"Cover_"
#define COVER_FILE_EXTENSION		@"jpg"

// for Link Define.
#define LINK_DICT_KEY_URL	@"Url"
#define LINK_DICT_KEY_RECT	@"Rect"

// for Movie Define.
#define MD_PAGE_NUMBER		@"Movie_PageNumber"
#define MD_MOVIE_FILENAME	@"Movie_Filename"
#define MD_AREA_X			@"Movie_Area_X"
#define MD_AREA_Y			@"Movie_Area_Y"
#define MD_AREA_WIDTH		@"Movie_Area_Width"
#define MD_AREA_HEIGHT		@"Movie_Area_Height"

// for Mail Send.
#define MS_TO_ADDESSES		@"Mail_To_Addresses"
#define MS_CC_ADDESSES		@"Mail_Cc_Addresses"
#define MS_BCC_ADDESSES		@"Mail_Bcc_Addresses"
#define MS_SUBJECT			@"Mail_Subject"
#define MS_BODY				@"Mail_Body"

// for Sound Define.
#define SD_PAGE_NUMBER		@"Sound_PageNumber"
#define SD_SOUND_FILENAME	@"Sound_Filename"
#define SD_DELAY_TIME		@"Sound_Delay_Time"
#define SD_TERMINATE_MESSAGE	@"Sound_Terminate_Message"

// for PageJump Link.
#define PJ_PAGE_NUMBER		@"PageJumpLink_PageNumber"
#define PJ_PAGE_AREA_X		@"PageJumpLink_Area_X"
#define PJ_PAGE_AREA_Y		@"PageJumpLink_Area_Y"
#define PJ_PAGE_AREA_WIDTH	@"PageJumpLink_Area_Width"
#define PJ_PAGE_AREA_HEIGHT	@"PageJumpLink_Area_Height"
#define PJ_PAGE_JUMPTO		@"PageJumpLink_JumpTo"

// for InPage ScrollView Define.
#define IPSD_PAGE_NUMBER	@"InPageScrollView_PageNumber"
#define IPSD_AREA_X			@"InPageScrollView_Area_X"
#define IPSD_AREA_Y			@"InPageScrollView_Area_Y"
#define IPSD_AREA_WIDTH		@"InPageScrollView_Area_Width"
#define IPSD_AREA_HEIGHT	@"InPageScrollView_Area_Height"
#define IPSD_FILENAMES		@"InPageScrollView_Filenames"	//multi file(s).

// for Url Link with CSV.
#define ULWC_URL			@"UrlLinkWithCsv_URL"

// for TOC Define.
#define TOC_PAGE			@"Toc_Page"
#define TOC_LEVEL			@"Toc_Level"
#define TOC_TITLE			@"Toc_Title"
#define TOC_FILENAME		@"Toc_Filename"
//#define TOC_CELL_IMAGE		@"Toc_Cell_Image"

// for Bookmark.
#define BOOKMARK_MULTI_CONTENT	@"Bookmark_MultiContent"
#define BOOKMARK_ARRAY			@"Bookmark_Array"
#define BOOKMARK_PAGE_NUMBER	@"Bookmark_PageNumber"
#define BOOKMARK_PAGE_MEMO		@"Bookmark_PageMemo"

// for latest read page.
#define USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT @"Latest_Read_Page_MultiContent"
#define USERDEFAULT_LATEST_READ_PAGE @"Latest_Read_Page"

// for Information view.
#define DEFAULT_BOOK_SUPPORT_URL_PREFIX	@"http://www.google.co.jp/search?q="
#define PROGRAM_SUPPORT_URL			@"http://www.incunabula.co.jp/book/Sakutto/"

// for last assigned ContentId.
#define LAST_CONTENT_ID		@"Assigned_Last_ContentId"
#define FIRST_CONTENT_ID	1	/* 1-start */

#define CID_FOR_SINGLE_CONTENT	1
#define METADATA_PLIST_FILENAME	@"ContentMetadata.plist"

// for judge simulator device is changed. (to reset configuration for debug.)
#define LAST_LAUNCHED_DEVICE_ON_SIMULATOR	@"LastLaunchedDeviceOnSimulator"

//for const URL for OPDS.
#define URL_OPDS			@"UrlBaseWithOpds"

#endif
