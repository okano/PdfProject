/*
 *  Define.h
 *  SakuttoBook
 *
 *  Created by okano on 10/12/13.
 *  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
 *
 */
#import "ConstantDefine.h"

//Vertical/Horizon mode in default. (is overwrited by pdfDefine.csv)
#define IS_VERTICAL_PDF 1		/* 0:yokogaki, 1:tategaki*/

//Page Transition with Slide/Curl.
#define IS_TRANSITION_CURL 0	/* 0:Slide, 1:Curl*/

//Page background color.
#define PAGE_BACKGROUND_COLOR_R		0.0f	/* 0.0f - 1.0f */
#define PAGE_BACKGROUND_COLOR_G		0.0f	/* 0.0f - 1.0f */
#define PAGE_BACKGROUND_COLOR_B		0.0f	/* 0.0f - 1.0f */

//Page Transition Enable/Disable with tap left&right side.
#define ENABLED_TRANSITION 1	/* 0:transition disable, 1:enable(normal) */

//Use Multi contents.
#define IS_MULTI_CONTENTS	1	/* 0:single content, 1:multi contents */

//Use content list with Image.
#define IS_CONTENTLIST_WITH_IMAGE	1	/* 0:list with table, 1:list with image */

//Hide Infomation button on Menu bar.
#define HIDE_INFOMATION_BUTTON 0	/* 0:show, 1:hide */

//Hide Server button on Menu bar.
#define HIDE_SERVER_BUTTON 0	/* 0:show, 1:hide */

//Hide Restore button in Payment History View.
#define HIDE_RESTORE_BUTTON 0	/* 0:show, 1:hide */

//Overwrite productIdList.csv by server data.
#define OVERWRITE_PRODUCTIDLIST_BY_SERVER	0	/* 0:save original data, 1:overwrite by server data */

//Setting how to open URL link.
#define OPEN_URL_WITH	0	/* 0:ask everytime, 1:open in this application, 2:open with Safari(close this application) */

// Tap area. (0.00 - 1.00) (1.00 is "fit to screen")
#define TAP_AREA_LEFT_X			0.00f
#define TAP_AREA_LEFT_Y			0.15f
#define TAP_AREA_LEFT_WIDTH		0.40f
#define TAP_AREA_LEFT_HEIGHT	1.00f
#define TAP_AREA_RIGHT_X		0.60f
#define TAP_AREA_RIGHT_Y		0.15f
#define TAP_AREA_RIGHT_WIDTH	0.40f
#define TAP_AREA_RIGHT_HEIGHT	1.00f
#define TAP_AREA_TOP_X			0.00f
#define TAP_AREA_TOP_Y			0.00f
#define TAP_AREA_TOP_WIDTH		1.00f
#define TAP_AREA_TOP_HEIGHT		0.15f
#define TAP_AREA_BOTTOM_X		0.00f
#define TAP_AREA_BOTTOM_Y		0.85f
#define TAP_AREA_BOTTOM_WIDTH	1.00f
#define TAP_AREA_BOTTOM_HEIGHT	0.15f

// for cache image.
#define CACHE_IMAGE_WIDTH_MIN		 320.0f
#define CACHE_IMAGE_WIDTH_MAX		1536.0f
#define CACHE_IMAGE_SMALL_WIDTH				 100.0f

// for Marker Pen.
#define MARKERPEN_LINE_COLOR_R		0.85f
#define MARKERPEN_LINE_COLOR_G		0.85f
#define MARKERPEN_LINE_COLOR_B		0.2f
#define MARKERPEN_LINE_COLOR_ALPHA	0.85f
#define MARKERPEN_LINE_WIDTH		2.0f

//
#define USERNAME			@"UserName"
#define PASSWORD			@"PassWord"
#define USERNAME_DEFAULT	@"user"
#define PASSWORD_DEFAULT	@"password"
#define HTTP_PORT_DEFAULT	80

// license key.
#define LICENSE_KEY @"99840053-0000-0000-0008-000000000000"
