
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       UIOverlapedViewController.m
 * @Abstract:   重叠视图控制器
 * @History:
 
 -2013-07-02 创建 by xuwf
 */

#import <QuartzCore/QuartzCore.h>
#import "UIOverlapedViewController.h"
#import "UIOverlapedViewControllerGlobal.h"
#import "OVContainerView.h"

#pragma mark - Constant

#define kDefaultLeftInset           (60)
#define kDefaultLargeLeftInset      (200)
#define kDefaultMiddleInset         (100)
#define kDefaultLargeMiddleInset    (200)

#define kDefaultNavigationBarHeight (45)

#define kOVAnimationPushDuration    (0.25f)
#define kOVAnimationPopDuration     (0.25f)

#define kOVSlideSpeedThreshold      (10)        /* 滑动速度阈值，但大于此值，则认为有效 */

typedef void(^OVSimpleBlock)(void);

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIOverlapedViewController private
@interface UIOverlapedViewController () <UIGestureRecognizerDelegate> {
    NSMutableArray*         _viewControllers;
    UIView*                 _maskView;
    UIPanGestureRecognizer* _panRecognizer;
    NSInteger               _lastDragOffset;
    
    CGFloat                 _originalLeftBeforeDrag;
    BOOL                    _shouldPopWhenDrag;
    
}
@property (nonatomic, strong) NSMutableArray* viewControllers;
@property (nonatomic, strong) UIPanGestureRecognizer* panRecognizer;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIOverlapedViewController implementation
@implementation UIOverlapedViewController
@synthesize rootViewController  = _rootViewController;
@synthesize topViewController   = _topViewController;
@synthesize firstViewController = _firstViewController;
@synthesize leftInset           = _leftInset;
@synthesize largeLeftInset      = _largeLeftInset;
@synthesize middleInset         = _middleInset;
@synthesize largeMiddleInset    = _largeMiddleInset;
@synthesize viewControllers     = _viewControllers;
@synthesize navigationBar       = _navigationBar;
@synthesize delegate            = _delegate;
@synthesize style               = _style;
@synthesize hidesNavigationBar  = _hidesNavigationBar;
@synthesize panRecognizer       = _panRecognizer;
@synthesize backBarButtonItemBackgroundImage = _backBarButtonItemBackgroundImage;
@synthesize backBarButtonTitleEdgeInset =_backBarButtonTitleEdgeInset;
@synthesize adjustPositionWhenNavigationBarShow = _adjustPositionWhenNavigationBarShow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController* )rootViewController withStyle:(UIOverlapedStyle)style {
    if ((self = [super init])) {
        _rootViewController = rootViewController;
        _viewControllers = [[NSMutableArray alloc] init];
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_maskView setBackgroundColor:[UIColor blackColor]];
        [_maskView setAlpha:0.5];
        [_maskView setUserInteractionEnabled:NO];
        [self.view addSubview:_maskView];
        [self.view sendSubviewToBack:_maskView];
        
        _style = style;
        
        /* set some reasonble defaults */
        _leftInset = kDefaultLeftInset;
        _largeLeftInset = kDefaultLargeLeftInset;
        _middleInset = kDefaultMiddleInset;
        _largeMiddleInset = kDefaultLargeMiddleInset;
        _adjustPositionWhenNavigationBarShow = YES;
        _hidesNavigationBar = NO;
        _backBarButtonTitleEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        /* navigation */
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kDefaultNavigationBarHeight)];
        _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_navigationBar enableShadow];
        
        /* gesture */
        [self configureGestureRecognizer];
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    _panRecognizer.delegate = nil;
    _panRecognizer = nil;
    _navigationBar = nil;
    
    // remove all view controllers the hard way (w/o calling delegate)
    while ([self.viewControllers count]) {
        [self popViewControllerAnimated:NO];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // embedding rootViewController
    if (self.rootViewController) {
        [self.view addSubview:self.rootViewController.view];
        [self addChildViewController:self.rootViewController];
        
        self.rootViewController.view.height = self.view.height;
        self.rootViewController.view.width = self.view.width;
        self.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0) {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0) {
    return UIInterfaceOrientationMaskAll;
}


- (void)handlePanGestureAction:(UIPanGestureRecognizer* )recognizer {
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    if ([self.viewControllers count] <= 2) return;
    [self stopOverlapedAnimation];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _lastDragOffset = 0;
            _shouldPopWhenDrag = NO;
            _originalLeftBeforeDrag = self.topViewController.containerView.left;
            break;
        case UIGestureRecognizerStateChanged: {
            NSInteger offset = translatedPoint.x - _lastDragOffset;
            _shouldPopWhenDrag = (offset > kOVSlideSpeedThreshold)?YES:NO;
            CGFloat newLeft = self.topViewController.containerView.left + offset;
            if (newLeft > _originalLeftBeforeDrag) {
                self.topViewController.containerView.left += offset;
            }
            
            _lastDragOffset = translatedPoint.x;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            /* 速度大于阈值或者滑动到view.width一半以上 */
            if ((self.topViewController.containerView.left - _originalLeftBeforeDrag) > self.topViewController.containerView.width/2 || _shouldPopWhenDrag){
                [self popViewControllerAnimated:YES];
            } else {
                [UIView animateWithDuration:kOVAnimationPushDuration animations:^{
                    self.topViewController.containerView.left = _originalLeftBeforeDrag;
                }];
            }
            break;
        default:
            break;
    }
}

- (void)configureGestureRecognizer
{
    [self.view removeGestureRecognizer:self.panRecognizer];
    
    // add a gesture recognizer to detect dragging to the guest controllers
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:NO];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
    self.panRecognizer = panRecognizer;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate

- (void)setDelegate:(id<UIOverlapedViewControllerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        
        _delegateFlags.delegateWillInsertViewController = [delegate respondsToSelector:@selector(stackedView:willInsertViewController:)];
        _delegateFlags.delegateDidInsertViewController = [delegate respondsToSelector:@selector(stackedView:didInsertViewController:)];
        _delegateFlags.delegateWillRemoveViewController = [delegate respondsToSelector:@selector(stackedView:willRemoveViewController:)];
        _delegateFlags.delegateDidRemoveViewController = [delegate respondsToSelector:@selector(stackedView:didRemoveViewController:)];
    }
}

