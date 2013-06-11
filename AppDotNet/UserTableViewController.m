//
//  UserTableViewController.m
//  AppDotNet
//
//  Created by Brian Lewis on 5/18/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "UserTableViewController.h"

@interface UserTableViewController ()

{
    NSArray *dataArray;
    NSString *cellIdentifier;
}

- (IBAction)reloadUserTimeline:(id)sender;

@end

@implementation UserTableViewController

@synthesize userId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadUserTimeline:self];
}

- (IBAction)reloadUserTimeline:(id)sender {
    
    cellIdentifier = @"loadingCell";
    [self.tableView reloadData];
    
    NSString *urlString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/posts", userId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        dataArray = [responseDictionary objectForKey:@"data"];
        
        cellIdentifier = @"displayCell";
        
        [self.tableView reloadData];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([cellIdentifier isEqualToString:@"loadingCell"]) {
        return 1;
    }
    
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if ([cellIdentifier isEqualToString:@"loadingCell"]) {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:4];
        [activityIndicator startAnimating];
    }
    
    if ([cellIdentifier isEqualToString:@"displayCell"]) {
        
        NSDictionary *postDictionary = dataArray[indexPath.row];
        NSDictionary *user = [postDictionary objectForKey:@"user"];
        
        NSString *imageUrlString = [[user objectForKey:@"avatar_image"] objectForKey:@"url"];
        
        NSURL *url = [NSURL URLWithString:imageUrlString];
        NSData *avatarData = [NSData dataWithContentsOfURL:url];
        UIImage *avatar = [[UIImage alloc] initWithData:avatarData];
        cell.imageView.image = avatar;
        
        UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
        textLabel.text = [postDictionary objectForKey:@"text"];
        
        UILabel *usernameLabel = (UILabel*)[cell viewWithTag:3];
        usernameLabel.text = [user objectForKey:@"username"];
    }
    
    return cell;
}

@end
