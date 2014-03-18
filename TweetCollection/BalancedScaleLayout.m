#import "BalancedScaleLayout.h"
#import "BeamAttachmentBehavior.h"
#import "BeamView.h"

static CGSize const kItemSize = {40.0f, 40.0f};

@interface BalancedScaleLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@end

@implementation BalancedScaleLayout

#pragma mark - Init methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self registerClass:[BeamView class] forDecorationViewOfKind:[BeamView kind]];

        self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    
    return self;
}

#pragma mark - Private methods

- (CGRect)beamFrame
{
    CGFloat beamWidth = 0.5 * self.collectionViewContentSize.width;
    
    return (CGRect)
    {
        .origin.x = CGRectGetMidX(self.collectionView.bounds) - beamWidth * 0.5,
        .origin.y = CGRectGetMidY(self.collectionView.bounds),
        .size.width = beamWidth,
        .size.height = 10.0f
    };
}

- (CGRect)itemFrame
{
    return (CGRect)
    {
        .origin.x = CGRectGetMidX(self.collectionView.bounds) - kItemSize.width * 0.5,
        .origin.y = CGRectGetMaxY(self.collectionView.bounds) + kItemSize.height,
        .size = kItemSize
    };
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForDecorationViewOfKind:decorationViewKind
                                                      atIndexPath:indexPath];
}

- (void)prepareLayout
{
    if (self.animator.behaviors.count == 0)
    {
        UICollectionViewLayoutAttributes *beam = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[BeamView kind]
                                                                                                             withIndexPath:[BeamView indexPath]];
        beam.frame = [self beamFrame];
        
        UIDynamicItemBehavior *beamProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[beam]];
        beamProperties.angularResistance = 300.0f;
        [self.animator addBehavior:beamProperties];
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:beam
                                                                             attachedToAnchor:beam.center];
        [self.animator addBehavior:attachmentBehavior];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[beam]];
        [self.animator addBehavior:gravity];
        self.gravityBehavior = gravity;
        
        UICollisionBehavior *collisions = [[UICollisionBehavior alloc] initWithItems:@[]];
        [self.animator addBehavior:collisions];
        self.collisionBehavior = collisions;
    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    for (UICollectionViewUpdateItem *item in updateItems)
    {
        if (item.updateAction == UICollectionUpdateActionInsert)
        {
            NSIndexPath *path = item.indexPathAfterUpdate;
            UICollectionViewLayoutAttributes *item = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
            item.frame = [self itemFrame];
            
            UICollectionViewLayoutAttributes *beam = [self layoutAttributesForDecorationViewOfKind:[BeamView kind]
                                                                                       atIndexPath:[BeamView indexPath]];
            BeamAttachmentBehavior *beamAttachment = [[BeamAttachmentBehavior alloc]
                                                      initWithItem:item
                                                      attachedToBeam:beam
                                                      onLeft:(item.indexPath.section == 0)];
            [self.animator addBehavior:beamAttachment];
            
            [self.collisionBehavior addItem:item];
        }
    }
}

@end
