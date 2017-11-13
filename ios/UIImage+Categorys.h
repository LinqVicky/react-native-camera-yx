//
//  UIImage+Categorys.h
//  CRM
//
//  Created by Apple on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	@brief	UIImage分类
 */
@interface UIImage (Categorys)

/**
 *	@brief	创建指定大小带圆角效果的图片对象
 *
 *	@param 	size 	图片大小
 *
 *	@return	创建得到的图片
 */
- (UIImage *)createRoundedRectImageWithsize:(CGSize)size;

/**
 *	@brief	创建图片，并加上文字 缩放图片为指定大小
 *
 *	@param 	size 	缩放的图片大小
 *
 *	@return	缩放后的图片
 */
-(UIImage*)createImage:(CGSize)size text:(NSString*)text orientation:(UIImageOrientation)orientation;

@end
