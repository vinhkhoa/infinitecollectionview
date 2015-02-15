//
//  VKInfiniteCollectionView.h
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKInfiniteCollectionView;

#pragma mark - DataSource
@protocol VKInfiniteCollectionViewDataSource <UICollectionViewDataSource>

@required
- (void)prependDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView;
- (void)appendDataForInfiniteCollectionView:(VKInfiniteCollectionView *)collectionView;

@end

#pragma mark - Delegate
@protocol VKInfiniteCollectionViewDelegate <UICollectionViewDelegate>

@end

#pragma mark - Interface
@interface VKInfiniteCollectionView : UICollectionView

@end
