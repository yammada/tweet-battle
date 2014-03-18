#import <Mantle/Mantle.h>

@interface Tweet : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *profileImageURL;
@property (nonatomic, copy, readonly) NSString *text;

@end
