//
//  Article.h
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (strong, nonatomic, readonly) NSString *title;
@property (assign, nonatomic) NSInteger tag;

+ (instancetype)articleWithTag:(NSInteger)tag;

@end
