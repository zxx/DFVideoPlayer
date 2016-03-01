//
//  ViewController.m
//  DFVitamioVideoPlayer
//
//  Created by zhudf on 15/5/29.
//  Copyright (c) 2015年 朱东方. All rights reserved.
//

#import "DFVideoPlayer.h"
#import "DFVideoControlView.h"
#import "Vitamio.h"

@interface DFVideoPlayer ()<VMediaPlayerDelegate, DFVideoControlViewDelegate>

@property (nonatomic, strong)   VMediaPlayer        *mediaPlayer;

@property (nonatomic, strong)   UIView              *view;
@property (nonatomic, strong)   UIView              *carrierView;
@property (nonatomic, strong)   DFVideoControlView  *videoControlView;

@property (nonatomic, weak)     UIView              *parentView;

@property (nonatomic, assign)   long                duration;
@property (nonatomic, strong)   NSTimer             *durationTimer;

@property (nonatomic, assign)   BOOL                progressDragging;
@property (nonatomic, assign)   BOOL                mediaPlayerInited;

@property (nonatomic, strong)   NSArray             *constraints;

@property (nonatomic, assign, getter = isFullScreen) BOOL fullScreen;
@property (nonatomic, assign) CGRect originalRect;

@end

@implementation DFVideoPlayer

#pragma mark - Life Cycle

- (void)dealloc
{
    NSLog(@"DFVideoPlayer dealloc....");
}

- (instancetype)initWithURL:(NSURL *)videoURL
{
    if (self = [super init]) {
        _videoURL = videoURL;
    }
    return self;
}

- (void)showInWindow
{
    UIWindow *windown = [UIApplication sharedApplication].keyWindow;
    if (!windown) {
        windown = [[UIApplication sharedApplication].windows firstObject];
    }
    
    [self showInView:windown];
}

- (void)showInView:(UIView *)parentView
{
    [self showInView:parentView withRect:CGRectMake(0, 0, CGRectGetWidth(parentView.bounds), CGRectGetWidth(parentView.bounds) * 9 / 16.0)];
}

- (void)showInView:(UIView *)view withRect:(CGRect)rect
{
    _parentView = view;
    
    self.view.frame = rect;
    [self.view addSubview:self.carrierView];
    [self.view addSubview:self.videoControlView];
    [view addSubview:self.view];
    
    [self start];
}

- (void)start
{
    [self startPlayerWithUrl:self.videoURL];
}

