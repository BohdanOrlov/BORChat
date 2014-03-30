//
// Created by Bohdan on 3/29/14.
//

#import "BORChatCollectionViewController.h"
#import "BORChatMessage.h"
#import "BORChatCollectionViewCell.h"

@interface BORChatCollectionViewController()
@property (strong, nonatomic) NSMutableArray *messages;
@end

@implementation BORChatCollectionViewController {

}

- (void)viewDidLoad {
    [self.collectionView registerClass:[BORChatCollectionViewCell class] forCellWithReuseIdentifier:[self cellReuseIdentifier]];
}

- (NSString *)cellReuseIdentifier {
    return NSStringFromClass([BORChatCollectionViewCell class]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BORChatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellReuseIdentifier] forIndexPath:indexPath];
    cell.message = self.messages[(NSUInteger) indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [BORChatCollectionViewCell sizeForMessage:self.messages[(NSUInteger) indexPath.row]];
}

- (void)addMessage:(id <BORChatMessage>)message {
    [self.messages addObject:message];
    [self.collectionView reloadData];

}


@end