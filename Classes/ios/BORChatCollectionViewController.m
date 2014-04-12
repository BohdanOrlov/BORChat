//
// Created by Bohdan on 3/29/14.
//

#import "BORChatCollectionViewController.h"
#import "BORChatMessage.h"
#import "BORChatCollectionViewCell.h"
#import "BORChatCollectionViewHeader.h"
#import "BORSpringFlowLayout.h"


@interface BORChatCollectionViewController ()
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *messagesBySections;
@end

@implementation BORChatCollectionViewController {

}
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.messages = [NSMutableArray array];
        self.messagesBySections = [NSMutableArray array];
    }

    return self;
}


- (void)viewDidLoad {
//    self.collectionView.backgroundColor = [UIColor colorWithRed:0.7 green:1 blue:0.7 alpha:1.0];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[BORChatCollectionViewCell class]
        forCellWithReuseIdentifier:[self cellReuseIdentifier]];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    [self.collectionView registerClass:[BORChatCollectionViewHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
        withReuseIdentifier:[self headerReuseIdentifier]];
    layout.minimumLineSpacing = 2;
    layout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 35);
    self.layout = (BORSpringFlowLayout *) layout;
}

- (NSString *)cellReuseIdentifier {
    return @"BORChatCollectionViewCell";
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.messagesBySections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messagesBySections[(NSUInteger) section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BORChatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellReuseIdentifier]
        forIndexPath:indexPath];
    cell.message = self.messagesBySections[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [BORChatCollectionViewCell sizeForMessage:self.messagesBySections[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row]];
    return size;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (![kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return nil;
    }
    BORChatCollectionViewHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
        withReuseIdentifier:[self headerReuseIdentifier] forIndexPath:indexPath];
    [view configureWithDate:[self.messagesBySections[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row] date]];
    return view;
}

- (NSString *)headerReuseIdentifier {
    return @"BORCollectionReusableView";
}

- (void)addMessage:(id <BORChatMessage>)message scrollToMessage:(BOOL)scrollToMessage {
    [message setLastMessageInARow:YES];
    [self.messages addObject:message];
    [self addMessageToAppropriateSection:message scrollToMessage:scrollToMessage];
}

- (void)addMessageToAppropriateSection:(id <BORChatMessage>)message scrollToMessage:(BOOL)scrollToMessage {
    __block CGSize size = self.collectionView.contentSize;
    [self.collectionView performBatchUpdates:^{
        if (!self.messagesBySections.count || [self shouldCreateSectionForMessage:message]) {
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.messagesBySections.count]];
            [self.messagesBySections addObject:[NSMutableArray array]];
        }
        else if (self.messagesBySections.count && ([[self.messagesBySections.lastObject lastObject] sentByCurrentUser] == message.sentByCurrentUser)) {
            [[self.messagesBySections.lastObject lastObject] setLastMessageInARow:NO];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.messagesBySections.lastObject count]-1
                inSection:self.messagesBySections.count -1]]];
        }
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.messagesBySections.lastObject count]
            inSection:self.messagesBySections.count - 1]]];
        [self.messagesBySections.lastObject addObject:message];
    }
        completion:^(BOOL finished) {
            if (!scrollToMessage)
                return;
            //fixes scroll to first cell that added into bottom inset area.
            [self.collectionView scrollRectToVisible:[self.collectionView.visibleCells.lastObject frame] animated:YES];
            [self scrollToLastMessageAnimated:YES ];
        }];

}

- (BOOL)shouldCreateSectionForMessage:(id <BORChatMessage>)message {
    return [message.date timeIntervalSinceDate:[[self.messagesBySections.lastObject lastObject] date]] > 60 * 60;
}

- (void)scrollToLastMessageAnimated:(BOOL)animated {
    if(!self.messages.count)
        return;
    NSUInteger indexOfLastSection = self.messagesBySections.count - 1;
    NSInteger indexOfMessageInLastSection = [self.messagesBySections[indexOfLastSection] count] - 1;
    NSIndexPath *path = [NSIndexPath indexPathForItem:indexOfMessageInLastSection
        inSection:indexOfLastSection];
    [self.collectionView scrollToItemAtIndexPath:path
        atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
}
@end