- (void)delegateWillInsertViewController:(UIViewController *)viewController {
    if (_delegateFlags.delegateWillInsertViewController) {
        [self.delegate overlapedViewController:self willInsertViewController:viewController];
    }
}

- (void)delegateDidInsertViewController:(UIViewController *)viewController {
    if (_delegateFlags.delegateDidInsertViewController) {
        [self.delegate overlapedViewController:self didInsertViewController:viewController];
    }
}

- (void)delegateWillRemoveViewController:(UIViewController *)viewController {
    if (_delegateFlags.delegateWillRemoveViewController) {
        [self.delegate overlapedViewController:self willRemoveViewController:viewController];
    }
}

- (void)delegateDidRemoveViewController:(UIViewController *)viewController {
    if (_delegateFlags.delegateDidRemoveViewController) {
        [self.delegate overlapedViewController:self didRemoveViewController:viewController];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helpers
- (CGRect)viewRect {
    /* self.view.frame not used, it's wrong in viewWillAppear */
    CGRect viewRect = [[UIScreen mainScreen] applicationFrame];
    return viewRect;
}

/* return screen width */
- (CGFloat)screenWidth {
    CGRect viewRect = [self viewRect];
    CGFloat screenWidth = IsLandscape() ? viewRect.size.height : viewRect.size.width;
    return screenWidth;
}

/* return screen height */
- (CGFloat)screenHeight {
    CGRect viewRect = [self viewRect];
    NSUInteger screenHeight = IsLandscape() ? viewRect.size.width : viewRect.size.height;
    return screenHeight;
}

/* left border is depending on amount of VCs */
- (NSUInteger)currentLeftInset {
    NSUInteger lInset = self.largeLeftInset;
    NSUInteger mInset  = self.largeMiddleInset;
    NSUInteger count = [self.viewControllers count];
    
    if (self.style == UIOverlapedStyleOverlap) {
        lInset = (count == 0) ? lInset:self.leftInset;
        mInset = self.middleInset;
    }
    
    NSUInteger inset = lInset;
    
    if (count) {
        inset+=mInset;
    }
    
    return inset;
}

- (void)pushAnimatedWithView:(UIView* )view completion:(void (^)(BOOL finished))completion {
    CGFloat left = view.left;
    
    view.left = view.left+view.width;
    [UIView animateWithDuration:kOVAnimationPushDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        view.left = left;
    } completion:completion];
}

- (void)popAnimatedWithView:(UIView* )view completion:(void (^)())completion {
    [UIView animateWithDuration:kOVAnimationPushDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        view.left = view.left+view.width;
    } completion:^(BOOL finished){
        if (completion) completion();
    }];
}

