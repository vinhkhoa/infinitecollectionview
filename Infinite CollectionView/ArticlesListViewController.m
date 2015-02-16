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

static CGFloat const kCellWidth = 80;
static CGFloat const kCellHeight = 60;
static CGFloat const kCellMargin = 15;

static NSString *const kCellID = @"cellID";
static int const kDataSize = 40;
static int const kInsertSize = 10;

static int const kMinTag = 1;
static int const kMaxTag = 10000;
static int const kInitialTag = 1;

static int const kBatchSizePortrait = 3;
static int const kBatchSizeLandscape = 5;

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

	for (int i = 1; i <= kDataSize; i++)
	{
		[_arrArticles addObject:[Article articleWithTag:(i + kInitialTag - 1)]];
	}
}

- (NSUInteger)articlesBatchSize
{
	return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? kBatchSizeLandscape : kBatchSizePortrait;
}


#pragma mark - UIViewControllerRotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	self.collectionView.rotating = YES;
	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	self.collectionView.rotating= NO;
}


#pragma mark - Find multiple from divisor & thredshold

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


#pragma mark - UICollectionViewDataSource

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


#pragma mark - VKInfiniteCollectionViewDataSource

- (void)prependDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView completionBlock:(void (^)(BOOL, NSUInteger))completionBlock
{
	BOOL success = NO;
	NSUInteger shiftIndex = 0;

	// Anything to prepend?
	if ([self hasDataToPrepend])
	{
		Article *firstArticle = _arrArticles[0];
		NSUInteger firstTag = firstArticle.tag;

		// Get the tags for the new articles to be prepended
		NSUInteger potentialInsertFromTag;
		if (firstTag >= kMinTag + kInsertSize)
		{
			potentialInsertFromTag = firstTag - kInsertSize;
		}
		else
		{
			potentialInsertFromTag = kMinTag;
		}
		NSUInteger insertSize = [self biggestMultipleOfDivisor:[self articlesBatchSize] notMoreThan:(firstTag - potentialInsertFromTag)];
		NSUInteger insertToTag = firstTag - 1;
		NSUInteger insertFromTag = MAX(insertToTag - insertSize + 1, 0);

		// Insert articles
		for (NSUInteger i = insertToTag; i >= insertFromTag; i--)
		{
			[_arrArticles insertObject:[Article articleWithTag:i] atIndex:0];
		}

		_arrArticles = [NSMutableArray arrayWithArray:[_arrArticles subarrayWithRange:NSMakeRange(0, MIN(kDataSize, _arrArticles.count))]];

		// Record the result
		NSUInteger firstArticleNewIndex = [_arrArticles indexOfObject:firstArticle];
		shiftIndex = firstArticleNewIndex;
		success = YES;
	}

	completionBlock(success, shiftIndex);
}

- (void)appendDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView completionBlock:(void (^)(BOOL, NSUInteger))completionBlock
{
	BOOL success = NO;
	NSUInteger shiftIndex = 0;

	// Anything to append?
	if ([self hasDataToAppend])
	{
		Article *lastArticle = _arrArticles.lastObject;
		NSUInteger lastArticlePrevIndex = _arrArticles.count - 1;
		NSUInteger lastTag = lastArticle.tag;

		// Get the tags for the new articles to be inserted
		NSUInteger insertFromTag = lastTag + 1;
		NSUInteger insertToTag = MIN(lastTag + kInsertSize, kMaxTag);
		NSUInteger insertSize = MAX(insertToTag - insertFromTag + 1, 0);

		// Insert articles
		for (NSUInteger i = insertFromTag; i <= insertToTag; i++)
		{
			[_arrArticles addObject:[Article articleWithTag:i]];
		}

		// Trim the new array
		NSUInteger deleteSize = [self smallestMultipleOfDivisor:[self articlesBatchSize] notLessThan:insertSize];
		[_arrArticles removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, deleteSize)]];

		// Record the result
		NSUInteger lastArticleNewIndex = [_arrArticles indexOfObject:lastArticle];
		shiftIndex = lastArticlePrevIndex - lastArticleNewIndex;
		success = YES;
	}

	completionBlock(success, shiftIndex);
}


#pragma mark - Article conditions

- (BOOL)hasDataToPrepend
{
	return ((Article *)_arrArticles[0]).tag > kMinTag;
}

- (BOOL)hasDataToAppend
{
	return ((Article *)_arrArticles.lastObject).tag < kMaxTag;
}

@end
