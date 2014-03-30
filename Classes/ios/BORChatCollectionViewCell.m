

#import "BORChatCollectionViewCell.h"
#import "BORChatMessage.h"


#define kMaxTextViewWidth 220.0
#define kTextViewInsets UIEdgeInsetsMake(9, 10, 0, 10)

@interface BORChatCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@end

static UIColor *initialColor;
static UIFont *messageFont;

@implementation BORChatCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.33 animations:^{
        if (selected)
            self.messageTextView.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.9 alpha:1.0];
        else
            self.messageTextView.backgroundColor = initialColor;
    }];
}

- (void)awakeFromNib {


    initialColor = self.messageTextView.backgroundColor;
    messageFont = [UIFont systemFontOfSize:16];
    self.messageTextView.font = messageFont;
    self.messageTextView.scrollsToTop = NO;
    self.timeLabel.font = [UIFont systemFontOfSize:8];

    self.timeLabel.textColor = [UIColor lightTextColor];
}


- (void)setMessage:(id <BORChatMessage>)message {
    _message = message;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];

    //TODO
    self.senderOrigin = self.message.sentByCurrentUser ? WHChatCollectionViewCellSenderOriginRight : WHChatCollectionViewCellSenderOriginLeft;
    self.senderName = message.senderName;
    self.timeString = [[formatter stringFromDate:message.date] lowercaseString];

}

- (void)setSenderOrigin:(WHChatCollectionViewCellSenderOrigin)senderOrigin {
    _senderOrigin = senderOrigin;


    if (self.senderOrigin == WHChatCollectionViewCellSenderOriginRight) {
        self.messageTextView.textColor = [UIColor whiteColor];

        UIImage *image;
        if (self.message.isLastMessageInARow)
            image = [UIImage imageNamed:@"usersLastMessageBubble.png"];
        else
            image = [UIImage imageNamed:@"usersMessageBubble.png"];
        self.bubbleImageView.image = [image stretchableImageWithLeftCapWidth:25 topCapHeight:18];
    }
    else {
        self.messageTextView.textColor = [UIColor lightTextColor];

        UIImage *image;
        if (self.message.isLastMessageInARow)
            image = [UIImage imageNamed:@"othersLastMessageBubble.png"];
        else
            image = [UIImage imageNamed:@"othersMessageBubble.png"];
        self.bubbleImageView.image = [image stretchableImageWithLeftCapWidth:25 topCapHeight:18];
    }
}

- (void)setText:(NSString *)text maxWidth:(float)maxWidth {
    _text = text;
    self.messageTextView.text = text;
    CGSize size = [self.class textViewSizeForText:text maxWidth:maxWidth];

    self.textViewWidthConstraint.constant = (CGFloat) ceil(size.width);
    self.textViewHeightConstraint.constant = (CGFloat) ceil(size.height);
    [self.messageTextView layoutIfNeeded];

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
    size.height += 4; //magic for pixel perfect
    size.width += kTextViewInsets.left + kTextViewInsets.right;
    return size;
}

+ (CGSize)sizeForMessage:(id <BORChatMessage>)message {
    CGSize size;
    size = [self textViewSizeForText:message.text maxWidth:kMaxTextViewWidth];
    float height = size.height;


    height += 4; //top spacing

    return CGSizeMake(320, height);
}


@end
