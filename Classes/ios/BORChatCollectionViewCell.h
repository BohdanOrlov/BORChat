

#import <UIKit/UIKit.h>


@class BORChatCollectionViewCell;
@protocol BORChatMessage;

typedef NS_ENUM(NSInteger, WHChatCollectionViewCellSenderOrigin) {
    WHChatCollectionViewCellSenderOriginLeft,
    WHChatCollectionViewCellSenderOriginRight
};

@protocol WHChatCollectionViewCellDelegate <NSObject>
- (void)cellTapped:(BORChatCollectionViewCell *)cell;
@end

@interface BORChatCollectionViewCell : UICollectionViewCell

@property (nonatomic) WHChatCollectionViewCellSenderOrigin senderOrigin;
@property (strong, nonatomic) NSString *text, *senderName, *timeString;
@property (weak, nonatomic) id <WHChatCollectionViewCellDelegate> delegate;

@property (strong, nonatomic) id <BORChatMessage> message;

+ (CGSize)sizeForMessage:(id <BORChatMessage>)message;

@end
