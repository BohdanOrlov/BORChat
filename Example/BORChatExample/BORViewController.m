//
//  BORViewController.m
//  BORChatExample
//
//  Created by Bohdan on 3/22/14.
//  Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import "BORViewController.h"
#import <BORChat/BORChatRoom.h>

@interface BORViewController ()

@end

@implementation BORViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatRoom = [[BORChatRoom alloc] init];
    [self.view addSubview:self.chatRoom.view];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end