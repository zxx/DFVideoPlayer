//
//  DFViewController.m
//  DFVideoPlayer
//
//  Created by zhudf on 06/07/2015.
//  Copyright (c) 2014 zhudf. All rights reserved.
//

#import "DFViewController.h"
#import <DFVideoPlayer/DFVideoPlayer.h>

@interface DFViewController ()

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
DFVideoPlayer *player;

- (void)viewDidAppear:(BOOL)animated
{
    player = [[DFVideoPlayer alloc] initWithURL:[NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"]];
    [player showInWindow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