- (void)fadeInAnimatedWithView:(UIView* )view completion:(void (^)(BOOL finished))completion {
    view.alpha = 0.f;
    view.transform = CGAffineTransformMakeScale(1.2, 1.2); // large but fade in
    
    [UIView animateWithDuration:kOVAnimationPushDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        view.alpha = 1.f;
        view.transform = CGAffineTransformIdentity;
    } completion:completion];
}

- (void)fadeOutAnimatedWithView:(UIView* )view completion:(void (^)())completion {
    [UIView animateWithDuration:kOVAnimationPopDuration delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        view.alpha = 0.f;
        view.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
    
}

- (void)stopOverlapedAnimation {
    // remove all current animations
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController *)obj;
        [vc.containerView.layer removeAllAnimations];
    }];
}

- (UIViewController *)topViewController {
    return [self.viewControllers lastObject];
}

- (UIViewController *)firstViewController {
    return [self.viewControllers count] ? [self.viewControllers objectAtIndex:0] : nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIOverlapedViewController (Public)

- (NSInteger)indexOfViewController:(UIViewController *)viewController {
    __block NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        index = [self.viewControllers indexOfObject:viewController.navigationController];
        if (index == NSNotFound) {
            [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UINavigationController class]] && ((UINavigationController *)obj).topViewController == viewController) {
                    index = idx;
                    *stop = YES;
                }
            }];
        }
    }
    return index;
}

/* returns current view controller in self.viewControllers */
- (UIViewController *)currentViewController:(UIViewController *)viewController {
    if(!viewController) return nil; // don't assert on mere menu events
    
    NSUInteger vcIndex = [self indexOfViewController:viewController];
    return [self.viewControllers objectAtIndex:vcIndex];
}

- (void)updateViewControllerMask {
    NSUInteger count = [self.viewControllers count];
    
    if (count == 2) {
        [self.view insertSubview:_maskView aboveSubview:self.rootViewController.view];
    } else if (count > 2) {
        [self.view insertSubview:_maskView aboveSubview:self.firstViewController.containerView];
    } else {
        [self.view sendSubviewToBack:_maskView];
    }
}

/* for UIOverlapedStyleOverlap */
- (void)updateFirstViewControllerPostionAnimated:(BOOL)animated {
    if (self.style == UIOverlapedStyleOverlap) {
        OVSimpleBlock finishBlock = ^{
            if ([self.viewControllers count] == 1) {
                self.firstViewController.containerView.left = self.largeMiddleInset;
            } else {
                self.firstViewController.containerView.left = self.leftInset;
            }
        };
        if (animated) {
            [UIView animateWithDuration:kOVAnimationPushDuration animations:finishBlock];
        } else finishBlock();
        
    }
}

