//
//  TweetController.m
//  TweetCollection
//
//  Created by Adam May on 3/9/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import "TweetController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TweetController () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSMutableString *incomingStream;

@end

@implementation TweetController

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)startStreamingTweetsForHashtag:(NSString *)hashtag
{
    if ([self userHasAccessToTwitter])
    {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:Nil completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                NSArray *twitterAccounts =
                [self.accountStore accountsWithAccountType:twitterAccountType];

                NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
                NSDictionary *params = @{@"track" : hashtag};
                SLRequest *request =
                [SLRequest requestForServiceType:SLServiceTypeTwitter
                                   requestMethod:SLRequestMethodGET
                                             URL:url
                                      parameters:params];
                
                //  Attach an account to the request
                [request setAccount:[twitterAccounts lastObject]];
                
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                      delegate:self
                                                                 delegateQueue:nil];
                
                
                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[request preparedURLRequest]];
                [dataTask resume];
            }
        }];
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.incomingStream = [NSMutableString string];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.incomingStream appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    NSRange delimiter = [self.incomingStream rangeOfString:@"\r\n"];
    while (delimiter.location != NSNotFound)
    {
        NSRange statusRange = NSMakeRange(0, delimiter.location);
        NSString *status = [self.incomingStream substringWithRange:statusRange];
        
        [self.incomingStream deleteCharactersInRange:statusRange];
        
        assert([self.incomingStream characterAtIndex:0] == '\r');
        assert([self.incomingStream characterAtIndex:1] == '\n');
        
        [self.incomingStream deleteCharactersInRange:NSMakeRange(0, 2)];

        delimiter = [self.incomingStream rangeOfString:@"\r\n"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __autoreleasing NSError *jsonError;
            id json = [NSJSONSerialization JSONObjectWithData:[status dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
            
            NSLog(@"json = %@", json);
            
        });
    }
}

@end
