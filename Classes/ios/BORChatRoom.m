//
// Created by Bohdan on 3/22/14.
// Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import "BORChatRoom.h"
#import "BORChatCollectionViewController.h"
#import "BORChatMessage.h"
#import "BORSpringFlowLayout.h"

#define UIColorFromRGB(rgbValue) [UIColor \
       colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
       green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
       blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static const int BORChatRoomMessageContainerHeight = 40;
static const int BORChatRoomDefaultSpacing = 10;

@interface BORChatRoom () <UITextViewDelegate>
@property (strong, nonatomic) BORChatCollectionViewController *chatCollectionViewController;
@property (nonatomic, strong) UIView *messageContainer;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *messageSendButton;
@property (nonatomic, strong) UILabel *messagePlaceholder;
@property (nonatomic, strong) NSLayoutConstraint *messageTextViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpacingConstraint;
@property (nonatomic) CGFloat lastKeyboardHeight;
@property (nonatomic) CGSize keyboardSize;
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

//    self.chatCollectionViewController = [[BORChatCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.chatCollectionViewController = [[BORChatCollectionViewController alloc] initWithCollectionViewLayout:[[BORSpringFlowLayout alloc] init]];
    UICollectionView *collectionView = self.chatCollectionViewController.collectionView;
    collectionView.frame = self.view.bounds;
//    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:collectionView];

//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"collectionView" : collectionView}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView][messageContainer]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"collectionView" : collectionView, @"messageContainer" : self.messageContainer}]];


    [self.view addSubview:self.messageContainer];

    NSDictionary *views = @{@"messageContainer" : self.messageContainer};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageContainer]|"
        options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageContainer(>=height)]|"
        options:NSLayoutFormatAlignmentMask metrics:@{@"height" : @(BORChatRoomMessageContainerHeight)} views:views];
    self.bottomSpacingConstraint = constraints.lastObject;
    [self.view addConstraints:constraints];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
    [self configureInsetsOfCollectionView:collectionView];

}


- (void)configureInsetsOfCollectionView:(UICollectionView *)collectionView {
    UIEdgeInsets insets = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, self.messageTextViewHeightConstraint.constant + [UIApplication sharedApplication].statusBarFrame.size.height, 0);
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        insets.top += self.navigationController.navigationBar.frame.size.height;
    }
    if (self.tabBarController && [[[self tabBarController] tabBar] isHidden]) {
        insets.bottom += [[[self tabBarController] tabBar] frame].size.height;
    }
    insets.bottom += self.keyboardSize.height + 10;
    collectionView.contentInset = insets;
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.bottomSpacingConstraint) {
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
            options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"view" : self.view}]];
        [self.view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]"
            options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"view" : self.view}]];
        self.bottomSpacingConstraint = [NSLayoutConstraint constraintWithItem:self.view
            attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.superview
            attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.view.superview addConstraint:self.bottomSpacingConstraint];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    CGRect rect = self.messageTextView.frame;
    rect.origin.x += 10;
    rect.size.width -= 20;
    self.messagePlaceholder.frame = rect;
    [self.messageContainer addSubview:self.messagePlaceholder];
}

#pragma mark - Accessors

- (UIView *)messageContainer {
    if (_messageContainer)
        return _messageContainer;

    _messageContainer = [[UIView alloc] init];
    _messageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    UIToolbar *blurToolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    blurToolbar.autoresizingMask = self.view.autoresizingMask;
    [_messageContainer addSubview:blurToolbar];

    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor =  UIColorFromRGB(0xadadad);
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
//    [separatorView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeHeight
//        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1
//        constant:1]];
    separatorView.frame = CGRectMake(0, 0, 0, 0.5);
    [_messageContainer addSubview:separatorView];
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|"
        options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"separatorView" : separatorView}]];
//    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-0.5)-[separatorView]"
//        options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"separatorView" : separatorView}]];`


    [_messageContainer addSubview:self.messageTextView];
    [_messageContainer addSubview:self.messageSendButton];
    NSDictionary *views = @{@"messageTextView" : self.messageTextView, @"messageSendButton" : self.messageSendButton};
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-s-[messageTextView]-s-[messageSendButton(44)]-s-|"
        options:NSLayoutFormatAlignAllBaseline metrics:@{@"s" : @(BORChatRoomDefaultSpacing)} views:views]];
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-t-[messageTextView]-b-|"
        options:NSLayoutFormatAlignAllBottom metrics:@{@"t" : @(7), @"b": @(5)} views:views]];
    [_messageContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageSendButton]|"
        options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];

    return _messageContainer;
}

