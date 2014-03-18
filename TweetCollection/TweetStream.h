#import <Foundation/Foundation.h>

@class Tweet;
@protocol TweetStreamDelegate;

@interface TweetStream : NSObject

@property (nonatomic, weak) id<TweetStreamDelegate> delegate;

- (void)startStreamingTweetsWithKeywords:(NSString *)keywords;
- (void)stopStreaming;

@end

@protocol TweetStreamDelegate <NSObject>

- (void)stream:(TweetStream *)stream didRecieveTweet:(Tweet *)tweet;

@end
