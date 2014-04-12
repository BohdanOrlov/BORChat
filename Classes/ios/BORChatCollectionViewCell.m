#import "BORChatCollectionViewCell.h"
#import "BORChatMessage.h"

#define UIColorFromRGB(rgbValue) [UIColor \
       colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
       green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
       blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kMaxTextViewWidth 220.0
#define kTextViewInsets UIEdgeInsetsMake(9, 10, 0, 10)

@interface BORChatCollectionViewCell ()
@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UITextView *messageTextView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSLayoutConstraint *textViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leftAlignmentConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightAlignmentConstraint;
@property (nonatomic, strong) id leftTimeLabelAlignmentConstraint;
@property (nonatomic, strong) id rightTimeLabelAlignmentConstraint;
@end

static UIColor *initialColor;
static UIFont *messageFont;
static NSCache *imageCache;

@implementation BORChatCollectionViewCell

+ (void)initialize {
    messageFont = [UIFont systemFontOfSize:15];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor yellowColor];
        [self.contentView addSubview:self.bubbleImageView];
        [self.contentView addSubview:self.messageTextView];
        [self.contentView addSubview:self.timeLabel];
        self.leftAlignmentConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[bubbleImageView]"
            options:NSLayoutFormatAlignmentMask metrics:nil
            views:@{@"bubbleImageView" : self.bubbleImageView}].lastObject;
        self.rightAlignmentConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"[bubbleImageView]-5-|"
            options:NSLayoutFormatAlignmentMask metrics:nil
            views:@{@"bubbleImageView" : self.bubbleImageView}].lastObject;
        self.leftTimeLabelAlignmentConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"[timeLabel]-5-|"
            options:NSLayoutFormatAlignmentMask metrics:nil
            views:@{@"timeLabel" : self.timeLabel}].lastObject;
        self.rightTimeLabelAlignmentConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[timeLabel]"
            options:NSLayoutFormatAlignmentMask metrics:nil
            views:@{@"timeLabel" : self.timeLabel}].lastObject;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bubbleImageView]|"
            options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"bubbleImageView" : self.bubbleImageView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeLabel]|"
            options:NSLayoutFormatAlignmentMask metrics:nil views:@{@"timeLabel" : self.timeLabel}]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView
            attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.messageTextView
            attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView
            attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.messageTextView
            attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView
            attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.messageTextView
            attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView
            attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.messageTextView
            attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    }
    return self;
}

