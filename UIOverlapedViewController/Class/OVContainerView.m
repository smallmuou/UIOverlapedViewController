//
//  OVContainerView.m
//  UIOverlapedViewController
//
//  Created by xuwf on 13-7-2.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "OVContainerView.h"
#import "UIView+Extension.h"

@implementation OVContainerView
@synthesize viewController = _viewController;
@synthesize originalWidth = _originalWidth;
@synthesize cornerRadius = _cornerRadius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (OVContainerView *)containerViewWithController:(UIViewController *)viewController {
    OVContainerView *view = [[OVContainerView alloc] initWithFrame:viewController.view.frame];
    view.viewController = viewController;
    return view;

}

- (void)setViewController:(UIViewController *)viewController {
    if (_viewController != viewController) {
        if (_viewController) {
            [_viewController.view removeFromSuperview];
        }
        _viewController = viewController;
        
        // properly embed view
        self.width = self.viewController.view.width;
        self.height = self.viewController.view.height;
        
        _viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _viewController.view.frame = CGRectMake(0, 0, self.width, self.height);
        [_viewController.view enableShadow];
        [self addSubview:_viewController.view];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)addMaskToCorners:(UIRectCorner)corners {
    // Re-calculate the size of the mask to account for adding/removing rows.
    CGRect frame = self.viewController.view.bounds;
    if([self.viewController.view isKindOfClass:[UIScrollView class]] && ((UIScrollView *)self.viewController.view).contentSize.height > self.viewController.view.frame.size.height) {
    	frame.size = ((UIScrollView *)self.viewController.view).contentSize;
    } else {
        frame.size = self.viewController.view.frame.size;
    }
    
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.viewController.view.layer.mask = maskLayer;
}

@end

@implementation UIViewController (OVContainerView)
- (OVContainerView *)containerView {
    return ([self.view.superview isKindOfClass:[OVContainerView class]] ? (OVContainerView *)self.view.superview : nil);
}

@end
