//
//  ArticlesListViewController.h
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKInfiniteCollectionView.h"

@interface ArticlesListViewController : UIViewController <VKInfiniteCollectionViewDataSource, VKInfiniteCollectionViewDelegate>

@property (strong, nonatomic) VKInfiniteCollectionView *collectionView;

@end

