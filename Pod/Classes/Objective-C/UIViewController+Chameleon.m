//
//  UIViewController+Chameleon.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UIViewController+Chameleon.h"
#import <objc/runtime.h>

#import "ChameleonConstants.h"
#import "ChameleonEnums.h"
#import "ChameleonMacros.h"

#import "NSArray+Chameleon.h"
#import "UIColor+Chameleon.h"
#import "UIViewController+Chameleon.h"
#import "UIView+ChameleonPrivate.h"
#import "UILabel+Chameleon.h"
#import "UIButton+Chameleon.h"
#import "UIAppearance+Swift.h"

@interface UIViewController ()

@property (readwrite) BOOL shouldContrast;
@property (readwrite) BOOL shouldUseLightContent;

@end

@implementation UIViewController (Chameleon)


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - Runtime

- (void)setShouldContrast:(BOOL)contrast {
    
    NSNumber *number = [NSNumber numberWithBool:contrast];
    objc_setAssociatedObject(self, @selector(shouldContrast), number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldContrast {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(shouldContrast));
    return [number boolValue];
}

- (void)setShouldUseLightContent:(BOOL)shouldUseLightContent {
    
    NSNumber *number = [NSNumber numberWithBool:shouldUseLightContent];
    objc_setAssociatedObject(self, @selector(shouldUseLightContent), number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldUseLightContent {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(shouldUseLightContent));
    return [number boolValue];
}

#pragma mark - Swizzling

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(preferredStatusBarStyle);
        SEL swizzledSelector = @selector(chameleon_preferredStatusBarStyle);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
            
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Methods


- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    
    if (statusBarStyle == UIStatusBarStyleContrast) {
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
        self.shouldContrast = YES;
        
    } else {
        
        if (statusBarStyle == UIStatusBarStyleLightContent) {
            
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
            self.shouldUseLightContent = YES;
            
        } else {
            
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
            self.shouldUseLightContent = NO;
        }
    }
    
    [self preferredStatusBarStyle];
}

- (UIStatusBarStyle)chameleon_preferredStatusBarStyle {
    
    [self chameleon_preferredStatusBarStyle];
    
    if (self.shouldContrast) {

        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        UIView *topView = [self.view findTopMostViewForPoint:CGPointMake(CGRectGetMidX(statusBarFrame), 2)];
        
        return [self contrastingStatusBarStyleForColor:topView.backgroundColor];
        
    } else {
        
        if (self.shouldUseLightContent) {
            return UIStatusBarStyleLightContent;
            
        } else {
            return [self chameleon_preferredStatusBarStyle];
        }
    }
}

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
                 withContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor contentStyle:contentStyle];
    [[self class] customizeButtonWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeNavigationBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
}

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                  andContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor contentStyle:contentStyle];
    [[self class] customizeButtonWithPrimaryColor:primaryColor secondaryColor:secondaryColor withContentStyle:contentStyle];
    [[self class] customizeNavigationBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
}

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                    usingFontName:(NSString *)fontName
                  andContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setSubstituteFontName:fontName];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setSubstituteFontName:fontName];
    
    [[self class] customizeButtonWithPrimaryColor:primaryColor secondaryColor:secondaryColor withContentStyle:contentStyle];
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor fontName:fontName fontSize:18 contentStyle:contentStyle];
    [[self class] customizeNavigationBarWithBarColor:primaryColor textColor:ContrastColor(primaryColor, YES) fontName:fontName fontSize:20 buttonColor:ContrastColor(primaryColor, YES)];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withFontName:fontName withFontSize:14 withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
}

#pragma mark - UIBarButtonItem

+ (UIColor *)contentColorForPrimaryColor:(UIColor *)primaryColor
                            contentStyle:(UIContentStyle)contentStyle {
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    return contentColor;
}

+ (void)customizeBarButtonItemWithPrimaryColor:(UIColor *)primaryColor
                                  contentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:primaryColor];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class], [self class]]] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [self class]]] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [self class]]] setTintColor:contentColor];
}

+ (void)customizeBarButtonItemWithPrimaryColor:(UIColor *)primaryColor
                                      fontName:(NSString *)fontName
                                      fontSize:(float)fontSize
                                  contentStyle:(UIContentStyle)contentStyle {
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [self customizeBarButtonItemWithPrimaryColor:primaryColor contentStyle:contentStyle];

    if ([UIFont fontWithName:fontName size:fontSize]) {
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{ NSForegroundColorAttributeName:contentColor, NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    }
}

#pragma mark - UIButton

+ (void)customizeButtonWithPrimaryColor:(UIColor *)primaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundColor:primaryColor];
    
    
    [[UIButton  appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class], [self class]]] setTintColor:contentColor];
    [[UIButton  appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIStepper class], [self class]]] setTintColor:primaryColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIStepper class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleShadowColor:ClearColor forState:UIControlStateNormal];
    
}

+ (void)customizeButtonWithPrimaryColor:(UIColor *)primaryColor
                         secondaryColor:(UIColor *)secondaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    UIColor *secondaryContentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            secondaryContentColor = ContrastColor(secondaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            secondaryContentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            secondaryContentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            secondaryContentColor = ContrastColor(secondaryColor, NO);
            break;
        }
    }
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:secondaryContentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundColor:secondaryColor];
    
    
    [[UIButton  appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class], [self class]]] setTintColor:contentColor];
    [[UIButton  appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIStepper class], [self class]]] setTintColor:primaryColor];
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIStepper class], [self class]]] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleShadowColor:ClearColor forState:UIControlStateNormal];
    
}

#pragma mark - UIImagePickerController

