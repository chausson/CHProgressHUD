//
//  CHProgressHUD.m
//  CHProgressHUDDemo
//
//  Created by Chausson on 16/4/8.
//  Copyright © 2016年 Chausson. All rights reserved.
//
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define CH_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define CH_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define CH_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define CH_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    #define CH_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
        boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
        attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
//#else
//    #define CH_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
//    sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
//#endif

#import "CHProgressHUD.h"
@interface CHProgressHUD () {
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    UILabel *label;
    UILabel *detailsLabel;
    BOOL isFinished;
    CGAffineTransform rotationTransform;
}
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) NSTimeInterval textDuration;
@property (atomic, strong) UIView *indicator;
@property (atomic, strong) NSTimer *graceTimer;
@property (atomic, strong) NSTimer *minShowTimer;
@property (atomic, strong) NSDate *showStarted;

/**
 *  The default View to be shown is Activity
 *
 * @see CHProgressHUDMode
 */
@property (assign) CHProgressHUDMode mode;

/**
 * The UIView (e.g., a UIImageView) to be shown when the HUD is in CHProgressHUDModeCustomView.
 */
@property (strong ) UIView *customView;

/**
 * An optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text. If the text is too long it will get clipped by displaying "..." at the end. If left unchanged or
 * set to @"", then no message is displayed.
 */
@property (copy ) NSString *labelText;

@property (copy ) CHProgressHUDCompletionBlock completionBlock;
/**
 * The opacity of the HUD window. Defaults to 0.8 (80% opacity).
 * If you set the color ,opacity is invalid.Plese set the color aplha.
 */
@property (assign ) float opacity;
/**
 * The color of the HUD window. Defaults to black. If this property is set, color is set using
 * this UIColor and the opacity property is not used.  using retain because performing copy on
 * UIColor base colors (like [UIColor greenColor]) cause problems with the copyZone.
 */
@property (strong ) UIColor *color;

@property (strong ) UIColor *labelColor;
/**
 * The actual size of the HUD bezel.
 */
@property (atomic, assign) CGSize size;

@property (strong ) UIFont* labelFont;

@property (strong ) CABasicAnimation *animation;

@property (strong ) UIColor *activityIndicatorColor;
/**
 * The corner radius for the HUD
 * Defaults to 10.0
 */
@property (assign ) float cornerRadius;
@property (assign ) float margin;
@end

static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 14.f;
//static const CGFloat kDetailsLabelFontSize = 12.f;

