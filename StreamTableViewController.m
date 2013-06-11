//
//  StreamTableViewController.m
//  AppDotNet
//
//  Created by Brian Lewis on 5/18/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "StreamTableViewController.h"
#import "UserTableViewController.h"

@interface StreamTableViewController ()
{
    NSArray *dataArray;
    NSString *cellIdentifier;
}

- (IBAction)reloadGlobalTimeline:(id)sender;

@end

@implementation StreamTableViewController

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
    
   /* UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                  initWithCustomView:activityIndicator];
    [[self navigationItem] setRightBarButtonItem:barButton];
    
    [activityIndicator startAnimating];*/ //This code can be used to put activity indicator in nav bar

    [self reloadGlobalTimeline:self];
}

- (IBAction)reloadGlobalTimeline:(id)sender {
    
    cellIdentifier = @"loadingCell";
    [self.tableView reloadData];
    
    NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"userSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSDictionary *postDictionary = dataArray[indexPath.row];
    NSDictionary *user = [postDictionary objectForKey:@"user"];
    
    ((UserTableViewController*)segue.destinationViewController).userId = [user objectForKey:@"id"];
    
    ((UserTableViewController*)segue.destinationViewController).title = [user objectForKey:@"username"];    
}

@end
