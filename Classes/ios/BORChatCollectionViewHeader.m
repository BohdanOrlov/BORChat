//
// Created by Bohdan on 4/5/14.
//

#import "BORChatCollectionViewHeader.h"

static NSDateFormatter *dateFormatter;

@interface BORChatCollectionViewHeader ()
@property (nonatomic, retain) UILabel *sectionLabel;
@end

@implementation BORChatCollectionViewHeader {

}
+ (void)initialize {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE h:mm a"];
}
- (id)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (!self)
        return nil;
    self.backgroundColor = [UIColor whiteColor];
    self.sectionLabel = [[UILabel alloc] init];
//    sectionLabel.text = [self.messagesBySections[indexPath.section][0] date].description;
    self.sectionLabel.textAlignment = NSTextAlignmentCenter;
    self.sectionLabel.font = [UIFont systemFontOfSize:13];
    CGRect rect = self.bounds;
    rect.origin.y += 10;
    rect.size.height -= 10;
    self.sectionLabel.frame = rect;
    [self addSubview:self.sectionLabel];
    return self;
}


-(void)configureWithDate:(NSDate *)date{
    NSString *string = [dateFormatter stringFromDate:date];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, [string rangeOfString:@" "].location)];
    self.sectionLabel.attributedText = attributedString;
}

@end