- (UITextView *)messageTextView {
    if (_messageTextView)
        return _messageTextView;
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _messageTextView.scrollsToTop = NO;
    _messageTextView.backgroundColor = [UIColor whiteColor];
    _messageTextView.layer.cornerRadius = 5;
    _messageTextView.layer.borderColor = UIColorFromRGB(0xc8c8cd).CGColor;
    _messageTextView.layer.borderWidth = 0.5;
    _messageTextView.delegate = self;
    self.messageTextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_messageTextView
        attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0
        constant:BORChatRoomMessageContainerHeight - 7 - 5];
    [_messageTextView addConstraint:self.messageTextViewHeightConstraint];

    return _messageTextView;
}

- (UILabel *)messagePlaceholder {
    if (_messagePlaceholder)
        return _messagePlaceholder;
    _messagePlaceholder = [[UILabel alloc] init];
    _messagePlaceholder.text = @"Text Message";
    _messagePlaceholder.font = [UIFont systemFontOfSize:13];
    _messagePlaceholder.textColor = UIColorFromRGB(0xc7c7cc);
    return _messagePlaceholder;
}

- (UIButton *)messageSendButton {
    if (_messageSendButton)
        return _messageSendButton;
    _messageSendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _messageSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_messageSendButton setTitle:@"Send" forState:UIControlStateNormal];
    _messageSendButton.tintColor = UIColorFromRGB(0x8e8e93);
    _messageSendButton.titleLabel.font = [UIFont boldSystemFontOfSize:_messageSendButton.titleLabel.font.pointSize];
    [_messageSendButton addConstraint:[NSLayoutConstraint constraintWithItem:_messageSendButton
        attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36.0]];
    [_messageSendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    return _messageSendButton;
}

#pragma mark - Private

- (void)sendMessage {
    self.messageTextView.text = nil;
    [self.messageTextView resignFirstResponder];

}

#pragma mark - Protocols

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.chatCollectionViewController scrollToLastMessageAnimated:YES ];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateMessageTextViewSizeAndInset:textView];
    [self.chatCollectionViewController scrollToLastMessageAnimated:YES ];
    if (self.messageTextView.text.length)
        self.messagePlaceholder.hidden = YES;
    else
        self.messagePlaceholder.hidden = NO;

}

- (void)updateMessageTextViewSizeAndInset:(UITextView *)textView {
    CGFloat navigationBarHeight = 0;
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    }
    self.messageTextViewHeightConstraint.constant = MIN(MAX([textView contentSize].height, BORChatRoomMessageContainerHeight - BORChatRoomDefaultSpacing * 2), self.view.frame.size.height - BORChatRoomDefaultSpacing * 2 - navigationBarHeight - [UIApplication sharedApplication].statusBarFrame.size.height - self.keyboardSize.height - 15);
    [self configureInsetsOfCollectionView:self.chatCollectionViewController.collectionView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self updateMessageTextViewSizeAndInset:textView];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(id)keyboardDidShow {
    NSDictionary *userInfo = [keyboardDidShow userInfo];
    self.keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updateMessageTextViewSizeAndInset:self.messageTextView];
    [self.view layoutIfNeeded];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        self.lastKeyboardHeight = self.keyboardSize.height;
        self.bottomSpacingConstraint.constant = self.lastKeyboardHeight;
        [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(id)keyboardDidHide {
    NSDictionary *userInfo = [keyboardDidHide userInfo];
    self.keyboardSize = CGSizeZero;
    [self updateMessageTextViewSizeAndInset:self.messageTextView];
    [self.view layoutIfNeeded];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:6];
        self.bottomSpacingConstraint.constant = 0;
        [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)addMessage:(id <BORChatMessage>)message scrollToMessage:(BOOL)scrollToMessage {
    [self.chatCollectionViewController addMessage:message scrollToMessage:scrollToMessage];
}

@end