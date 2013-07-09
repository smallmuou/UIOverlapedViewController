//
//  sds.h
//  UIOverlapedViewController
//
//  Created by xuwf on 13-7-2.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       UIOverlapedViewControllerGlobal.h
 * @Abstract:
 * @History:
 
 -2013-07-02 创建 by xuwf
 */

#ifndef ALog
#define OVALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

#ifndef DLog
#ifdef DEBUG
#define OVDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif
#endif

#ifndef ULog
#ifdef DEBUG
#define ULog(fmt, ...) { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#define ULog(...)
#endif
#endif

#define IsIpad() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define AppStatusBarOrientation ([[UIApplication sharedApplication] statusBarOrientation])
#define IsPortrait()  UIInterfaceOrientationIsPortrait(AppStatusBarOrientation)
#define IsLandscape() UIInterfaceOrientationIsLandscape(AppStatusBarOrientation)
