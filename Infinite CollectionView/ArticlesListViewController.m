//
//  ArticlesListViewController.m
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import "ArticlesListViewController.h"
#import "ArticleCollectionViewCell.h"
#import "Article.h"

static CGFloat const kCellWidth = 135;
static CGFloat const kCellHeight = 60;
static CGFloat const kCellMargin = 15;

static NSString *const kCellID = @"cellID";
static int const kDataSize = 30;
static int const kInsertBatchSize = 10;
static int const kMaxTag = 100;

static int const kDeleteBatchSizePortrait = 2;
static int const kDeleteBatchSizeLandscape = 3;

@implementation ArticlesListViewController
{
	NSMutableArray *_arrArticles;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = @"Infinite CollectionView";

	// CollectionView flowLayout
	UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	flowLayout.minimumInteritemSpacing = kCellMargin;
	flowLayout.minimumLineSpacing = kCellMargin;
	flowLayout.itemSize = CGSizeMake(kCellWidth, kCellHeight);

	// CollectionView
	self.collectionView = [[VKInfiniteCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
	[self.collectionView registerClass:[ArticleCollectionViewCell class] forCellWithReuseIdentifier:kCellID];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.backgroundColor = [UIColor colorWithRed:200 green:200 blue:200 alpha:1];
	self.collectionView.contentInset = UIEdgeInsetsMake(kCellMargin, 0, kCellMargin, 0);
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.collectionView];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];

	[self refreshData];
}

- (void)refreshData
{
	_arrArticles = [NSMutableArray array];

	for (int i = 0; i < kDataSize; i++)
	{
		[_arrArticles addObject:[Article articleWithTag:i]];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSUInteger)articlesBatchSize
{
	return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? kDeleteBatchSizeLandscape : kDeleteBatchSizePortrait;
}

/// Find the smallest number that is a multiple of a divisor that is bigger than or equal to thredshold
- (NSUInteger)smallestMultipleOfDivisor:(NSUInteger)divisor notLessThan:(NSUInteger)thredshold
{
	NSUInteger result;
	if (thredshold % divisor == 0)
	{
		result = thredshold;
	}
	else
	{
		result = (floor((CGFloat)thredshold / divisor) + 1) * divisor;
	}

	return result;
}

- (NSUInteger)biggestMultipleOfDivisor:(NSUInteger)divisor notMoreThan:(NSUInteger)thredshold
{
	NSUInteger result;
	if (thredshold % divisor == 0)
	{
		result = thredshold;
	}
	else
	{
		result = floor((CGFloat)thredshold / divisor) * divisor;
	}

	return result;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(0, kCellMargin, 0, kCellMargin);
}


#pragma mark - VKInfiniteCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _arrArticles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ArticleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];

	[cell setupWithArticle:_arrArticles[indexPath.row]];

	return cell;
}

- (void)prependDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView completionBlock:(void (^)(BOOL, NSUInteger))completionBlock
{
	BOOL success = NO;
	NSUInteger shiftIndex = 0;

	// Check if there is any data to prepend to the current array
	Article *firstArticle = _arrArticles[0];
	NSInteger firstTag = firstArticle.tag;
	if (firstTag > 0)
	{
		// Get the tags for the new articles to be inserted
		NSInteger insertFromTag = MAX(firstTag - kInsertBatchSize, 0);
		NSUInteger insertSize = [self biggestMultipleOfDivisor:[self articlesBatchSize] notMoreThan:(firstTag - insertFromTag)];
		NSInteger insertToTag = firstTag - 1;

		// Adjust the insert from tag
		insertFromTag = insertToTag - insertSize + 1;

		// Insert articles
		for (NSInteger i = insertToTag; i >= insertFromTag; i--)
		{
			[_arrArticles insertObject:[Article articleWithTag:i] atIndex:0];
		}

		// Trim the new array
		//NSUInteger deleteSize = [self smallestMultipleOfDivisor:[self articlesBatchSize] notLessThan:(insertToTag - insertFromTag + 1)];
		//[_arrArticles removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, deleteSize)]];

		_arrArticles = [NSMutableArray arrayWithArray:[_arrArticles subarrayWithRange:NSMakeRange(0, MIN(kDataSize, _arrArticles.count))]];

		// Record the result
		success = YES;
		shiftIndex = [_arrArticles indexOfObject:firstArticle] - 1;
	}

	completionBlock(success, shiftIndex);
}

- (void)appendDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView completionBlock:(void (^)(BOOL, NSUInteger))completionBlock
{
	BOOL success = NO;
	NSUInteger shiftIndex = 0;

	// Check if there is any data to append to the current array
	Article *lastArticle = _arrArticles.lastObject;
	NSUInteger lastArticlePrevIndex = _arrArticles.count - 1;
	NSInteger lastTag = lastArticle.tag;
	if (lastTag < kMaxTag)
	{
		// Get the tags for the new articles to be inserted
		NSInteger insertFromTag = lastTag + 1;
		NSInteger insertToTag = MIN(lastTag + kInsertBatchSize, kMaxTag);

		// Insert articles
		for (NSInteger i = insertFromTag; i <= insertToTag; i++)
		{
			[_arrArticles addObject:[Article articleWithTag:i]];
		}

		// Trim the new array
		NSUInteger deleteSize = [self biggestMultipleOfDivisor:[self articlesBatchSize] notMoreThan:(insertToTag - insertFromTag + 1)];
		[_arrArticles removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, deleteSize)]];

		// Record the result
		success = YES;
		NSUInteger lastArticleNewIndex = [_arrArticles indexOfObject:lastArticle];
		shiftIndex = lastArticlePrevIndex - lastArticleNewIndex - 1;
	}

	completionBlock(success, shiftIndex);
}


@end