- (void)dismiss
{
    [self stopPlayer];
    [self.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DFVideoControlViewDelegate
- (void)videoControlView:(DFVideoControlView *)controlView didPlayButtonClicked:(UIButton *)playerButton
{
    if (self.mediaPlayerInited) {
        if (![self.mediaPlayer isPlaying]) {
            [self.mediaPlayer start];
        }
    } else {
        [self start];
    }
}

- (void)videoControlView:(DFVideoControlView *)controlView didPauseButtonClicked:(UIButton *)pauseButton
{
    if (self.mediaPlayerInited) {
        if ([self.mediaPlayer isPlaying]) {
            [self.mediaPlayer pause];
        }
    } else {
        [self start];
    }
}

- (void)videoControlView:(DFVideoControlView *)controlView didCloseButtonClicked:(UIButton *)closeButton
{
    [self dismiss];
}

- (void)videoControlView:(DFVideoControlView *)controlView didFullScreenButtonClicked:(UIButton *)fullScrrenButton
{
    if (self.isFullScreen) return;
    self.originalRect = self.view.frame;
    
    CGFloat height = self.parentView.bounds.size.height;
    CGFloat width = self.parentView.bounds.size.width;
    CGRect frame = CGRectMake((width - height) / 2, (height - width) / 2, height, width);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.fullScreen = YES;
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)videoControlView:(DFVideoControlView *)controlView didShrinkScreenButtonClicked:(UIButton *)shrinkScreenButton
{
    if (!self.isFullScreen) return;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.view.frame = self.originalRect;
    } completion:^(BOOL finished) {
        self.fullScreen = NO;
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragBegan:(UISlider *)sener
{
    // 控制Timer
    self.progressDragging = YES;
}

- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragEnded:(UISlider *)sener
{
    if (self.mediaPlayerInited) {
        [self.mediaPlayer seekTo:sener.value * self.duration];
    }
}

#pragma mark - VMediaPlayerDelegate required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player start];
    self.duration = [player getDuration];
    [self startTimer];
    
    [self.videoControlView setPlaying:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [player seekTo:(long)0];
    [player pause];
    
    [self.videoControlView setPlaying:NO];
    [self.videoControlView alignmentRectInsets];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    [self.videoControlView setPlaying:NO];
}

#pragma mark - VMediaPlayerDelegate optional
/**
 * Called when set the data source to player.
 *
 * You can tell media player manager what preference are you like in this call back method.
 * e.g. set `player.decodingSchemeHint` or `player.autoSwitchDecodingScheme`,
 * `player.useCache` ect.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
	player.decodingSchemeHint = VMDecodingSchemeSoftware;
	player.autoSwitchDecodingScheme = NO;
}

/**
 * Called when the VMediaPlayer try to open media strem with another decoding schmeme.
 *
 * If `autoSwitchDecodingScheme' is YES and VMedaiPlayer failed to open stream with
 * `decodingSchemeHint` scheme, VMediaPlayer will try to a new scheme, the old and new
 * scheme return in `arg`.
 *
 * @param player The shared media player instance.
 * @param arg *NSArray|NSNumber*, int value. Contain the old&new decoding scheme.
 */
- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
	// Set buffer size, default is 1024KB(1024*1024).
	[player setBufferSize:512*1024];
	[player setVideoQuality:VMVideoQualityHigh];
    [player setVideoFillMode:VMVideoFillModeFit];
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
    self.progressDragging = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
	self.progressDragging = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
    [self.mediaPlayer pause];
    
	self.progressDragging = YES;
    [self.videoControlView setBuffering:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
//    [self.videoControlView updateBufferedProgress:[arg intValue]];
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
    [self.mediaPlayer start];
    
	self.progressDragging = NO;
    [self.videoControlView setBuffering:NO];
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
}

#pragma mark - Event reponse

- (void)timerTask
{
	if (!self.progressDragging && self.mediaPlayerInited) {
        [self.videoControlView updateProgress:[self.mediaPlayer getCurrentPosition] totalTime:self.duration];
	}
}

#pragma mark - Private methods

- (void)startPlayerWithUrl:(NSURL *)url
{
    [self.mediaPlayer setDataSource:url];
    [self.mediaPlayer prepareAsync];
    
    self.mediaPlayerInited = YES;
}

- (void)stopPlayer
{
    [self stopTimer];
    [self.mediaPlayer reset];
    
    self.mediaPlayerInited = NO;
}

- (void)startTimer
{
    self.durationTimer = [NSTimer timerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerTask)
                                               userInfo:nil
                                                repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.durationTimer invalidate];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        
        [invocation setArgument:&val atIndex:2];    // 0 target 1 selector 2..n parameters
        [invocation invoke];
    }
}

#pragma mark - Getters and Setters

- (DFVideoControlView *)videoControlView
{
    if (!_videoControlView) {
        _videoControlView = [[DFVideoControlView alloc] initWithFrame:self.view.bounds];
        _videoControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoControlView.userInteractionEnabled = YES;
        _videoControlView.delegate = self;
    }
    return _videoControlView;
}

- (UIView *)view
{
    if (!_view) {
        _view = [[UIView alloc] init];
        [_view setClipsToBounds:YES];
        _view.backgroundColor = [UIColor blackColor];
    }
    return _view;
}

- (UIView *)carrierView
{
    if (!_carrierView) {
        _carrierView = [[UIView alloc] initWithFrame:self.view.bounds];
        _carrierView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _carrierView.backgroundColor = [UIColor clearColor];
    }
    return _carrierView;
}

- (VMediaPlayer *)mediaPlayer
{
    if (!_mediaPlayer) {
        _mediaPlayer = [VMediaPlayer sharedInstance];
        [_mediaPlayer setupPlayerWithCarrierView:self.carrierView withDelegate:self];
    }
    return _mediaPlayer;
}

@end