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
static NSUInteger const batchSize = 20;

@implementation ArticlesListViewController
{
	NSMutableArray *_arrArticles;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

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
	self.collectionView.contentInset = UIEdgeInsetsMake(kCellMargin, kCellMargin, kCellMargin, kCellMargin);
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

	for (int i = 1; i <= 20; i++)
	{
		[_arrArticles addObject:[Article articleWithTag:i]];
	}
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

- (void)prependDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView
{
	// Check if there is any data to prepend to the current array
	NSInteger firstTag = ((Article *)_arrArticles[0]).tag;
	if (firstTag > 0)
	{
		NSInteger insertFromTag = MAX(firstTag - batchSize, 0);
		NSInteger insertToTag = firstTag - 1;

		for (NSInteger i = insertToTag; i >= insertFromTag; i--)
		{
			[_arrArticles insertObject:[Article articleWithTag:i] atIndex:0];
		}

		// Trim the array to keep its size
		[_arrArticles removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(batchSize, insertToTag - insertFromTag + 1)]];
	}
}

- (void)appendDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView
{
	NSUInteger lastTag = ((Article *)_arrArticles.lastObject).tag;

	NSInteger insertFromTag = lastTag + 1;
	NSInteger insertToTag = lastTag + batchSize - 1;

	for (NSInteger i = insertToTag; i >= insertFromTag; i--)
	{
		[_arrArticles addObject:[Article articleWithTag:i]];
	}

	// Trim the array to keep its size
	[_arrArticles removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertToTag - insertFromTag + 1)]];
}

#pragma mark - VKInfiniteCollectionViewDelegate

@end
