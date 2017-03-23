//
//  CPSliderView.m
//  CPProgress
//
//  Created by apple on 2017/3/21.
//  Copyright © 2017年 MorpLCP. All rights reserved.
//

#import "CPSliderView.h"

#define GAP 5.0

@interface CPSliderView ()
{
    CGFloat _progress;
}

@property (nonatomic, assign) NSInteger startCount;
@property (nonatomic, assign) CPSliderViewStyle style;
@property (nonatomic) CGMutablePathRef path;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *trajectoryLayer;
@property (nonatomic, strong) CAShapeLayer *sliderLayer;
@property (nonatomic, strong) UIView *strokView;

@property (nonatomic, strong) UIButton *dropView;

@property (nonatomic, copy) void (^valueChangeBlock)(CGFloat);

@end

@implementation CPSliderView

#pragma mark -- initMethod

- (instancetype)initWithFrame:(CGRect)frame style:(CPSliderViewStyle)style count:(NSInteger)count valueChangeBlock:(void (^)(CGFloat value))valueChange
{
    self.startCount = count;
    self.style = style;
    self.valueChangeBlock = valueChange;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat width = frame.size.height * _startCount + GAP * (_startCount - 1);
        self.strokView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - width) * 0.5, 0, width, frame.size.height)];
        _strokView.backgroundColor = [UIColor clearColor];
        _progress = 0;
        [self addSubview:_strokView];
        
        // 提示水滴
        self.dropView = [[UIButton alloc] initWithFrame:CGRectMake(-frame.size.height * 0.5, -frame.size.height * 1.3f - 2, frame.size.height, frame.size.height * 1.3f)];
        _dropView.backgroundColor = [UIColor blackColor];
        _dropView.hidden = YES;
        _dropView.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        UIEdgeInsets insets = _dropView.contentEdgeInsets;
        insets.top = _dropView.frame.size.width * 0.25f + 1;
        _dropView.contentEdgeInsets = insets;
        _dropView.titleLabel.font = [UIFont systemFontOfSize:13];
        [_dropView setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [self strokDropLayer];
        [_strokView addSubview:_dropView];
        
        [self setTrajectoryLayer];
        [self setSliderLayer];
    }
    return self;
}

- (void)setTrajectoryLayer
{
    [self strokLayerPath];
    _trajectoryLayer = [CAShapeLayer layer];
    _trajectoryLayer.fillColor = [UIColor lightGrayColor].CGColor;
    _trajectoryLayer.strokeColor = nil;
    _trajectoryLayer.lineWidth = 0;
    [_trajectoryLayer setPath:_path];
    [self.strokView.layer addSublayer:_trajectoryLayer];
    
    CGPathRelease(_path);
}

- (void)setSliderLayer
{
    [self strokLayerPath];
    _sliderLayer = [CAShapeLayer layer];
    _sliderLayer.fillColor = [UIColor blueColor].CGColor;
    _sliderLayer.strokeColor = nil;
    _sliderLayer.lineWidth = 0;
    [_sliderLayer setPath:_path];
    [self.strokView.layer addSublayer:_sliderLayer];
    
    CGPathRelease(_path);
    
    UIBezierPath *sliderPath = [UIBezierPath bezierPath];
    [sliderPath moveToPoint:CGPointMake(0, _strokView.frame.size.height * 0.5f)];
    [sliderPath addLineToPoint:CGPointMake(_strokView.frame.size.width, _strokView.frame.size.height * 0.5f)];
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = [UIColor blueColor].CGColor;
    _progressLayer.lineWidth = _strokView.frame.size.height;
    _progressLayer.strokeEnd = 0;
    _progressLayer.path = sliderPath.CGPath;
    
    _sliderLayer.mask = _progressLayer;
}

- (void)strokLayerPath
{
    switch (self.style)
    {
        case CPSliderViewStyleStar: // 星星
            [self strokStartLayerPath];
            break;
        case CPSliderViewStyleHeart:    // 心
            [self strokHeartLayerPath];
            break;
        default:
            break;
    }
}

#pragma mark -- setter