/* get view controllers that are in stack _after_ current view controller */
- (NSArray *)viewControllersAfterViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController);
    NSUInteger index = [self indexOfViewController:viewController];
    if (NSNotFound == index) return nil;
    
    NSArray *array = nil;
    /* don't remove view controller we've been called with */
    if ([self.viewControllers count] > index + 1) {
        array = [self.viewControllers subarrayWithRange:NSMakeRange(index + 1, [self.viewControllers count] - index - 1)];
    }
    
    return array;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Push & Pop

- (void)pushViewController:(UIViewController* )viewController fromViewController:(UIViewController* )baseViewController animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    __block BOOL isTopViewController = YES;
    
    /* figure out where to push */
    if (baseViewController == self.rootViewController || baseViewController.navigationController == self.rootViewController) {
        [self popToRootViewControllerAnimated:NO];
        baseViewController = nil;
    }
    
    if (baseViewController) {
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj == baseViewController) {
                UIViewController *currentVC = [self currentViewController:obj];
                if (currentVC) {
                    if (currentVC != self.topViewController) isTopViewController = NO;
                    [self popToViewController:currentVC animated:animated];
                }else {
                    [self popToRootViewControllerAnimated:animated];
                }
                *stop = YES;
            }
        }];
    }
    
    animated = isTopViewController ? animated:NO;
    viewController.view.height = [self screenHeight];
    
    NSUInteger count = [self.viewControllers count];
    [self delegateWillInsertViewController:viewController];
    
    /* controller view is embedded into a container */
    OVContainerView *container = [OVContainerView containerViewWithController:viewController];
    container.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    container.left = [self currentLeftInset];
    container.width = [self screenWidth] - container.left;
    
    // relay willAppear and add to subview
    [viewController viewWillAppear:animated];
    
    [self.view addSubview:container];
    
    /* enable shadow */
    if (count <= 1) [container enableShadow];
    
    /* navigationBar */
    if (count >= 1) {
        _navigationBar.hidden = _hidesNavigationBar;
        UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:viewController.title];
        
        /* back button */
        if ([self.viewControllers count]>1) {
            NSString* title = (!self.topViewController.title || [self.topViewController.title isEqualToString:@""])?@"Back":self.topViewController.title;
            
            UIBarButtonItem* backBarButtonItem;
            
            /* custom */
            if (_backBarButtonItemBackgroundImage) {
                UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
                [button setBackgroundImage:_backBarButtonItemBackgroundImage forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
                [button addTarget:self action:@selector(onBackBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                button.height = _backBarButtonItemBackgroundImage.size.height;
                button.width = button.titleLabel.width+_backBarButtonTitleEdgeInset.left+_backBarButtonTitleEdgeInset.right;
                [button setTitleEdgeInsets:_backBarButtonTitleEdgeInset];
                backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            } else {
                backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(onBackBarButtonPressed:)];
            }
            
            navigationItem.leftBarButtonItem = backBarButtonItem;
        }
        [_navigationBar pushNavigationItem:navigationItem animated:YES];
        
        if ([self.view.subviews containsObject:_navigationBar]) {
            [self.view bringSubviewToFront:_navigationBar];
        } else {
            [self.view addSubview:_navigationBar];
        }
        
        _navigationBar.width = container.width;
        _navigationBar.left = container.left;
        
        if (!_navigationBar.hidden && _adjustPositionWhenNavigationBarShow) {
            container.top += _navigationBar.height;
        }
    }
    
    /* animation */
    if (animated) {
        if (count < 1) {
            [self fadeInAnimatedWithView:container completion:NULL];
        } else {
            [self pushAnimatedWithView:container completion:NULL];
        }
    }
    
    [container layoutIfNeeded];
    [viewController viewDidAppear:animated];
    
    /* Must be here */
    [self.viewControllers addObject:viewController];
    [self addChildViewController:viewController];
    
    /* update mask */
    [self updateFirstViewControllerPostionAnimated:animated];
    [self updateViewControllerMask];
    [self delegateDidInsertViewController:viewController];
}

