//
//  ViewController.m
//  CPSliderViewDemo
//
//  Created by MorpLCP on 2017/3/23.
//  Copyright © 2017年 yizhan. All rights reserved.
//

#import "ViewController.h"
#import "CPSliderView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CPSliderView *slider = [[CPSliderView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 50) style:(CPSliderViewStyleHeart) count:5 valueChangeBlock:^(CGFloat value) {
        NSLog(@"%.f", value);
    }];
    slider.trajectoryColor = [UIColor lightGrayColor];
    slider.progressColor = [UIColor redColor];
    slider.value = 0.3;
    [self.view addSubview:slider];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
