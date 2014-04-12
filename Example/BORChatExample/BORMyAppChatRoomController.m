//
//  BORMyAppChatRoomController.m
//  BORChatExample
//
//  Created by Bohdan on 3/22/14.
//  Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import "BORMyAppChatRoomController.h"
#import "BORChatMessage.h"
#import "BORChatCollectionViewController.h"


@interface BORMyAppChatRoomController ()

@end

@implementation BORMyAppChatRoomController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"John Doe";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Demo"
        style:UIBarButtonItemStyleBordered target:self action:@selector(sendDemoMessage)];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendMessage {
    id <BORChatMessage> message = [[BORChatMessage alloc] init];
    message.text = self.messageTextView.text;
    message.sentByCurrentUser = YES;
    message.date = [NSDate date];
    [self addMessage:message scrollToMessage:YES];
    [super sendMessage];
}

- (void)sendDemoMessage{
    NSUInteger count = self.chatCollectionViewController.messages.count;
    id <BORChatMessage> message = [[BORChatMessage alloc] init];
    message.text = [NSString stringWithFormat:@"%@ (%d)",
                                              [@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." substringToIndex:count + 3],
                                              count];
    message.sentByCurrentUser = (int)(count * M_PI_4) % 2 == 1;
//    message.bubbleColor = message.sentByCurrentUser ? [UIColor colorWithRed:0.3 green:0.9
//        blue:0.3 alpha:1.0]: [UIColor colorWithWhite:0.95 alpha:1.0];
    message.date = [[NSDate date] dateByAddingTimeInterval:(message.sentByCurrentUser ? 60 * 60 * (count + 1) : 60 * 60 * count * 0.3) - (60 * 60 * 24 * 7)];
    [self addMessage:message scrollToMessage:YES];
}
@end