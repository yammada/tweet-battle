//
//  TweetController.h
//  TweetCollection
//
//  Created by Adam May on 3/9/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetController : NSObject

- (void)startStreamingTweetsForHashtag:(NSString *)hashtag;

@end

@protocol TweetStreamerDelegate <NSObject>



@end
