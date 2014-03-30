//
//  BORViewController.h
//  BORChatExample
//
//  Created by Bohdan on 3/22/14.
//  Copyright (c) 2014 Bohdan Orlov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BORChatRoom;

@interface BORViewController : UIViewController

@property(nonatomic, strong) BORChatRoom *chatRoom;
@end