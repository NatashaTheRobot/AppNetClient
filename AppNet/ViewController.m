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

@interface ViewController ()
{
    __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    
    NSArray *_feedItems;
    
}

- (void)getLatestAppNetUpdates;
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getLatestAppNetUpdates];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)refresh:(id)sender
{
    [self getLatestAppNetUpdates];
    [self.refreshControl endRefreshing];
}

- (void)getLatestAppNetUpdates
{
    [_activityIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSMutableArray *feedItemsUnsorted = [[NSMutableArray alloc] init];
                                   NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSArray *publicFeedArray = [responseDictionary objectForKey:@"data"];
                                   
                                   for (NSDictionary *update in publicFeedArray) {
                                       
                                       FeedItem *feedItem = [[FeedItem alloc] init];
                                       
                                       feedItem.text = [update objectForKey:@"text"];
                                       feedItem.username = [update valueForKeyPath:@"user.username"];
                                       feedItem.avatarURL = [NSURL URLWithString:[update valueForKeyPath:@"user.avatar_image.url"]];
                                                                              
                                       [feedItemsUnsorted addObject:feedItem];
                                       
                                   }
                                   
                                   _feedItems = [[feedItemsUnsorted reverseObjectEnumerator] allObjects];
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

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *new_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return new_image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"update";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (_feedItems) {
        FeedItem *feedItem = _feedItems[indexPath.row];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:feedItem.avatarURL]];
        
        cell.imageView.image = [self resizeImage:image toSize:CGSizeMake(50, 50)];
        cell.imageView.layer.cornerRadius = 10;
        cell.imageView.layer.masksToBounds = YES;
        
        cell.textLabel.text = feedItem.text;
        cell.textLabel.lineBreakMode = YES;
        cell.textLabel.numberOfLines = 0;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", feedItem.username];
    }
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = _feedItems[indexPath.row];
    NSString *text = feedItem.text;
    CGSize maximumLabelSize = CGSizeMake(160, CGFLOAT_MAX);
    UIFont *font = [UIFont systemFontOfSize:11];
    CGSize expectedLabelSize = [text sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = expectedLabelSize.height + 55;
    return height;
}

@end
