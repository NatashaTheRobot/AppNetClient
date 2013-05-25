//
//  FeedItem.m
//  AppNet
//
//  Created by Natasha Murashev on 5/24/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "FeedItem.h"

@interface FeedItem ()

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end

@implementation FeedItem

-(void)setCreatedAt:(NSString *)createdAt
{
    _createdAt = [self convertToDateFromString:createdAt];
}

- (NSDate *)convertToDateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

- (void)setUserImage:(UIImage *)userImage
{
    _userImage = [self resizeImage:userImage toSize:CGSizeMake(50, 50)];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resized_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized_image;
}



@end
