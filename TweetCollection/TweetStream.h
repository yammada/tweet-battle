#import <Foundation/Foundation.h>

@class Tweet;
@protocol TweetStreamDelegate;

@interface TweetStream : NSObject

@property (nonatomic, weak) id<TweetStreamDelegate> delegate;

- (void)startStreamingTweetsForHashtag:(NSString *)hashtag;

@end

@protocol TweetStreamDelegate <NSObject>

- (void)stream:(TweetStream *)stream didRecieveTweet:(Tweet *)tweet;

@end