- (void)setHidesNavigationBar:(BOOL)hidesNavigationBar {
    _hidesNavigationBar = hidesNavigationBar;
    _navigationBar.hidden = hidesNavigationBar;
    
    NSUInteger count = [self.viewControllers count];
    if (hidesNavigationBar) {
        for (NSUInteger i = 1; i < count; i++) {
            [[self.viewControllers objectAtIndex:i] containerView].top = 0;
        }
    } else {
        for (NSUInteger i = 1; i < count; i++) {
            CGFloat top = _adjustPositionWhenNavigationBarShow ? _navigationBar.height : 0;
            [[self.viewControllers objectAtIndex:i] containerView].top = top;
        }
    }
    
}

- (void)pushViewController:(UIViewController* )viewController animated:(BOOL)animated {
    [self pushViewController:viewController fromViewController:self.topViewController animated:animated];
}

- (void)onBackBarButtonPressed:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (UIViewController* )popViewControllerAnimated:(BOOL)animated {
    UIViewController *lastController = [self topViewController];
    if (lastController) {
        [self delegateWillRemoveViewController:lastController];
        
        NSUInteger count = [self.viewControllers count];
        
        // remove from view stack!
        OVContainerView *container = lastController.containerView;
        [lastController viewWillDisappear:animated];
        
        OVSimpleBlock finishBlock = ^{
            [container removeFromSuperview];
            [lastController viewDidDisappear:animated];
            [lastController removeFromParentViewController];
            [self delegateDidRemoveViewController:lastController];
        };
        
        /* Note: popNavigationItemAnimated must set animated to NO. or back item will discord */
        if (count>=2) [_navigationBar popNavigationItemAnimated:NO];
        if (count <= 2) [_navigationBar removeFromSuperview];
        
        /* animation */
        if (animated) {
            if (count < 2) {
                [self fadeOutAnimatedWithView:lastController.containerView completion:finishBlock];
            } else if ([self.viewControllers count]> 2) {
                [self popAnimatedWithView:lastController.containerView completion:finishBlock];
            } else {
                finishBlock();
            }
        } else {
            finishBlock();
        }
        
        [_viewControllers removeLastObject];
        
        [self updateFirstViewControllerPostionAnimated:animated];
        [self updateViewControllerMask];
    }
    
    return lastController;
}

- (NSArray* )popToViewController:(UIViewController* )viewController animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    NSUInteger index = [self indexOfViewController:viewController];
    if (NSNotFound == index) {
        return nil;
    }
    
    NSArray *controllersToRemove = [self viewControllersAfterViewController:viewController];
    [controllersToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self popViewControllerAnimated:animated];
    }];
    
    return controllersToRemove;
}

- (NSArray* )popToRootViewControllerAnimated:(BOOL)animated {
    NSMutableArray *array = [NSMutableArray array];
    while ([self.viewControllers count] > 0) {
        UIViewController *vc = [self popViewControllerAnimated:animated];
        [array addObject:vc];
    }
    return array;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /* prevent recognizing touches on the slider */
    if ([touch.view isKindOfClass:[UIControl class]]) return NO;
    return YES;
}


@end

@implementation UIViewController (UIOverlapedViewController)
- (UIOverlapedViewController* )overlapedViewController {
    if ([self.parentViewController isKindOfClass:[UIOverlapedViewController class]]) {
        return (UIOverlapedViewController*)self.parentViewController;
    } else if ([self.navigationController.parentViewController isKindOfClass:[UIOverlapedViewController class]]) {
        return (UIOverlapedViewController*)self.navigationController.parentViewController;
    } else {
        return nil;
    }
}

@end

