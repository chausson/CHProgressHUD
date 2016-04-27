//
//  CHProgressHUD.h
//  CHProgressHUDDemo
//
//  Created by Chausson on 16/4/8.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol CHProgressHUDDelegate;


typedef NS_ENUM(NSInteger, CHProgressHUDMode) {
    /** Progress is shown using an UIActivityIndicatorView. This is the default. */
    CHProgressHUDModeActivityIndicator,
    /** Shows a custom view */
    CHProgressHUDModeCustomView,
    /** Shows only labels */
    CHProgressHUDModeText // 显示文本
};
#if NS_BLOCKS_AVAILABLE
typedef void (^CHProgressHUDCompletionBlock)();
#endif
@interface CHProgressHUD : UIView

+ (void)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

+ (void)showAnimated:(BOOL)animated completionBlock:(CHProgressHUDCompletionBlock)completion;

+ (void)show:(BOOL)animated;

+ (void)hide:(BOOL)animated;

+ (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay
                            completionBlock:(CHProgressHUDCompletionBlock)completion;
/**
 * Please use CHProgressHUD Method Setup CutomView , it is only support one customView.
 */
+ (void)setCustomView:(UIView *)customView;
/**
 * The HUD style depend on mode .
 */
+ (void)setMode:(CHProgressHUDMode )mode;
/**
 *  Changed HUD of background .
 */
+ (void)setColor:(UIColor *)color;
/**
 *  Changed CornerRadius  of HUD .Defaults to 10.0.
 */
+ (void)setCornerRadius:(float)cornerRadius;
/**
 *  Changed LabelFont of HUD TEXT IN  CHProgressHUDModeText .Defaults is 13font.
 */
+ (void)setLabelFont:(UIFont *)labelFont;
/**
 *  Changed LabelColor of HUD TEXT IN  CHProgressHUDModeText .Defaults is white.
 */
+ (void)setLabelColor:(UIColor *)labelColor;
/**
 *  Changed HUD  of ActivityIndicatorColor .Defaults is White Color;
 */
+ (void)setActivityIndicatorColor:(UIColor *)color;
/**
 *  Changed HUD  of opacity. Defaults to 0.8 (80% opacity).
 */
+ (void)setOpacity:(float)opacity;
/**
 * the labelText will be showed in CHProgressHUDModeText
 * The  defults line is 2.
 */
+ (void)setLabelText:(NSString *)labelText;
/**
 * The  defults margin is 20.0f.deprecated on this version
 */
+ (void)setMargin:(CGFloat)margin NS_DEPRECATED_IOS(2_0, 9_0);
@end
