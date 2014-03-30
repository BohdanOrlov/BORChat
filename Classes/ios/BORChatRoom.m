//
// Created by Bohdan on 3/22/14.
// Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import "BORChatRoom.h"
#import "BORChatCollectionViewController.h"
#import "BORChatMessage.h"

static const int BORChatRoomMessageContainerHeight = 60;
static const int BORChatRoomDefaultSpacing = 10;

@interface BORChatRoom () <UITextViewDelegate>
@property (strong, nonatomic) BORChatCollectionViewController *chatCollectionViewController;
@property(nonatomic, strong) UIView *messageContainer;
@property(nonatomic, strong) UITextView *messageTextView;
@property(nonatomic, strong) UIButton *messageSendButton;
@property(nonatomic, strong) UILabel *messagePlaceholder;
@property(nonatomic, strong) NSLayoutConstraint *messageTextViewHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *bottomSpacingConstraint;
@property(nonatomic) CGFloat lastKeyboardHeight;
@end

@implementation BORChatRoom

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLoad {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.messageContainer];
    NSDictionary *views = @{@"messageContainer" : self.messageContainer};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageContainer]|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageContainer(>=height)]|" options:NSLayoutFormatAlignmentMask metrics:@{@"height" : @(BORChatRoomMessageContainerHeight)} views:views]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.chatCollectionViewController = [[BORChatCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [self.view addSubview:self.chatCollectionViewController.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    if(!self.bottomSpacingConstraint){
        [self.view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"view" : self.view}]];
        [self.view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"view" : self.view}]];
        self.bottomSpacingConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.view.superview addConstraint:self.bottomSpacingConstraint];
    }
    BORChatMessage *message = [[BORChatMessage alloc] init];
    message.text = @"Long long text message, OK?";
    message.date = [NSDate date];
    message.sentByCurrentUser = YES;
    message.isLastMessageInARow = YES;
    message.senderName = @"Bohdan";
    [self.chatCollectionViewController addMessage:message];
}

#pragma mark - Accessors

- (UIView *)messageContainer {
    if (_messageContainer)
        return _messageContainer;

    _messageContainer = [[UIView alloc] init];
    _messageContainer.backgroundColor = [UIColor lightGrayColor];
    _messageContainer.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor grayColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [separatorView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0]];
    [_messageContainer addSubview:separatorView];
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"separatorView" : separatorView}]];


    [_messageContainer addSubview:self.messageTextView];
    [_messageContainer addSubview:self.messageSendButton];
    NSDictionary *views = @{@"messageTextView" : self.messageTextView, @"messageSendButton" : self.messageSendButton};
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-s-[messageTextView]-s-[messageSendButton(44)]-s-|" options:NSLayoutFormatAlignAllBottom metrics:@{@"s" : @(BORChatRoomDefaultSpacing)} views:views]];
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-s-[messageTextView]-s-|" options:NSLayoutFormatAlignAllBottom metrics:@{@"s" : @(BORChatRoomDefaultSpacing)} views:views]];

    return _messageContainer;
}

- (UITextView *)messageTextView {
    if (_messageTextView)
        return _messageTextView;
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _messageTextView.backgroundColor = [UIColor whiteColor];
    _messageTextView.layer.cornerRadius = 5;
    _messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    _messageTextView.layer.borderWidth = 1.0;
    _messageTextView.delegate = self;
    self.messageTextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_messageTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:10.0];
    [_messageTextView addConstraint:self.messageTextViewHeightConstraint];
    return _messageTextView;
}

- (UIButton *)messageSendButton {
    if (_messageSendButton)
        return _messageSendButton;
    _messageSendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _messageSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_messageSendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_messageSendButton addConstraint:[NSLayoutConstraint constraintWithItem:_messageSendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36.0]];
    return _messageSendButton;
}

#pragma mark - Protocols

- (void)textViewDidChange:(UITextView *)textView {
    self.messageTextViewHeightConstraint.constant = MIN([textView contentSize].height, self.view.frame.size.height - BORChatRoomDefaultSpacing * 2);
}

#pragma mark - Notifications

- (void)keyboardWillShow:(id)keyboardDidShow {
    NSDictionary* userInfo = [keyboardDidShow userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.lastKeyboardHeight = keyboardSize.height;
        self.bottomSpacingConstraint.constant = -self.lastKeyboardHeight;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(id)keyboardDidHide {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bottomSpacingConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}


@end