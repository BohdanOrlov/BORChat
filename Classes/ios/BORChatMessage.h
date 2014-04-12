//
// Created by Bohdan on 3/29/14.
//

#import <Foundation/Foundation.h>

@protocol BORChatMessage <NSObject>
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL sentByCurrentUser;
@property (assign, nonatomic) BOOL lastMessageInARow;
@optional
@property (strong, nonatomic) UIColor *bubbleColor;
@property (strong, nonatomic) UIColor *textColor;
@end

@interface BORChatMessage : NSObject <BORChatMessage>
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL sentByCurrentUser;
@property (assign, nonatomic) BOOL lastMessageInARow;
@property (strong, nonatomic) UIColor *bubbleColor;
@end