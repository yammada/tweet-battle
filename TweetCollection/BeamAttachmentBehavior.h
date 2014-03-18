#import <UIKit/UIKit.h>

@interface BeamAttachmentBehavior : UIDynamicBehavior

- (instancetype)initWithItem:(id<UIDynamicItem>)item
              attachedToBeam:(id<UIDynamicItem>)beam
                      onLeft:(BOOL)left;

@end
