//
//  ALWObliqueProgressBar.m
//  ALWObliqueProgressBar
//
//  Created by lisong on 2017/12/4.
//

#import "ALWObliqueProgressBar.h"

@interface ALWObliqueProgressBar ()

@property (nonatomic, strong) UIView *contentView;///<内容视图
@property (nonatomic, strong) CAGradientLayer *gradientLayer;///<进度条的渐变层
@property (nonatomic, strong) UIView *coverView;///<覆盖进度条漏出边缘的视图

#pragma mark - Public property
@property (nonatomic, assign, readwrite) CGFloat obliqueAngle;///<倾斜角度，默认为(M_P / 6)；以左上角为标准，正值表示向右倾斜，负值表示向左倾斜
@property (nonatomic, assign, readwrite) ALWObliqueProgressDirection progressDirection;///<进度条方向
@property (nonatomic, strong, readwrite) NSArray<UIColor *> *progressColorsArray;///<进度条从左到右渐变颜色数组。默认值为@[[UIColor redColor], [UIColor blueColor]。当数组元素为1个，则显示纯色背景。

@property (nonatomic, assign, readwrite) CGFloat progressPercent;///<进度百分比

@end

@implementation ALWObliqueProgressBar

#pragma mark - Getter/Setter
- (UIColor *)backgroundColor
{
    UIColor *color = [super backgroundColor];
    if (color) {
        return color;
    }
    
    return [UIColor lightGrayColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    if (_coverView) {
        [_coverView setBackgroundColor:backgroundColor];
    }
}

- (CGFloat)obliqueAngle
{
    if (!_obliqueAngle) {
        return M_PI / 6;
    }
    
    return _obliqueAngle;
}

- (NSArray<UIColor *> *)progressColorsArray
{
    if (!_progressColorsArray || _progressColorsArray.count == 0) {
        return @[[UIColor redColor], [UIColor blueColor]];
    }
    
    return _progressColorsArray;
}

#pragma mark - Public methods
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUIWithConfiguration];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame obliqueAngle:(CGFloat)angel direction:(ALWObliqueProgressDirection)direction
{
    _obliqueAngle = angel;
    _progressDirection = direction;
    
    return [self initWithFrame:frame];
}

- (void)buildUIWithConfiguration
{
    [self setBackgroundColor:self.backgroundColor];
    
    self.layer.mask = [self getBGViewMaskLayer];
    
    //重复创建，移除之前视图
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    
    if (_coverView) {
        [_coverView removeFromSuperview];
        _coverView = nil;
    }
    
    switch (_progressDirection) {
        case ALWObliqueProgressDirectionFromLeft:{
            _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
            [self addSubview:_contentView];
            
            _coverView = [[UIView alloc] initWithFrame:self.bounds];
            [_coverView setBackgroundColor:self.backgroundColor];
            _coverView.layer.mask = [self getBGViewMaskLayer];
            [self addSubview:_coverView];
        }
            break;
        case ALWObliqueProgressDirectionFromRight:{
            _contentView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, 0, self.frame.size.height)];
            [self addSubview:_contentView];
            
            _coverView = [[UIView alloc] initWithFrame:self.bounds];
            [_coverView setBackgroundColor:self.backgroundColor];
            _coverView.layer.mask = [self getBGViewMaskLayer];
            [self addSubview:_coverView];
        }
            break;
    }
    
    [self resetContentColorsArray];
}

- (void)updateProgressWithPercent:(CGFloat)percent
{
    [self updateProgressWithPercent:percent animation:YES];
}

- (void)updateProgressWithPercent:(CGFloat)percent animation:(BOOL)animation
{
    _progressPercent = MIN(MAX(percent, 0), 1);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    //覆盖视图和内容视图重叠的宽度；进度条倾斜部分被切掉的宽度。
    CGFloat overlapWidth = height * tan(fabs(self.obliqueAngle));
    
    //内容视图宽度，需要考虑左右倾斜时候被切掉部分
    CGFloat contentWidth = overlapWidth + (width - overlapWidth) * _progressPercent;
    
    CGRect contentRect = CGRectZero;
    CGRect coverRect = CGRectZero;
    
    switch (_progressDirection) {
        case ALWObliqueProgressDirectionFromLeft:{
            contentRect = CGRectMake(0, 0, contentWidth, height);
            
            CGFloat originX = CGRectGetMaxX(contentRect) - overlapWidth;
            coverRect = CGRectMake(originX, 0, width, height);
        }
            break;
        case ALWObliqueProgressDirectionFromRight:{
            contentRect = CGRectMake(width - contentWidth, 0, contentWidth, height);
            
            CGFloat originX = (CGRectGetMinX(contentRect) + overlapWidth) - width;
            coverRect = CGRectMake(originX, 0, width, height);
        }
            break;
    }
    
    //重新设置内容视图的mask
    _contentView.layer.mask = [self getContentMaskLayerWithSize:CGSizeMake(contentWidth, height)];
    
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            _contentView.frame = contentRect;
            
            //有动画时候，修改frame
            _gradientLayer.frame = _contentView.bounds;
            
            _coverView.frame = coverRect;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        _contentView.frame = contentRect;
        
        //无动画时候，重新添加渐变layer
        [self resetContentColorsArray];
        
        _coverView.frame = coverRect;
    }
}

