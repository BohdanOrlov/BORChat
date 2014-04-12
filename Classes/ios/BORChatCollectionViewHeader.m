//
// Created by Bohdan on 4/5/14.
//

#import "BORChatCollectionViewHeader.h"

#define UIColorFromRGB(rgbValue) [UIColor \
       colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
       green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
       blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSDateFormatter *dateFormatter;

@interface BORChatCollectionViewHeader ()
@property (nonatomic, retain) UILabel *sectionLabel;
@end

@implementation BORChatCollectionViewHeader {

}
+ (void)initialize {
    dateFormatter = [[NSDateFormatter alloc] init];


}
- (id)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (!self)
        return nil;
    self.backgroundColor = [UIColor whiteColor];
    self.sectionLabel = [[UILabel alloc] init];
//    sectionLabel.text = [self.messagesBySections[indexPath.section][0] date].description;
    self.sectionLabel.textAlignment = NSTextAlignmentCenter;
    self.sectionLabel.font = [UIFont systemFontOfSize:11];
    self.sectionLabel.textColor = UIColorFromRGB(0x8e8e93);
    CGRect rect = self.bounds;
    rect.origin.y += 10;
    rect.size.height -= 10;
    self.sectionLabel.frame = rect;
    [self addSubview:self.sectionLabel];
    return self;
}


-(void)configureWithDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];

    NSString *aString = @" \\d";
    [dateFormatter setDateFormat:@"EEEE h:mm a"];
    if([today isEqualToDate:otherDate]) {
        [dateFormatter setDateFormat:@"'Today' h:mm a"];
    }
    NSDate *yesterday = [otherDate dateByAddingTimeInterval:60 * 60 * 24];
    if([today isEqualToDate:yesterday]) {
        [dateFormatter setDateFormat:@"'Yesterday' h:mm a"];
    }
    if([today timeIntervalSinceDate:date] > 60 * 60 * 24 * 6) {
        [dateFormatter setDateFormat:@"EEE, MMM d, h:mm a"];
        aString = @", \\d";
    }


    NSString *string = [dateFormatter stringFromDate:date];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];

    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11]
        range:NSMakeRange(0, [string rangeOfString:aString options:NSRegularExpressionSearch].location +1)];
    self.sectionLabel.attributedText = attributedString;
}

@end