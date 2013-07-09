//
//  OVContainerView.h
//  UIOverlapedViewController
//
//  Created by xuwf on 13-7-2.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OVContainerView : UIScrollView {
    UIViewController*   _viewController;
    CGFloat             _cornerRadius;
}

+ (OVContainerView *)containerViewWithController:(UIViewController *)viewController;


@property (nonatomic, strong) UIViewController* viewController;
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

@end

@interface UIViewController (OVContainerView)
- (OVContainerView *)containerView;
@end