@implementation CHProgressHUD
#pragma mark - Lifecycle
+ (CHProgressHUD *)sharedHUD {
    static dispatch_once_t once;
    
    static CHProgressHUD *sharedHUD;

    dispatch_once(&once, ^{ sharedHUD = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
//#else
//    dispatch_once(&once, ^{ sharedHUD = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
//#endif
    return sharedHUD;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opacity = 0.8f;
        self.color = nil;
        self.labelFont = [UIFont systemFontOfSize:kLabelFontSize];
        self.labelColor = [UIColor whiteColor];
        self.cornerRadius = 10.0f;
        self.margin = 20.0f;
        self.xOffset = 0.0f;
        self.yOffset = 0.0f;
        self.textDuration = 1.5;
        self.activityIndicatorColor = [UIColor whiteColor];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible for now
        self.alpha = 0.0f;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeCenter;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
								| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        rotationTransform = CGAffineTransformIdentity;
        label = [[UILabel alloc]init];
        label.textAlignment  = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        
        [self updateIndicators];
        [self registerForKVO];
    }
    
    return self;
}
#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.xOffset = 0.0f;
    self.yOffset = 0.0f;
    // Entirely cover the parent view
    UIView *parent = self.superview;
//    if (!parent) {
        self.frame =  parent.bounds;
//    }
    CGRect bounds = self.bounds;
    
    // Determine the total width and height needed
    CGFloat maxWidth = bounds.size.width - 4 * self.margin;
    CGSize totalSize = CGSizeZero;
    
    
    CGRect indicatorF = self.indicator.bounds;
    indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
    totalSize.width = MAX(totalSize.width, indicatorF.size.width);
    totalSize.height += indicatorF.size.height;
    // Position elements
    CGFloat yPos = 0.0f;
    CGFloat xPos = 0.0f;
    yPos = self.center.y-indicatorF.size.height/2;
    if (parent) {
         yPos = self.superview.frame.size.height/2-indicatorF.size.height/2;
    }

    indicatorF.origin.y = yPos;
    indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) + xPos;
    self.indicator.frame = indicatorF;
  
    totalSize.width += 2 * self.margin;
    totalSize.height += 2 * self.margin;
    if ([self  isNeedShowLabel]) {
        CGFloat remainingHeight = bounds.size.height - totalSize.height - kPadding - 4 * self.margin;
        CGSize maxSize = CGSizeMake(maxWidth, remainingHeight);
        CGSize labelSize = CH_MULTILINE_TEXTSIZE(self.labelText, self.labelFont, maxSize, detailsLabel.lineBreakMode);
        CGRect labelF;
        CGFloat labelY;

        labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) + xPos;
        labelF.size = labelSize;
        if(self.mode == CHProgressHUDModePlainText){
            labelY = self.center.y;
            totalSize.height = labelSize.height +2*kPadding;
        }else{
            labelY = CGRectGetMaxY(self.indicator.frame)+kPadding;
        }
  
        labelF.origin.y = labelY;
        label.frame = labelF;
        _yOffset = labelF.size.height+kPadding;
        _xOffset = labelF.size.width-totalSize.width+kPadding*8;

        totalSize.width += _xOffset;
    }
    self.size = totalSize;
}
- (void)updateIndicators {
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self.indicator removeFromSuperview];
    [label removeFromSuperview];
    label = nil;
    switch (self.mode) {
        case CHProgressHUDModeActivityIndicator:{
    
            self.indicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [(UIActivityIndicatorView *)self.indicator startAnimating];
            [self addSubview:self.indicator];
            [(UIActivityIndicatorView *)self.indicator setColor:self.activityIndicatorColor];

        }
            break;
        case CHProgressHUDModeCustomView:{
            self.indicator = self.customView;
            [self addSubview:self.indicator];
        }
            break;
        case CHProgressHUDModeActivityText:{
            self.indicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [(UIActivityIndicatorView *)self.indicator startAnimating];
            [(UIActivityIndicatorView *)self.indicator setColor:self.activityIndicatorColor];
      
            [self addSubview:self.indicator];
            [self initLabel];
        }
            break;
        case CHProgressHUDModePlainText:{
            [self initLabel];
        }
            break;
            
            
        default:
            break;
    }

    
}
- (void)initLabel{
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.labelColor;
    label.font = self.labelFont;
    label.text = self.labelText;
    label.numberOfLines = 0;
    [self addSubview:label];
}
#pragma mark BG Drawing
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    // Set background rect color
    if (self.color) {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
    } else {
        CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    }
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD backgroud rect
    CGRect boxRect = CGRectMake(round((allRect.size.width - self.size.width) / 2),
                                round((allRect.size.height - self.size.height) / 2), self.size.width, self.size.height+ self.yOffset);
    float radius = self.cornerRadius;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}
