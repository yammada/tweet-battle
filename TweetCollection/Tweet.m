//
//  Tweet.m
//  TweetCollection
//
//  Created by Adam May on 3/11/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"profileImageURL": @"user.profile_image_url"};
}

+ (NSValueTransformer *)profileImageURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
