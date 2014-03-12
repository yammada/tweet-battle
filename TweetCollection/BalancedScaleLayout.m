//
//  BalancedScaleLayout.m
//  TweetCollection
//
//  Created by Adam May on 3/8/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import "BalancedScaleLayout.h"

@interface BeamView : UICollectionReusableView

+ (NSString *)kind;

@end

@implementation BeamView

+ (NSString *)kind
{
    return NSStringFromClass(self);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

@end

@interface BalancedScaleLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collisions;

@end

@implementation BalancedScaleLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self registerClass:[BeamView class] forDecorationViewOfKind:[BeamView kind]];
    }
    
    return self;
}

- (UIOffset)beamOffsetForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat beamWidth = 0.5 * self.collectionViewContentSize.width;
    if (indexPath.section == 0)
    {
        return UIOffsetMake(-beamWidth * 0.5 + 10, 0);
    }
    else
    {
        return UIOffsetMake(beamWidth * 0.5 - 10, 0);
    }
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize
{
    return self.collectionView.frame.size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

- (void)prepareLayout
{
    if (self.animator == nil)
    {
        self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    
    if (self.animator.behaviors.count == 0)
    {
        //Add items to the animator
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++)
        {
            NSInteger cellCount = [self.collectionView numberOfItemsInSection:section];
            
            for (NSInteger i = 0; i < cellCount; i++)
            {
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:section];
                
                UICollectionViewLayoutAttributes *item = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
                item.frame = CGRectMake(0.5 * self.collectionViewContentSize.width,
                                        self.collectionViewContentSize.height + 20,
                                        20, 20);
                [items addObject:item];
            }
        }
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:items];
        [self.animator addBehavior:gravity];
        
        UICollisionBehavior *collisions = [[UICollisionBehavior alloc] initWithItems:items];
        [self.animator addBehavior:collisions];
        
        // Create decoration views and add them to the animator
        UICollectionViewLayoutAttributes *beam = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[BeamView kind]
                                                                                                             withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        beam.size = CGSizeMake(0.5 * self.collectionViewContentSize.width, 10);
        beam.center = CGPointMake(0.5 * self.collectionViewContentSize.width,
                                  0.25 * self.collectionViewContentSize.height);
        [gravity addItem:beam];
        
        UIDynamicItemBehavior *beamProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[beam]];
        beamProperties.angularResistance = 300.0;
        [self.animator addBehavior:beamProperties];
        
        UIAttachmentBehavior *beamAttachment = [[UIAttachmentBehavior alloc] initWithItem:beam attachedToAnchor:beam.center];
        [self.animator addBehavior:beamAttachment];
        
        for (UICollectionViewLayoutAttributes *item in items)
        {
            UIOffset attachmentOffset = [self beamOffsetForIndexPath:item.indexPath];
            
            UIAttachmentBehavior *itemBeamAttachment = [[UIAttachmentBehavior alloc] initWithItem:item offsetFromCenter:UIOffsetZero attachedToItem:beam offsetFromCenter:attachmentOffset];
            itemBeamAttachment.length = 60.0;
            itemBeamAttachment.damping = 0.4;
            itemBeamAttachment.frequency = 1.0;
            [self.animator addBehavior:itemBeamAttachment];
        }
        
        self.gravity = gravity;
        self.collisions = collisions;
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
            item.frame = CGRectMake(0.5 * self.collectionViewContentSize.width,
                                    self.collectionViewContentSize.height + 20,
                                    20, 20);
            
            UIOffset attachmentOffset = [self beamOffsetForIndexPath:path];
            
            UICollectionViewLayoutAttributes *beam = [self layoutAttributesForDecorationViewOfKind:[BeamView kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            UIAttachmentBehavior *itemBeamAttachment = [[UIAttachmentBehavior alloc] initWithItem:item offsetFromCenter:UIOffsetZero attachedToItem:beam offsetFromCenter:attachmentOffset];
            itemBeamAttachment.length = 60.0;
            itemBeamAttachment.damping = 0.4;
            itemBeamAttachment.frequency = 1.0;
            [self.animator addBehavior:itemBeamAttachment];
            
            [self.gravity addItem:item];
            [self.collisions addItem:item];
            
        }
    }
}

@end