- (void)setTrajectoryColor:(UIColor *)trajectoryColor
{
    if (trajectoryColor)
    {
        _trajectoryColor = trajectoryColor;
        _trajectoryLayer.fillColor = trajectoryColor.CGColor;
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    if (progressColor)
    {
        _progressColor = progressColor;
        _sliderLayer.fillColor = progressColor.CGColor;
        _dropView.backgroundColor = progressColor;
    }
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    _progress = [self getValueWithRealValue:value];
    CGPoint center = _dropView.center;
    center.x = _strokView.frame.size.width * _progress;
    _dropView.center = center;
    [self setValue:_progress animated:NO];
}

#pragma mark -- touchesMethod

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _dropView.hidden = NO;
    [self changeValueWithTouchs:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self changeValueWithTouchs:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _dropView.hidden = YES;
}

#pragma mark -- customMethod

- (void)changeValueWithTouchs:(NSSet<UITouch *> *)touchs
{
    CGPoint point = [[touchs anyObject] locationInView:self];
    CGFloat x = point.x - ((self.frame.size.width - _strokView.frame.size.width) * 0.5);
    CGFloat value = x / _strokView.frame.size.width;
    if (value >= 0 && value <= 1)
    {
        CGPoint center = _dropView.center;
        center.x = x;
        _dropView.center = center;
        // 处理间隔部分比例
        for (int i = 0; i < _startCount; i++)
        {
            if (x >= (_strokView.frame.size.height + GAP) * i + _strokView.frame.size.height && x <= (_strokView.frame.size.height + GAP) * i + _strokView.frame.size.height + GAP)
            {
                // 当x位于间隙当中时保持偏移量不增加
                x = (_strokView.frame.size.height + GAP) * i + _strokView.frame.size.height;
                break;
            }
            else
            {
                x = point.x - ((self.frame.size.width - _strokView.frame.size.width) * 0.5);
            }
        }
        value = x / _strokView.frame.size.width;
        [self setValue:value animated:NO];
    }
    else if (value < 0) // 触摸最左侧为0
    {
        CGPoint center = _dropView.center;
        center.x = 0;
        _dropView.center = center;
        [self setValue:0 animated:NO];
    }
    else // 触摸最右侧为1
    {
        CGPoint center = _dropView.center;
        center.x = CGRectGetMaxX(_strokView.bounds);
        _dropView.center = center;
        [self setValue:1 animated:NO];
    }
    
    // 获取需要的实际value
    CGFloat realValue = [self getRealValueWithOffsetValue:_progress];
    
    NSString *valueStr = [self decimalwithFormat:@"0.0" floatV:realValue * 10]; // 四舍五入
    NSInteger titValue = [[valueStr componentsSeparatedByString:@"."].lastObject integerValue];
    if (titValue == 0) // 为整数的时候不显示小数点
    {
        [_dropView setTitle:[NSString stringWithFormat:@"%.f", realValue * 10] forState:(UIControlStateNormal)];
    }
    else
    {
        [_dropView setTitle:[NSString stringWithFormat:@"%.1f", realValue * 10] forState:(UIControlStateNormal)];
    }
    
    if (_valueChangeBlock)
    {
        self.valueChangeBlock(realValue);
    }
}

//四舍五入
- (NSString *)decimalwithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

/**
 value转换 - 偏移value转实际value
 因为每一个星星或者心之间的间隔，所以我们改变过的value比例中包含间隔的部分，需要转换成不考虑间隔的value.
 在此主要用于回调改变过的数值
 @param value 偏移的value
 @return 实际value
 */
- (CGFloat)getRealValueWithOffsetValue:(CGFloat)value
{
    CGFloat width = _strokView.frame.size.height + GAP;
    NSInteger gapCount = value * _strokView.frame.size.width / width;
    CGFloat realValue = (value * _strokView.frame.size.width - GAP * gapCount) / (_strokView.frame.size.width - GAP * (_startCount - 1));
    return realValue;
}

/**
 value转换 - 实际value转偏移value转
 在此主要用于设置初始value时的转换
 @param value 偏移的value
 @return 实际value
 */
- (CGFloat)getValueWithRealValue:(CGFloat)value
{
    NSInteger gapCount = 0;
    
    if ((int)(value * 10) % (int)((1.0 / _startCount) * 10)!= 0)
    {
        gapCount = value / (1.0 / _startCount);
    }
    else
    {
        gapCount = value / (1.0 / _startCount) - 1;
    }
    
    CGFloat offsetValue = ((value * (_strokView.frame.size.width - GAP * (_startCount - 1))) + GAP * gapCount) / _strokView.frame.size.width * 1.0;
    return offsetValue;
}

// 更新进度
- (void)setValue:(float)value animated:(BOOL)animated
{
    _value = [self getRealValueWithOffsetValue:value];
    _progress = value;
    [CATransaction begin];
    [CATransaction setDisableActions:!animated];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.3];
    self.progressLayer.strokeEnd = _progress;
    [CATransaction commit];
}

