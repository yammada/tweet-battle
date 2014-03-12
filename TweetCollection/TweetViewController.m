//
//  TweetViewController.m
//  TweetCollection
//
//  Created by Adam May on 3/8/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetController.h"

@interface UIColor (Random)

+ (UIColor *)randomColor;

@end

@implementation UIColor (Random)

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:1.0];
}

@end

@interface TweetViewController ()

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TweetController *tweetController;

@end


@implementation TweetViewController

- (IBAction)addRandomTweet:(id)sender
{
    int section = arc4random_uniform(2);
    NSMutableArray *array = [self tweetsForSection:section];
    [array addObject:@"#mobilemarch"];

    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:array.count - 1 inSection:section]]];
}

- (void)viewDidLoad
{
    self.tweets = @[[NSMutableArray arrayWithArray:@[@"#mobilemarch"]],
                    [NSMutableArray arrayWithArray:@[@"#mobilemarch"]]];
    
    self.tweetController = [[TweetController alloc] init];
    [self.tweetController startStreamingTweetsForHashtag:@"#sxsw"];

}

- (NSMutableArray *)tweetsForSection:(NSInteger)section
{
    return self.tweets[section];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self tweetsForSection:section].count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.tweets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor randomColor];
    
    return cell;
}

@end
