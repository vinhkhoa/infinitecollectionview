//
//  ArticlePageCollectionViewCell.m
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import "ArticleCollectionViewCell.h"
#import "Article.h"

static CGFloat const kPadding = 15;

@implementation ArticleCollectionViewCell
{
	UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Background & border
		self.backgroundColor = [UIColor whiteColor];
		self.layer.borderWidth = 1;
		self.layer.borderColor = [UIColor grayColor].CGColor;

		// Title label
		_titleLabel = [UILabel new];
		_titleLabel.font = [UIFont systemFontOfSize:16];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.numberOfLines = 0;
		_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:_titleLabel];
		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:kPadding]];
		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:kPadding]];
		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-kPadding]];
		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-kPadding]];
	}

	return self;
}

- (void)setupWithArticle:(Article *)article
{
	_article = article;

	_titleLabel.text = _article.title;
}

@end
