//
// Created by Bohdan on 3/29/14.
//

#import <Foundation/Foundation.h>

@protocol BORChatMessage;


@interface BORChatCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic, readonly) NSMutableArray *messages;
- (void) addMessage:(id <BORChatMessage>)message;
@end