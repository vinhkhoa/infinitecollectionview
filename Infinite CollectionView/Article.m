//
//  Article.m
//  Infinite CollectionView
//
//  Created by Vinh Khoa Nguyen on 15/02/2015.
//  Copyright (c) 2015 Vinh Khoa Nguyen. All rights reserved.
//

#import "Article.h"

@implementation Article

+ (instancetype)articleWithTag:(NSUInteger)tag
{
	Article *result = [Article new];
	result.tag = tag;

	return result;
}

- (NSString *)title
{
	return [NSString stringWithFormat:@"%ld", (long)self.tag];
}

@end
