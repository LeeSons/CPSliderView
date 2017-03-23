# CPSliderView

## 简介
**CPSliderView**,是一个自定义的滑块控件，简单易用。
##使用方法
导入头文件``` #improt "CPSliderView"```初始化并设置相关属性。

```
CPSliderView *slider = [[CPSliderView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 30) style:CPSliderViewStyleHeart count:5 valueChangeBlock:^(CGFloat value) {
        NSLog(@"%.1f", value);
    }];
slider.trajectoryColor = [UIColor lightGrayColor]; // 设置轨迹颜色
slider.progressColor = [UIColor orangeColor]; // 设置已划过的颜色
slider.value = 0.5; // 设置初始值
    
```
