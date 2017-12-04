//
//  ALWViewController.m
//  ALWObliqueProgressBar
//
//  Created by lisong on 12/04/2017.
//  Copyright (c) 2017 lisong. All rights reserved.
//

#import "ALWViewController.h"
#import "ALWObliqueProgressBar.h"

@interface ALWViewController ()

@property (nonatomic, strong) ALWObliqueProgressBar *progressBar1;
@property (nonatomic, strong) ALWObliqueProgressBar *progressBar2;
@property (nonatomic, strong) ALWObliqueProgressBar *progressBar3;
@property (nonatomic, strong) ALWObliqueProgressBar *progressBar4;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) CGFloat percent1;
@property (nonatomic, assign) CGFloat percent2;
@property (nonatomic, assign) CGFloat percent3;
@property (nonatomic, assign) CGFloat percent4;

@end

@implementation ALWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat barHeight = 20;
    CGFloat offsetY = 40;
    
    _percent1 = 0.2;
    _percent2 = 0;
    _percent3 = 0.2;
    _percent4 = 0;
    
    _progressBar1 = [[ALWObliqueProgressBar alloc] initWithFrame:CGRectMake(0, offsetY, width, barHeight)];
    [_progressBar1 updateProgressWithPercent:_percent1];
    [self.view addSubview:_progressBar1];
    
    offsetY += barHeight + 10;
    
    _progressBar2 = [[ALWObliqueProgressBar alloc] initWithFrame:CGRectMake(0, offsetY, width, barHeight) obliqueAngle:M_PI / 6 direction:ALWObliqueProgressDirectionFromRight];
    [_progressBar2 updateProgressColorsArray:@[[UIColor redColor], [UIColor greenColor]]];
    [self.view addSubview:_progressBar2];

    offsetY += barHeight + 10;

    _progressBar3 = [[ALWObliqueProgressBar alloc] initWithFrame:CGRectMake(0, offsetY, width, barHeight) obliqueAngle:-M_PI / 6 direction:ALWObliqueProgressDirectionFromLeft];
    [_progressBar3 updateProgressColorsArray:@[[UIColor yellowColor], [UIColor greenColor], [UIColor brownColor]]];
    [_progressBar3 updateProgressWithPercent:_percent3 animation:NO];
    [self.view addSubview:_progressBar3];

    offsetY += barHeight + 10;

    _progressBar4 = [[ALWObliqueProgressBar alloc] initWithFrame:CGRectMake(0, offsetY, width, barHeight) obliqueAngle:-M_PI / 6 direction:ALWObliqueProgressDirectionFromRight];
    [self.view addSubview:_progressBar4];

    offsetY += barHeight + 10;

    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(20, offsetY, 60, 40)];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(didClickedResetButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
 
    [self startTimer];
}

- (void)startTimer
{
    [self stopTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateProgress
{
    if (_count > 10) {
        [self stopTimer];
        
        return;
    }
    
    _count++;
    
    _percent1 += 0.1;
    _percent2 += 0.1;
    _percent3 += 0.1;
    _percent4 += 0.1;
    
    [_progressBar1 updateProgressWithPercent:_percent1 animation:YES];
    [_progressBar2 updateProgressWithPercent:_percent2 animation:YES];
    [_progressBar3 updateProgressWithPercent:_percent3 animation:YES];
    [_progressBar4 updateProgressWithPercent:_percent4 animation:NO];
}

- (void)didClickedResetButton
{
    _count = 0;
    
    _percent1 = 0;
    _percent2 = 0;
    _percent3 = 0;
    _percent4 = 0;
    
    [self startTimer];
}

@end
