

#import "BORSpringFlowLayout.h"

@interface BORSpringFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

// Needed for tiling
@property (nonatomic, strong) NSMutableSet *visibleItems;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@end

@implementation BORSpringFlowLayout

- (id)init {
    if (!(self = [super init])) return nil;

//    self.headerReferenceSize = CGSizeMake(0, 50);

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleItems = [NSMutableSet set];
    self.isFlexbile = YES;
    return self;
}

- (void)prepareLayout {
//    NSLog(@"==== PREPARE ====");
    [super prepareLayout];

    if ([[UIApplication sharedApplication] statusBarOrientation] != self.interfaceOrientation || !self.isFlexbile) {
        [self reloadLayoutProperties];
    }

    self.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    // Need to overflow our actual visible rect slightly to avoid flickering.
    CGRect visibleRect = CGRectInset((CGRect) {.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);

    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    for (UICollectionViewLayoutAttributes *item in itemsInVisibleRectArray) {
//        if ([item.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
//            item.indexPath = [NSIndexPath indexPathForItem:-1 inSection:item.indexPath.section];// since first row has same indexpath as section header
    }
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];

    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        UICollectionViewLayoutAttributes *item = [[behaviour items] firstObject];
        BOOL currentlyVisible = NO;
        for (UICollectionViewLayoutAttributes *attribute in itemsInVisibleRectArray) {
            if([attribute.indexPath isEqual:item.indexPath] && attribute.representedElementKind == item.representedElementKind)
                currentlyVisible = YES;
        }
        return !currentlyVisible;
    }]];

    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        UICollectionViewLayoutAttributes *item = [[obj items] firstObject];
        [self.visibleItems removeObject:item];
//        NSLog(@"Deleted: %@, %@", item.representedElementKind,[item.indexPath description]);
    }];

    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleItems
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = NO;
        for (UICollectionViewLayoutAttributes *attribute in self.visibleItems) {
            if([attribute.indexPath isEqual:item.indexPath] && attribute.representedElementKind == item.representedElementKind)
                currentlyVisible = YES;
        }
        return !currentlyVisible;
    }]];

    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
//        NSLog(@"Added: %@, %@", item.representedElementKind, [item.indexPath description]);
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];

        [self configureSpringBehaviour:springBehaviour touchLocation:touchLocation];

        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleItems addObject:item];
    }];
}

- (void)configureSpringBehaviour:(UIAttachmentBehavior *)springBehaviour touchLocation:(CGPoint)touchLocation {
    UICollectionViewLayoutAttributes *item = springBehaviour.items.lastObject;
    CGPoint center = item.center;
    springBehaviour.length = 1.0f;
    springBehaviour.damping = 0.8f;
    springBehaviour.frequency = 1.0f;

    // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
//        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
    CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
    CGFloat scrollResistance = distanceFromTouch / 1500.0;

    if (self.latestDelta < 0) {
                center.y += floor(MAX(self.latestDelta, self.latestDelta * scrollResistance));
            }
            else {
                center.y += floor(MIN(self.latestDelta, self.latestDelta * scrollResistance));
            }
    item.center = center;
//    NSLog(@"distance: %f, delta: %f, center: %f", distanceFromTouch, self.latestDelta, item.frame.origin.y);
//        }

}

- (void)reloadLayoutProperties {
    self.latestDelta = 0;
    [self.dynamicAnimator removeAllBehaviors];
    self.visibleItems = [NSMutableSet set];
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
        [self configureSpringBehaviour:springBehaviour touchLocation:touchLocation];

        [self.dynamicAnimator updateItemUsingCurrentState:springBehaviour.items.lastObject];
    }];

    return NO;
}

//- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
//    [super prepareForCollectionViewUpdates:updateItems];
//
//    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
//        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
//            if ([self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate])
//                return;
//            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
//
//            attributes.frame = CGRectMake(10, 0, 300, 44); // or some other initial frame
//
//            UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];
//
//            springBehaviour.length = 1.0f;
//            springBehaviour.damping = 0.8f;
//            springBehaviour.frequency = 1.0f;
//            [self.dynamicAnimator addBehavior:springBehaviour];
//        }
//    }];
//}
@end
