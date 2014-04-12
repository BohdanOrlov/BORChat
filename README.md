# BORChat

[![Version](http://cocoapod-badges.herokuapp.com/v/BORChat/badge.png)](http://cocoadocs.org/docsets/BORChat)
[![Platform](http://cocoapod-badges.herokuapp.com/p/BORChat/badge.png)](http://cocoadocs.org/docsets/BORChat)

Chat room that tries to mimic iMessage with bouncy bubbles

## Usage

![image](http://giant.gfycat.com/BelatedFoolhardyCaudata.gif)

To run the example project; clone the repo, and run `pod install` from the Example directory first.

In orde to use in your project subclass BORCharRoom view controller and override 'sendMessage'.

```objective-c
- (void)sendMessage {
    id <BORChatMessage> message = [[BORChatMessage alloc] init];
    message.text = self.messageTextView.text;
    message.sentByCurrentUser = YES;
    message.date = [NSDate date];
    [self addMessage:message scrollToMessage:YES];
    [super sendMessage];
}
```

## Requirements

## Installation

BORChat is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "BORChat"

## Author

Bohdan Orlov, bohdan.orlov@onefinestay.com

## License

BORChat is available under the MIT license. See the LICENSE file for more info.

