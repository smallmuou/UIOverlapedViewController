/*!
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
 * @File:       UIOverlapedViewController.h
 * @Abstract:   重叠视图控制器
 * @History:
 
 -2013-07-02 创建 by xuwf
 */

#import <UIKit/UIKit.h>

enum {
    UIOverlapedStyleSlice     = 0,    /* 切片样式，不缩进 */
    UIOverlapedStyleOverlap   = 1,    /* 重叠样式，有缩进 */
};
typedef NSInteger UIOverlapedStyle;

@class UIOverlapedViewController;
@protocol UIOverlapedViewControllerDelegate <NSObject>
@optional

/* viewController will be inserted */
- (void)overlapedViewController:(UIOverlapedViewController *)overlapedViewController willInsertViewController:(UIViewController* )viewController;

/* viewController has been inserted */
- (void)overlapedViewController:(UIOverlapedViewController *)overlapedViewController didInsertViewController:(UIViewController* )viewController;

/* viewController will be removed */
- (void)overlapedViewController:(UIOverlapedViewController *)overlapedViewController willRemoveViewController:(UIViewController* )viewController;

/* viewController has been removed */
- (void)overlapedViewController:(UIOverlapedViewController *)overlapedViewController didRemoveViewController:(UIViewController* )viewController;
@end


@interface UIOverlapedViewController : UIViewController {
    @package
    
    id __weak           _delegate;
    UIOverlapedStyle    _style;
    UIViewController*   _rootViewController;
    UIViewController*   _topViewController;
    UIViewController*   _firstViewController;
    NSUInteger          _leftInset;
    NSUInteger          _largeLeftInset;
    NSUInteger          _middleInset;
    NSUInteger          _largeMiddleInset;
    BOOL                _hidesNavigationBar;
    BOOL                _adjustPositionWhenNavigationBarShow;
    UINavigationBar*    _navigationBar;
    UIImage*            _backBarButtonItemBackgroundImage;
    UIEdgeInsets        _backBarButtonTitleEdgeInset;
    
    struct {
        unsigned int delegateWillInsertViewController:1;
        unsigned int delegateDidInsertViewController:1;
        unsigned int delegateWillRemoveViewController:1;
        unsigned int delegateDidRemoveViewController:1;
    }_delegateFlags;
}

/** 
 the root controller gets the whole background view
 style enum UIOverlapedStyle
 */
- (id)initWithRootViewController:(UIViewController* )rootViewController withStyle:(UIOverlapedStyle)style;

/** 
 Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
 baseViewController is used to remove subviews if a previous controller invokes a new view. can be nil. 
 */
- (void)pushViewController:(UIViewController* )viewController fromViewController:(UIViewController* )baseViewController animated:(BOOL)animated;

/* pushes the view controller, sets the last current vc as parent controller */
- (void)pushViewController:(UIViewController* )viewController animated:(BOOL)animated;

/* remove top view controller from stack, return it */
- (UIViewController* )popViewControllerAnimated:(BOOL)animated;

/* remove view controllers until 'viewController' is found */
- (NSArray* )popToViewController:(UIViewController* )viewController animated:(BOOL)animated;

/* removes all view controller */
- (NSArray* )popToRootViewControllerAnimated:(BOOL)animated;

/* event delegate */
@property (nonatomic, weak) id<UIOverlapedViewControllerDelegate> delegate;

/* style */
@property (nonatomic, readonly) UIOverlapedStyle style;

/* root view controller, always displayed behind stack */
@property (nonatomic, strong, readonly) UIViewController* rootViewController;

/* The top(last) view controller on the stack */
@property (nonatomic, strong, readonly) UIViewController* topViewController;

/* first view controller */
@property (nonatomic, strong, readonly) UIViewController* firstViewController;

/**
    RootVC              MiddleVC            DetailVC
 ___________________________________________________________
 |             |    |          |         |                  |
 |             |    |          |         |                  |
 |             |    |          |         |                  |
 |<-largeLeftInset->|<-largeMiddleInset->|                  |
 |<-leftInset->|<-middleInset->|         |                  |
 |             |    |          |         |                  |
 |             |    |          |         |                  |
 |             |    |          |         |                  |
 |_____________|____|__________|_________|__________________|
 */

/**
 left inset thats always visible. Defaults to 60.
 Note: only available for UIOverlapedStyleOverlap 
 */
@property (nonatomic, assign) NSUInteger leftInset;

/* large left inset. is visible to show you the full menu width. Defaults to 200 */
@property (nonatomic, assign) NSUInteger largeLeftInset;

/**
 middle inset thats always visible. Defaults to 60.
 Note: only available for UIOverlapedStyleOverlap
 */
@property (nonatomic, assign) NSUInteger middleInset;

/* large left inset. is visible to show you the full middle width. Defaults to 200 */
@property (nonatomic, assign) NSUInteger largeMiddleInset;

/* navigation bar. for custom bar background */
@property (nonatomic, strong, readonly) UINavigationBar* navigationBar;

/* hides navigation bar */
@property (nonatomic, assign) BOOL hidesNavigationBar;

/* back bar button background */
@property (nonatomic, strong) UIImage* backBarButtonItemBackgroundImage;

/* back bar button title edge inset. Defaults:(0, 0, 0, 0) */
@property (nonatomic, assign) UIEdgeInsets backBarButtonTitleEdgeInset;

/**
 adjust view position when navigation bar show.
 YES view's top add navigation bar height
 NO  view's top is set to 0
 */
@property (nonatomic, assign) BOOL adjustPositionWhenNavigationBarShow;

@end

@interface UIViewController (UIOverlapedViewController)
@property (nonatomic, readonly, strong) UIOverlapedViewController *overlapedViewController;
@end