- (void)awakeFromNib {


}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    [UIView animateWithDuration:0.33 animations:^{
//        if (selected)
//            self.messageTextView.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.9 alpha:1.0];
//        else
//            self.messageTextView.backgroundColor = initialColor;
//    }];
//}

- (UIImageView *)bubbleImageView {
    if (_bubbleImageView)
        return _bubbleImageView;
    _bubbleImageView = [[UIImageView alloc] init];
    _bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    _bubbleImageView.backgroundColor = [UIColor redColor];
    return _bubbleImageView;
}

- (UITextView *)messageTextView {
    if (_messageTextView)
        return _messageTextView;
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _messageTextView.editable = NO;
    _messageTextView.font = messageFont;
    _messageTextView.scrollsToTop = NO;
    self.textViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_messageTextView
        attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    self.textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_messageTextView
        attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    [_messageTextView addConstraints:@[self.textViewWidthConstraint, self.textViewHeightConstraint]];
    return _messageTextView;
}

- (UILabel *)timeLabel {
    if (_timeLabel)
        return _timeLabel;
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor lightGrayColor];
    return _timeLabel;
}

- (void)setMessage:(id <BORChatMessage>)message {
    _message = message;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    //TODO
    self.senderOrigin = self.message.sentByCurrentUser ? WHChatCollectionViewCellSenderOriginRight : WHChatCollectionViewCellSenderOriginLeft;
    self.senderName = message.senderName;
    self.timeString = [[formatter stringFromDate:message.date] lowercaseString];
    self.text = message.text;

}
- (UIImage *)colorImage:(UIImage *)origImage withColor:(UIColor *)color
{
// begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(origImage.size, NO, [UIScreen mainScreen].scale);

// get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();

// set the fill color
    [color setFill];

// translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, origImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, origImage.size.width, origImage.size.height);
//    CGContextDrawImage(context, rect, origImage.CGImage);

// set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, origImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);


// generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

//return the color-burned image
    return coloredImg;

}
- (UIImage *) cachedImageWithName:(NSString *)name color:(UIColor *)color{
    NSString *key = [name stringByAppendingString:color.description];
    if ([imageCache objectForKey:key])
        return [imageCache objectForKey:key];
    if(!imageCache)
        imageCache = [[NSCache alloc] init];
    UIImage *image = [[self colorImage:[UIImage imageNamed:name] withColor:color] stretchableImageWithLeftCapWidth:25
        topCapHeight:18];
    [imageCache setObject:image forKey:key];
    return image;
}
- (void)setSenderOrigin:(WHChatCollectionViewCellSenderOrigin)senderOrigin {
    _senderOrigin = senderOrigin;

    self.messageTextView.backgroundColor = [UIColor clearColor];
    UIColor *bubbleColor = [self bubbleColor];
//        self.messageTextView.backgroundColor = bubbleColor;
    if (self.senderOrigin == WHChatCollectionViewCellSenderOriginRight) {
        self.messageTextView.textColor = [UIColor whiteColor];

        UIImage *image;


        if (self.message.lastMessageInARow)
            image = [self cachedImageWithName:@"usersLastMessageBubble.png" color:bubbleColor];
        else
            image = [self cachedImageWithName:@"usersMessageBubble.png" color:bubbleColor];
        self.bubbleImageView.image = image;
        if ([self.contentView.constraints containsObject:self.leftAlignmentConstraint]) {
            [self.contentView removeConstraint:self.leftAlignmentConstraint];
        }
        [self.contentView addConstraint:self.rightAlignmentConstraint];
        if ([self.contentView.constraints containsObject:self.leftTimeLabelAlignmentConstraint]) {
            [self.contentView removeConstraint:self.leftTimeLabelAlignmentConstraint];
        }
        [self.contentView addConstraint:self.rightTimeLabelAlignmentConstraint];
    }
    else {
        self.messageTextView.textColor = [UIColor darkTextColor];

        UIImage *image;
        if (self.message.lastMessageInARow)
            image = [self cachedImageWithName:@"othersLastMessageBubble.png" color:bubbleColor];
        else
            image = [self cachedImageWithName:@"othersMessageBubble.png" color:bubbleColor];
        self.bubbleImageView.image = [image stretchableImageWithLeftCapWidth:25 topCapHeight:18];
        if ([self.contentView.constraints containsObject:self.rightAlignmentConstraint]) {
            [self.contentView removeConstraint:self.rightAlignmentConstraint];
        }
        [self.contentView addConstraint:self.leftAlignmentConstraint];
        if ([self.contentView.constraints containsObject:self.rightTimeLabelAlignmentConstraint]) {
            [self.contentView removeConstraint:self.rightTimeLabelAlignmentConstraint];
        }
        [self.contentView addConstraint:self.leftTimeLabelAlignmentConstraint];
    }
}

- (UIColor *)bubbleColor {
    UIColor *color;
    if([self.message respondsToSelector:@selector(bubbleColor)])
        color = self.message.bubbleColor;
    if(!color)
        color = self.message.sentByCurrentUser ? UIColorFromRGB(0x047eff) : UIColorFromRGB(0xe5e5ea);
    return color;
}

- (void)setText:(NSString *)text {
    [self setText:text maxWidth:kMaxTextViewWidth];
}

- (void)setText:(NSString *)text maxWidth:(float)maxWidth {
    _text = text;
    self.messageTextView.text = text;
    self.messageTextView.text = text;
    CGSize size = [self.class textViewSizeForText:text maxWidth:maxWidth];

    self.textViewWidthConstraint.constant = (CGFloat) ceil(size.width);
    self.textViewHeightConstraint.constant = (CGFloat) ceil(size.height);
    [self layoutIfNeeded];

//    NSLog(@"%@, %@, %@, %@", text, NSStringFromCGSize(size), NSStringFromUIEdgeInsets(self.messageTextView.textContainerInset), NSStringFromCGSize(self.messageTextView.frame.size));
}

- (void)setSenderName:(NSString *)senderName {
    _senderName = senderName;
    [self configureDetailsLabel];
}

- (void)setTimeString:(NSString *)timeString {
    _timeString = timeString;
    [self configureDetailsLabel];
}


- (void)configureDetailsLabel {
    self.timeLabel.text = self.timeString;
}

+ (CGSize)textViewSizeForText:(NSString *)text maxWidth:(float)maxWidth {
    UIFont *font = messageFont;
    static UITextView *textView;
    if (!textView) {
        textView = [[UITextView alloc] init];
    }

    textView.text = text;
    textView.font = font;
    CGSize size = [textView sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
//    size.height += kTextViewInsets.top + kTextViewInsets.bottom;
//    size.height += 4; //magic for pixel perfect
//    size.width += kTextViewInsets.left + kTextViewInsets.right;
    return size;
}

+ (CGSize)sizeForMessage:(id <BORChatMessage>)message {
    CGSize size;
    size = [self textViewSizeForText:message.text maxWidth:kMaxTextViewWidth];
    float height = size.height;


//    height += 16; //top spacing

    return CGSizeMake(320, height);
}


@end