+ (void)customizeImagePickerControllerWithPrimaryColor:(UIColor *)primaryColor withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    //Workaround for Swift http://stackoverflow.com/a/28765193
    [[UIButton appearanceWhenContainedWithin:@[[UIView class],[UIImagePickerController class],[self class]]] setBackgroundColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UIView class],[UIImagePickerController class],[self class]]] setTintColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UINavigationBar class],[UIImagePickerController class],[self class]]] setBackgroundColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UINavigationBar class],[UIImagePickerController class],[self class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedWithin:@[[UITableViewCell class],[UIImagePickerController class],[self class]]] setBackgroundColor:ClearColor];
    
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIView class],[UIImagePickerController class],[self class]] setBackgroundColor:ClearColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIView class],[UIImagePickerController class],[self class]] setTintColor:contentColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class],[UIImagePickerController class],[self class]] setBackgroundColor:ClearColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class],[UIImagePickerController class],[self class]] setTintColor:contentColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class],[UIImagePickerController class]] setBackgroundColor:ClearColor];
}

#pragma mark - UILabel

+ (void)customizeLabelWithPrimaryColor:(UIColor *)primaryColor
                              fontName:(NSString *)fontName
                              fontSize:(CGFloat)fontSize
                      withContentStyle:(UIContentStyle)contentStyle {
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setTextColor:contentColor];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setTextColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    if (font) {
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setFont:[UIFont fontWithName:fontName size:fontSize]];
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class], [UITextField class]]] setFont:[UIFont fontWithName:fontName size:14]];
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[self class], [UIButton class]]] setFont:[UIFont fontWithName:fontName size:18]];
    }
}

#pragma mark - UINavigationBar

+ (void)customizeNavigationBarWithPrimaryColor:(UIColor *)primaryColor
                              withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:primaryColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:contentColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{NSForegroundColorAttributeName:contentColor}];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:barColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:buttonColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{NSForegroundColorAttributeName:textColor}];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                                  fontName:(NSString *)fontName
                                  fontSize:(CGFloat)fontSize
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:barColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:buttonColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    if ([UIFont fontWithName:fontName size:fontSize]) {
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize] }];
    }
}

#pragma mark - UIPageControl

+ (void)customizePageControlWithPrimaryColor:(UIColor *)primaryColor
                            withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];
    
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setCurrentPageIndicatorTintColor:primaryColor];
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setPageIndicatorTintColor:[primaryColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
}

#pragma mark - UIProgressView

+ (void)customizeProgressViewWithPrimaryColor:(UIColor *)primaryColor
                             withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setProgressTintColor:primaryColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setProgressTintColor:contentColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setProgressTintColor:contentColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeProgressViewWithPrimaryColor:(UIColor *)primaryColor
                            andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

#pragma mark - UISearchBar

+ (void)customizeSearchBarWithPrimaryColor:(UIColor *)primaryColor withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UISearchBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:primaryColor];
    [[UISearchBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundColor:primaryColor];
    [[UISearchBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:contentColor];
    [[UISearchBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

#pragma mark - UISegmentedControl

+ (void)customizeSegmentedControlWithPrimaryColor:(UIColor *)primaryColor
                                 withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]]
     setTintColor:contentColor];
}

+ (void)customizeSegmentedControlWithPrimaryColor:(UIColor *)primaryColor
                                     withFontName:(NSString *)fontName
                                     withFontSize:(CGFloat)fontSize
                                 withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]]
     setTintColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{NSFontAttributeName:font}
                                                                                        forState:UIControlStateNormal];
    }
}

#pragma mark - UISlider

+ (void)customizeSliderWithPrimaryColor:(UIColor *)primaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setMinimumTrackTintColor:primaryColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setMinimumTrackTintColor:contentColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setMinimumTrackTintColor:contentColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeSliderWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

#pragma mark - UIStepper

+ (void)customizeStepperWithPrimaryColor:(UIColor *)primaryColor
                        withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    
    [[UIStepper appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:primaryColor];
    [[UIStepper appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]]
     setTintColor:contentColor];
    [[UIStepper appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]]
     setTintColor:contentColor];
}

#pragma mark - UISwitch

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor {
    
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setOnTintColor:primaryColor];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class],[UINavigationBar class]]] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class],[UIToolbar class]]] setOnTintColor:secondaryColor];
}

#pragma mark - UITabBar

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                           andTintColor:(UIColor *)tintColor {
    
    [[UITabBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:barTintColor];
    [[UITabBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:tintColor];
}

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                              tintColor:(UIColor *)tintColor
                               fontName:(NSString *)fontName
                               fontSize:(CGFloat)fontSize {
    
    [[UITabBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:barTintColor];
    [[UITabBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:tintColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTitleTextAttributes:@{NSFontAttributeName:font}
                                                                                  forState:UIControlStateNormal];
    }
}

#pragma mark - UIToolbar

+ (void)customizeToolbarWithPrimaryColor:(UIColor *)primaryColor
                        withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor = [self contentColorForPrimaryColor:primaryColor contentStyle:contentStyle];

    [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setTintColor:contentColor];
    [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:primaryColor];
    [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setClipsToBounds:YES];
}


#pragma mark - Private Methods

- (UIStatusBarStyle)contrastingStatusBarStyleForColor:(UIColor *)backgroundColor {
    
    //Calculate Luminance
    CGFloat luminance;
    CGFloat red, green, blue;
    
    //Check for clear or uncalculatable color and assume white
    if (![backgroundColor getRed:&red green:&green blue:&blue alpha:nil]) {
        return UIStatusBarStyleDefault;
    }
    
    //Relative luminance in colorimetric spaces - http://en.wikipedia.org/wiki/Luminance_(relative)
    red *= 0.2126f; green *= 0.7152f; blue *= 0.0722f;
    luminance = red + green + blue;
    
    return (luminance > 0.6f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma GCC diagnostic pop

@end
