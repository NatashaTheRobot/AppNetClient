//
//  ViewController.m
//  AppNet
//
//  Created by Natasha Murashev on 5/24/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FeedItem.h"
#import "UpdateCell.h"

@interface ViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    
    NSMutableArray *_feedItems;
    
}

- (void)getLatestAppNetUpdates;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getLatestAppNetUpdates];
}


- (void)getLatestAppNetUpdates
{
    [_activityIndicator startAnimating];
    
    if (!_feedItems) {
        _feedItems = [[NSMutableArray alloc] init];
    } else {
        [_feedItems removeAllObjects];
    }
    
    NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSArray *publicFeedArray = [responseDictionary objectForKey:@"data"];
                                   
                                   for (NSDictionary *update in publicFeedArray) {
                                       
                                       FeedItem *feedItem = [[FeedItem alloc] init];
                                       
                                       feedItem.text = [update objectForKey:@"text"];
                                       feedItem.username = [update valueForKeyPath:@"user.username"];
                                       feedItem.avatarURL = [NSURL URLWithString:[update valueForKeyPath:@"user.avatar_image.url"]];
                                       
                                       [_feedItems insertObject:feedItem atIndex:_feedItems.count];
                                       
                                   }
                                   
                                   [self.tableView reloadData];
                                   [_activityIndicator stopAnimating];
                               }
                               
                           }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _feedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"update";
    UpdateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    if (!cell) {
//        cell = [[UpdateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//    }
    
    FeedItem *feedItem = _feedItems[indexPath.row];
    
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feedItem.avatarURL]];
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.layer.masksToBounds = YES;
    
    cell.textLabel.text = feedItem.text;
    cell.textLabel.lineBreakMode = YES;
    
    
    [cell.textLabel sizeToFit];
    
    CGSize maxSize = CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX);
    
    CGSize requiredSize = [cell.textLabel sizeThatFits:maxSize];
    
    
    
//    UIFont *font = [UIFont boldSystemFontOfSize:11.0];
//    CGSize textLabelsize = CGSizeMake(cell.textLabel.frame.size.width,
//                             cell.frame.size.height - cell.detailTextLabel.frame.size.height);
//    
//    CGSize size = [feedItem.text sizeWithFont:font
//                            constrainedToSize:textLabelsize
//                                lineBreakMode:NSLineBreakByWordWrapping];
//    CGFloat numberOfLines = size.height / font.lineHeight;
//    
//    cell.textLabel.numberOfLines = (int)numberOfLines + 1;
//    NSLog(@"%i", cell.textLabel.numberOfLines);
    
    cell.detailTextLabel.text = feedItem.username;
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    if (_feedItems[indexPath.row]) {
//        UpdateCell *cell = (UpdateCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//        
////        cell.textLabel.text = ((FeedItem *)_feedItems[indexPath.row]).text;
////        
////        [cell.textLabel sizeToFit];
////        
////        CGSize maxSize = CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX);
////        
////        CGSize requiredSize = [cell.textLabel sizeThatFits:maxSize];
////        
////        return requiredSize.height;
//    }
//    
//    return 50.0;
//}

@end
