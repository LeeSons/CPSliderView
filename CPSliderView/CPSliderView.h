//
//  CPSliderView.h
//  CPProgress
//
//  Created by apple on 2017/3/21.
//  Copyright © 2017年 MorpLCP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPSliderView : UIView

/*** 样式 ***/
typedef NS_ENUM(NSUInteger, CPSliderViewStyle)
{
    CPSliderViewStyleStar, // 五星
    CPSliderViewStyleHeart, // 心形
};

@property (nonatomic, assign) CGFloat value; // 数值
@property (nonatomic, strong) UIColor *trajectoryColor; // 轨迹颜色
@property (nonatomic, strong) UIColor *progressColor; // 进度条颜色

/**
 初始化

 @param frame frame
 @param style 样式
 @param count 星星或者心形的个数
 @param valueChange value改变回调
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame style:(CPSliderViewStyle)style count:(NSInteger)count valueChangeBlock:(void (^)(CGFloat value))valueChange;

@end
