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
- (void)addRefreshControl;

- (void)downloadImage:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [_activityIndicator startAnimating];
    
    [self getLatestAppNetUpdates];
    
    [self addRefreshControl];
}

- (void)addRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(getLatestAppNetUpdates)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)getLatestAppNetUpdates
{    
    NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   
                                   NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSArray *publicFeedArray = [responseDictionary objectForKey:@"data"];
                                   
                                   NSMutableArray *feedItemsUnsorted = [[NSMutableArray alloc] init];
                                   
                                   for (NSDictionary *update in publicFeedArray) {
                                       
                                       FeedItem *feedItem = [[FeedItem alloc] init];
                                       
                                       feedItem.text = [update objectForKey:@"text"];
                                       feedItem.username = [update valueForKeyPath:@"user.username"];
                                       feedItem.url = [NSURL URLWithString:[update valueForKeyPath:@"user.avatar_image.url"]];
                                       feedItem.createdAt = [update objectForKey:@"created_at"];
                                                                              
                                       [feedItemsUnsorted addObject:feedItem];
                                       
                                   }
                                   
                                   _feedItems = [feedItemsUnsorted sortedArrayUsingComparator:^NSComparisonResult(FeedItem *feedItem1, FeedItem *feedItem2) {
                                       return ([feedItem1.createdAt compare:feedItem2.createdAt] == NSOrderedAscending);
                                   }];
                                   
                                   [self.tableView reloadData];
                                   
                                   if ([_activityIndicator isAnimating]) {
                                       [_activityIndicator stopAnimating];
                                   }
                                   
                                   if ([self.refreshControl isRefreshing]) {
                                       [self.refreshControl endRefreshing];
                                   }
                               }
                               
                           }];
    
}

- (void)downloadImage:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                    UIImage *image = [[UIImage alloc] initWithData:data];
                                    completionBlock(YES,image);
                                } else{
                                    completionBlock(NO,nil);
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    FeedItem *feedItem = _feedItems[indexPath.row];
    
    if (feedItem.userImage) {
        cell.imageView.image = feedItem.userImage;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"batman.png"];
        [self downloadImage:feedItem.url completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                cell.imageView.image = image;
                feedItem.userImage = image;
            }
        }];
    }

    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.layer.masksToBounds = YES;
        
    cell.textLabel.text = feedItem.text;
    cell.textLabel.lineBreakMode = YES;
    cell.textLabel.numberOfLines = 0;
        
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", feedItem.username];
        
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
