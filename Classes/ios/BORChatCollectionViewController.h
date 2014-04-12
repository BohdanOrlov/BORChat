//
// Created by Bohdan on 3/29/14.
//

#import <Foundation/Foundation.h>

@protocol BORChatMessage;
@class BORSpringFlowLayout;


@interface BORChatCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic, readonly) NSMutableArray *messages;
@property (nonatomic, strong) BORSpringFlowLayout *layout;
- (void)addMessage:(id <BORChatMessage>)message scrollToMessage:(BOOL)scrollToMessage;
- (void)scrollToLastMessageAnimated:(BOOL)animated;
@end