// 绘制五角星layer
- (void)strokStartLayerPath
{
    _path = CGPathCreateMutable();
    for (int i = 0; i < _startCount; i++)
    {
        CGFloat height = self.strokView.frame.size.height;
        CGFloat width = height;
        //确定中心点
        CGPoint centerPoint = CGPointMake((width + GAP) * i * 1.0 + width * 0.5, height * 0.5);
        //确定半径
        CGFloat radius = width * 0.5f;
        UIBezierPath *bPath = [UIBezierPath bezierPath];
        CGPoint p1 = CGPointMake(centerPoint.x, centerPoint.y - radius);
        [bPath moveToPoint:p1];
        CGFloat angle = 4 * M_PI / 5.0;
        // 获取五个关键点
        for (int i = 1; i <= _startCount; i++)
        {
            CGFloat x = centerPoint.x - sinf(i * angle) * radius;
            CGFloat y = centerPoint.y - cosf(i * angle) * radius;
            [bPath addLineToPoint:CGPointMake(x, y)];
        }
        [bPath closePath];
        CGPathAddPath(_path, NULL, bPath.CGPath);
    }
}

// 绘制心形layer
- (void)strokHeartLayerPath
{
    _path = CGPathCreateMutable();
    for (int i = 0; i < _startCount; i++)
    {
        CGFloat height = self.strokView.frame.size.height;
        CGFloat width = height;
        // 左侧圆心
        CGPoint leftCenter = CGPointMake((width + GAP) * i * 1.0 + width * 0.25, height * 0.25);
        // 左侧圆半径
        CGFloat leftRadius = height * 0.25;
        // 右侧圆心
        CGPoint rightCenter = CGPointMake((width + GAP) * i * 1.0 + width * 0.75, leftCenter.y);
        // 右侧圆半径
        CGFloat rightRadius = height * 0.25;
        // 绘制心形路径
        // 左侧半圆
        UIBezierPath *heartPath = [UIBezierPath bezierPathWithArcCenter:leftCenter radius:leftRadius startAngle:M_PI endAngle:0 clockwise:YES];
        // 右侧半圆
        [heartPath addArcWithCenter:rightCenter radius:rightRadius startAngle:M_PI endAngle:0 clockwise:YES];
        // 右侧开始到底部顶点的弧线
        [heartPath addQuadCurveToPoint:CGPointMake(leftCenter.x + leftRadius, leftRadius * 4.0) controlPoint:CGPointMake(rightCenter.x + leftRadius, leftRadius * 2.0)];
        // 底部顶点开始到左侧半圆初始点的弧线
        [heartPath addQuadCurveToPoint:CGPointMake(leftCenter.x - leftRadius, leftCenter.y) controlPoint:CGPointMake(leftCenter.x - leftRadius, leftCenter.y + leftRadius)];
        CGPathAddPath(_path, NULL, heartPath.CGPath);
    }
}

// 绘制水滴按钮
- (void)strokDropLayer
{
    // 圆心
    CGPoint center = CGPointMake(_dropView.frame.size.width * 0.5f, _dropView.frame.size.width * 0.5f);
    // 半径
    CGFloat radius = _dropView.frame.size.width * 0.5f - 1.0f;
    UIBezierPath *dropPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:M_PI endAngle:0 clockwise:YES];
    // 三阶贝塞尔曲线，两个控制点，为右侧到底部的弧线
    [dropPath addCurveToPoint:CGPointMake(center.x, _dropView.frame.size.height) controlPoint1:CGPointMake(_dropView.frame.size.width - 1.0f, _dropView.frame.size.width) controlPoint2:CGPointMake(_dropView.frame.size.width * 0.5f + 1, _dropView.frame.size.width)];
    // 三阶贝塞尔曲线，两个控制点，为底部到左侧的弧线
    [dropPath addCurveToPoint:CGPointMake(1.0, center.y) controlPoint1:CGPointMake(_dropView.frame.size.width * 0.5f - 1, _dropView.frame.size.width) controlPoint2:CGPointMake(1.0, _dropView.frame.size.width)];
    // 遮罩
    CAShapeLayer *btnMask = [CAShapeLayer layer];
    btnMask.fillColor = [UIColor whiteColor].CGColor;
    btnMask.strokeColor = nil;
    btnMask.lineWidth = 0;
    btnMask.path = dropPath.CGPath;
    [_dropView.layer setMask:btnMask];
}

@end
