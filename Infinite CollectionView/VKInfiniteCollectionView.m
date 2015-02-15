//
//  VKInfiniteCollectionView.m
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import "VKInfiniteCollectionView.h"

static NSUInteger const kDefaultReloadMargin = 50;

@implementation VKInfiniteCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
	if (self = [super initWithFrame:frame collectionViewLayout:layout])
	{
		self.showsVerticalScrollIndicator = NO;
		self.reloadMargin = kDefaultReloadMargin;
	}

	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	// Prepend data?
	if (self.contentOffset.y < -self.contentInset.top)
	{
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(prependDataForInfiniteCollectionView:completionBlock:)])
		{
			[self.dataSource prependDataForInfiniteCollectionView:self completionBlock:^(BOOL success, NSUInteger shiftIndex) {
				if (success)
				{
					[self reloadDataShiftingCellByIndex:shiftIndex];
				}
			}];
		}
	}

	// Append data?
	if (self.contentSize.height > 0 && self.contentOffset.y > (self.contentSize.height - CGRectGetHeight(self.bounds) - self.reloadMargin))
	{
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(appendDataForInfiniteCollectionView:completionBlock:)])
		{
			[self.dataSource appendDataForInfiniteCollectionView:self completionBlock:^(BOOL success, NSUInteger shiftIndex) {
				if (success)
				{
					[self reloadDataShiftingCellByIndex:-shiftIndex];
				}
			}];
		}
	}
}

- (void)reloadDataShiftingCellByIndex:(NSInteger)shiftingIndex
{
	// Get the position of the top visible items
	NSIndexPath *fromIndexPath = self.indexPathsForVisibleItems[0];
	NSUInteger fromIndex = fromIndexPath.row;
	UICollectionViewLayoutAttributes *fromAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:fromIndexPath];
	CGFloat fromY = CGRectGetMinY(fromAttributes.frame);

	// Get the position of that same item after it has been shifted
	NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:(fromIndex + shiftingIndex) inSection:0];
	UICollectionViewLayoutAttributes *toAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:toIndexPath];
	CGFloat toY = CGRectGetMinY(toAttributes.frame);

	// Adjust the contentOffset to keep the collectionView at the same 'position' after new data is loaded
	CGPoint currentOffset = self.contentOffset;
	CGFloat newOffsetY = currentOffset.y + (toY - fromY);
	[self setContentOffset:CGPointMake(currentOffset.x, newOffsetY)];

	[self reloadData];
}

@end