#pragma mark - Private
- (BOOL)isNeedShowLabel{
    return ((self.mode == CHProgressHUDModeActivityText )|| (self.mode == CHProgressHUDModePlainText)) && self.labelText.length > 0;
}
- (void)done {
    isFinished = YES;
    self.alpha = 0.0f;
    self.labelText = nil;
    if (self.mode == CHProgressHUDModeCustomView && [self.customView isKindOfClass:[UIImageView class]]) {
        [self.indicator.layer removeAllAnimations];
    }
    [self removeFromSuperview];
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = NULL;
    }
    self.showStarted = nil;
}
- (void)didMoveToSuperview{
    
    [self updateForCurrentOrientationAnimated:NO];
}
- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
}
#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}
- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}
- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont", @"labelColor",
            @"color",  @"activityIndicatorColor", nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self updateUIForKeypath:keyPath];
    }
}
- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"mode"] || [keyPath isEqualToString:@"customView"] ||
        [keyPath isEqualToString:@"activityIndicatorColor"]) {
        [self updateIndicators];
    } else if ([keyPath isEqualToString:@"labelText"]) {
        label.text = self.labelText;
    } else if ([keyPath isEqualToString:@"labelFont"]) {
        label.font = self.labelFont;
    }else if ([keyPath isEqualToString:@"color"]) {
        _color = self.color;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
#pragma mark Show & Hide
+ (void)showHUDAddedTo:(UIView *)view animated:(BOOL)animated{
     [[CHProgressHUD sharedHUD] show:animated insertView:view];
}

+ (void)showAnimated:(BOOL)animated completionBlock:(CHProgressHUDCompletionBlock)completion{
    [CHProgressHUD sharedHUD].completionBlock = completion;
    [self show:animated];

}

+ (void)show:(BOOL)animated{
    
    [[CHProgressHUD sharedHUD] show:animated insertView:nil];
}
+ (void)showPlainText:(NSString *)text{
    [[CHProgressHUD sharedHUD] setMode:CHProgressHUDModePlainText];
    [[CHProgressHUD sharedHUD] setLabelText:text];
    [[CHProgressHUD sharedHUD] show:YES insertView:nil];
}
- (void)show:(BOOL)animated insertView:(UIView *)view{
    self.showStarted = [NSDate date];
    if (self.labelText.length == 0 && self.mode != CHProgressHUDModeCustomView) {
        self.mode = CHProgressHUDModeActivityIndicator;
    }
    if (animated) {
        self.indicator.transform = CGAffineTransformIdentity;
        if (self.mode == CHProgressHUDModePlainText) {
            [self hideAfterDelayed:self.textDuration animation:animated text:self.labelText completionBlock:nil];
        }else  if (self.mode == CHProgressHUDModeCustomView && [self.customView isKindOfClass:[UIImageView class]]) {
            [CHProgressHUD rotate360DegreeWithImageView:(UIImageView *)self.indicator];
        }
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        self.alpha = 1.0f;
    }
    if (!self.superview && view == nil) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        
    }else{
        
        [view addSubview:self];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
+ (void)hide:(BOOL)animated{
    [[CHProgressHUD sharedHUD] hide:@(animated)];
}
+ (void)hideWithText:(NSString *)text animated:(BOOL)animated{
    [[CHProgressHUD sharedHUD] hideAfterDelayed:[CHProgressHUD sharedHUD].textDuration animation:animated text:text completionBlock:nil];
}
+ (void)hide:(BOOL)animated text:(NSString *)text
                      afterDelay:(NSTimeInterval)delay
                 completionBlock:(CHProgressHUDCompletionBlock)completion{
        [[CHProgressHUD sharedHUD]  hideAfterDelayed:delay animation:animated text:text completionBlock:completion];
}
+ (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay
                       completionBlock:(CHProgressHUDCompletionBlock)completion{
    [[CHProgressHUD sharedHUD]  hideAfterDelayed:delay animation:animated text:nil completionBlock:completion];
}
- (void)hide:(NSNumber *)animated{

    if (animated && self.showStarted) {
        [UIView animateWithDuration:0.30 animations:^{
            self.transform = CGAffineTransformConcat( self.transform, CGAffineTransformMakeScale(0.5f, 0.5f));
            self.alpha = 0.02f;
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            [self done];
         
        }];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }

}
- (void)hideAfterDelayed:(NSTimeInterval )delay
               animation:(BOOL )animated
                    text:(NSString *)text
         completionBlock:(CHProgressHUDCompletionBlock)completion{
    [CHProgressHUD sharedHUD].completionBlock = completion;
    if (text != nil && text.length > 0) {
        self.mode = CHProgressHUDModePlainText;
        self.labelText = text;
    }
    [self  performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

#pragma mark Catagetory
+ (UIImageView *)rotate360DegreeWithImageView:(__kindof UIImageView *)imageView{
    if ( [CHProgressHUD sharedHUD].animation) {
        [imageView.layer addAnimation: [CHProgressHUD sharedHUD].animation forKey:nil];
    }else{
        CABasicAnimation *animation = [ CABasicAnimation
                                       animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        
        //围绕Z轴旋转，垂直与屏幕
        animation.toValue = [ NSValue valueWithCATransform3D:
                             
                             CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
        animation.duration = 0.5;
        //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
        animation.cumulative = YES;
        animation.repeatCount = 1000;
        //在图片边缘添加一个像素的透明区域
        CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
        UIGraphicsBeginImageContext(imageRrect.size);
        [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [CHProgressHUD sharedHUD].animation = animation;
        [imageView.layer addAnimation: [CHProgressHUD sharedHUD].animation forKey:nil];
    }

    return imageView;
}
#pragma mark OverRide Setter
+ (void)setLabelColor:(UIColor *)labelColor{
    [CHProgressHUD sharedHUD].labelColor = labelColor;
}
+ (void)setMode:(CHProgressHUDMode )mode{
    [CHProgressHUD sharedHUD].mode = mode;
}
+ (void)setMargin:(CGFloat)margin{
    [CHProgressHUD sharedHUD].margin = margin;
}
+ (void)setCustomView:(UIView *)customView{
  //  id copyOfView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:customView]];
    [CHProgressHUD sharedHUD].customView = customView;
}
+ (void)setColor:(UIColor *)color{
    [CHProgressHUD sharedHUD].color = color;
}
+ (void)setCornerRadius:(float)cornerRadius{
    [CHProgressHUD sharedHUD].cornerRadius = cornerRadius;
}
+ (void)setLabelFont:(UIFont *)labelFont{
    [CHProgressHUD sharedHUD].labelFont = labelFont;
}
+ (void)setActivityIndicatorColor:(UIColor *)color{
    [CHProgressHUD sharedHUD].activityIndicatorColor = color;
}
+ (void)setOpacity:(float)opacity{
    [CHProgressHUD sharedHUD].opacity = opacity;
}
+ (void)setLabelText:(NSString *)labelText{
    [CHProgressHUD sharedHUD].labelText = labelText;
}
+ (void)setTextDuration:(NSTimeInterval )time{
    [CHProgressHUD sharedHUD].textDuration = time;
}
- (void)dealloc{
    [self unregisterFromKVO];
}
@end
