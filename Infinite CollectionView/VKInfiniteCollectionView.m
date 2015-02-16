//
//  VKInfiniteCollectionView.m
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import "VKInfiniteCollectionView.h"
#import "ArticleCollectionViewCell.h"
#import "Article.h"

@implementation VKInfiniteCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
	if (self = [super initWithFrame:frame collectionViewLayout:layout])
	{
		self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO;
	}

	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	// Do nothing if the collectionView is rotating
	if (!self.rotating)
	{
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
		if (self.contentSize.height > 0 && self.contentOffset.y > (self.contentSize.height - CGRectGetHeight(self.bounds)))
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
}

- (void)reloadDataShiftingCellByIndex:(NSInteger)shiftingIndex
{
	// Sometimes indexPathsForVisibleItems returns an empty array. In that case, just reloadData and move on
	if (self.indexPathsForVisibleItems.count == 0)
	{
		NSLog(@"empty visible items");

		[self reloadData];
		[self.collectionViewLayout invalidateLayout];
		[self.collectionViewLayout prepareLayout];
	}
	else
	{
		// Sort the array of visible indexPaths
		NSArray *arrVisibleIndexPaths = [self.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *indexPath1, NSIndexPath *indexPath2) {
			if (indexPath1.row > indexPath2.row)
			{
				return NSOrderedDescending;
			}
			else if (indexPath1.row < indexPath2.row)
			{
				return NSOrderedAscending;
			}
			else
			{
				return NSOrderedSame;
			}
		}];

		// Get the position of the top visible items
		NSIndexPath *fromIndexPath = arrVisibleIndexPaths[0];
		UICollectionViewLayoutAttributes *fromAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:fromIndexPath];
		CGFloat fromY = CGRectGetMinY(fromAttributes.frame);

		[self reloadData];
		[self.collectionViewLayout invalidateLayout];
		[self.collectionViewLayout prepareLayout];

		// Get the position of that same item after it has been shifted
		NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:(fromIndexPath.row + shiftingIndex) inSection:0];
		UICollectionViewLayoutAttributes *toAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:toIndexPath];
		CGFloat toY = CGRectGetMinY(toAttributes.frame);

		// Adjust the contentOffset to keep the collectionView at the same 'position' after new data is loaded
		[self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + (toY - fromY))];
	}
}

@end
