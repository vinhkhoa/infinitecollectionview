//
//  ArticlePageCollectionViewCell.h
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface ArticleCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) Article *article;

- (void)setupWithArticle:(Article *)article;

@end
