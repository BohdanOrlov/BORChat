//
// Created by Bohdan on 4/5/14.
//

#import <Foundation/Foundation.h>


@interface BORChatCollectionViewHeader : UICollectionReusableView
@property (nonatomic, retain, readonly) UILabel *sectionLabel;
- (void)configureWithDate:(NSDate *)date;
@end