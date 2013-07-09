
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       UIView+Extension.h
 * @Abstract:   UIView 扩展
 * @History:
 
 -2013-07-02 创建 by xuwf
 */

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

- (void)enableShadow;

@end
