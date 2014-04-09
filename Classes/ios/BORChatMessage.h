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
@end

@interface BORChatMessage : NSObject <BORChatMessage>
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL sentByCurrentUser;
@property (assign, nonatomic) BOOL lastMessageInARow;
@end