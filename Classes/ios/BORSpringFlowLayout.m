

#import "BORSpringFlowLayout.h"

@interface BORSpringFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

// Needed for tiling
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@end

@implementation BORSpringFlowLayout

- (id)init {
    if (!(self = [super init])) return nil;

    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 0;
    self.itemSize = CGSizeMake(300, 44);
    self.sectionInset = UIEdgeInsetsMake(0, 0, 23, 0);
//    self.headerReferenceSize = CGSizeMake(0, 50);

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];

    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    if ([[UIApplication sharedApplication] statusBarOrientation] != self.interfaceOrientation || !self.isFlexbile) {
        [self reloadLayoutProperties];
    }

    self.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    // Need to overflow our actual visible rect slightly to avoid flickering.
    CGRect visibleRect = CGRectInset((CGRect) {.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);

    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    for (UICollectionViewLayoutAttributes *item in itemsInVisibleRectArray) {
        if ([item.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
            item.indexPath = [NSIndexPath indexPathForItem:-1 inSection:item.indexPath.section];// since first row has same indexpath as section header
    }
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];

    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }]];

    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];

    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        return !currentlyVisible;
    }]];

    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];


        springBehaviour.length = 1.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 1.0f;

        // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
//        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 1500.0;

        if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
            }
            else {
                center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
            }
            item.center = center;
//        }

        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (void)reloadLayoutProperties {
    self.latestDelta = 0;
    [self.dynamicAnimator removeAllBehaviors];
    self.visibleIndexPathsSet = [NSMutableSet set];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
    return [[self.dynamicAnimator itemsInRect:rect] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return ![[attributes representedElementKind] isEqualToString:UICollectionElementKindSectionHeader];
    }]];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.dynamicAnimator layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if (!attributes) {
        attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    if (!attributes) {
        attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    self.latestDelta = delta;

    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 1500.0;

        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta * scrollResistance);
        }
        else {
            center.y += MIN(delta, delta * scrollResistance);
        }
        item.center = center;

        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];

    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];

    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            if ([self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate])
                return;
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];

            attributes.frame = CGRectMake(10, 0, 300, 44); // or some other initial frame

            UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];

            springBehaviour.length = 1.0f;
            springBehaviour.damping = 0.8f;
            springBehaviour.frequency = 1.0f;
            [self.dynamicAnimator addBehavior:springBehaviour];
        }
    }];
}
@end