- (void)updateProgressColorsArray:(NSArray<UIColor *> *)colorsArray
{
    self.progressColorsArray = colorsArray;
    
    [self resetContentColorsArray];
}

#pragma mark - Private methods
- (CAShapeLayer *)getBGViewMaskLayer
{
    CGPathRef path = [self getCGPathWithFrame:self.bounds angle:self.obliqueAngle];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;
    shapeLayer.strokeColor = nil;
    
    return shapeLayer;
}

- (CAGradientLayer *)getContentGradientLayerWithFrame:(CGRect)frame
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    NSMutableArray *colorsArray = [NSMutableArray arrayWithCapacity:self.progressColorsArray.count];
    for (UIColor *color in self.progressColorsArray) {
        [colorsArray addObject:(id)color.CGColor];
    }
    
    gradientLayer.colors = colorsArray;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    
    return gradientLayer;
}

- (CAShapeLayer *)getContentMaskLayerWithSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGPathRef path = [self getCGPathWithFrame:rect angle:self.obliqueAngle];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = rect;
    shapeLayer.path = path;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;
    shapeLayer.strokeColor = nil;
    
    return shapeLayer;
}

///以左上角为标准，右斜正角度，左斜负角度
- (CGPathRef)getCGPathWithFrame:(CGRect)frame angle:(CGFloat)angle
{
    if (angle == 0) {
        return nil;
    }
    
    CGFloat originX = frame.origin.x;
    CGFloat originY = frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGPathRef path = nil;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    if (angle > 0) {
        CGFloat absoluteAngle = fabs(angle);
        
        //左上角点
        [bezierPath moveToPoint:frame.origin];
        
        //左下角点
        CGFloat secondPointX = height * tan(absoluteAngle);
        CGPoint secondPoint = CGPointMake(originX + secondPointX, originY + height);
        [bezierPath addLineToPoint:secondPoint];
        
        //右下角点
        [bezierPath addLineToPoint:CGPointMake(originX + width,originY + height)];
        
        //右上角点
        CGFloat fourthPointX = originX + width - secondPointX;
        CGPoint fourthPoint = CGPointMake(fourthPointX, originY);
        [bezierPath addLineToPoint:fourthPoint];
        
        path = [bezierPath CGPath];
    } else {
        CGFloat absoluteAngle = fabs(angle);
        
        //左上角点
        CGFloat firstPointX = height * tan(absoluteAngle);
        [bezierPath moveToPoint:CGPointMake(originX + firstPointX, 0)];
        
        //左下角点
        [bezierPath addLineToPoint:CGPointMake(originX, originY + height)];
        
        //右下角点
        CGFloat thirdPointX = originX + width - firstPointX;
        CGPoint thirdPoint = CGPointMake(thirdPointX, originY + height);
        [bezierPath addLineToPoint:thirdPoint];
        
        //右上角点
        [bezierPath addLineToPoint:CGPointMake(originX + width, originY)];
        
        path = [bezierPath CGPath];
    }
    
    return path;
}

///重新设置进度内容的颜色
- (void)resetContentColorsArray
{
    if (_gradientLayer) {
        [_gradientLayer removeFromSuperlayer];
        _gradientLayer = nil;
    }
    
    //优先添加渐变色
    if (self.progressColorsArray.count >= 2) {
        _gradientLayer = [self getContentGradientLayerWithFrame:_contentView.bounds];
        [_contentView.layer addSublayer:_gradientLayer];
    }else{
        _gradientLayer = nil;
        
        UIColor *singleColor = [self.progressColorsArray firstObject];
        
        if (singleColor) {
            [_contentView setBackgroundColor:singleColor];
        }
    }
}

@end
