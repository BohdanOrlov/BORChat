//
// Created by Bohdan on 3/22/14.
// Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import "BORChatRoom.h"
#import <RSEnvironment/RSEnvironment.h>

@interface BORChatRoom ()
@property(nonatomic, strong) UIView *messageContainer;
@property(nonatomic, strong) UITextView *messageTextView;
@property(nonatomic, strong) UIButton *messageSendButton;
@property(nonatomic, strong) UILabel *messagePlaceholder;
@end

@implementation BORChatRoom

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    return self;
}

- (void)viewDidLoad {
    [self.view addSubview:self.messageContainer];
    NSDictionary *views = NSDictionaryOfVariableBindings(self.messageContainer);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageContainer]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];
}

- (UIView *)messageContainer {
    if (_messageContainer)
        return _messageContainer;
    _messageContainer = [[UIView alloc] init];
    _messageContainer.backgroundColor = [UIColor lightGrayColor];
    UIView *separatorView = [[UIView alloc] init];
    [separatorView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0]];
    [_messageContainer addSubview:separatorView];
    NSDictionary *views = NSDictionaryOfVariableBindings(separatorView);
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    return _messageContainer;
}
@end