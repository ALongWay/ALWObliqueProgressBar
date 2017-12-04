//
//  ALWObliqueProgressBar.h
//  ALWObliqueProgressBar
//
//  Created by lisong on 2017/12/4.
//

#import <UIKit/UIKit.h>

///进度条开始方向
typedef NS_ENUM(NSInteger, ALWObliqueProgressDirection) {
    ALWObliqueProgressDirectionFromLeft = 0,
    ALWObliqueProgressDirectionFromRight
};

@interface ALWObliqueProgressBar : UIView

@property (nonatomic, assign, readonly) CGFloat obliqueAngle;///<倾斜角度，默认为(M_P / 6)；以左上角为标准，正值表示向右倾斜，负值表示向左倾斜
@property (nonatomic, assign, readonly) ALWObliqueProgressDirection progressDirection;///<进度条方向
@property (nonatomic, strong, readonly) NSArray<UIColor *> *progressColorsArray;///<进度条从左到右渐变颜色数组。默认值为@[[UIColor redColor], [UIColor blueColor]。当数组元素为1个，则显示纯色背景。

@property (nonatomic, assign, readonly) CGFloat progressPercent;///<进度百分比

- (instancetype)initWithFrame:(CGRect)frame;

/**
 初始化倾斜进度条方法
 
 @param frame frame
 @param angel 倾斜角度
 @param direction 进度条方向
 @return return value description
 */
- (instancetype)initWithFrame:(CGRect)frame obliqueAngle:(CGFloat)angel direction:(ALWObliqueProgressDirection)direction;

/**
 设置进度条区域背景颜色
 
 @param backgroundColor backgroundColor description
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor;

/**
 更新进度条颜色数组progressColorsArray
 */
- (void)updateProgressColorsArray:(NSArray<UIColor *> *)colorsArray;

/**
 更新进度，带有动画。请先构建界面。
 
 @param percent 百分比
 */
- (void)updateProgressWithPercent:(CGFloat)percent;

/**
 更新进度，选择是否带有动画
 
 @param percent percent description
 @param animation animation description
 */
- (void)updateProgressWithPercent:(CGFloat)percent animation:(BOOL)animation;

@end
