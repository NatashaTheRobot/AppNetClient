//
//  FeedItem.h
//  AppNet
//
//  Created by Natasha Murashev on 5/24/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedItem : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSURL *avatarURL;
                        
@end
