//
//  Tweet.h
//  TweetCollection
//
//  Created by Adam May on 3/11/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Tweet : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *profileImageURL;

@end
