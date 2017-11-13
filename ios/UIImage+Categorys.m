//
//  UIImage+Categorys.m
//  CRM
//
//  Created by zouzhushi on 2017/11/11.
//  Copyright © 2017年 XiaMen Yaxon NetWorks Co., LTD. All rights
//

#import "UIImage+Categorys.h"


static void addRoundedRectToPath(CGContextRef context, 
                                 CGRect rect, 
                                 float ovalWidth,
                                 float ovalHeight) {
    
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
#pragma mark change the corner size below...
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


@implementation UIImage (Categorys)

/**
 *	@brief	创建图片，并加上文字 缩放图片为指定大小
 *
 *	@param 	size 	缩放的图片大小
 *
 *	@return	缩放后的图片
 */
-(UIImage*)createImage:(CGSize)size text:(NSString*)text orientation:(UIImageOrientation)orientation
{
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    else
        UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    if (text == nil) {
        return scaledImage;
    }
    
    
    return [self addText:scaledImage text:text orientation:orientation];
}

/**
 *	@brief	为图片加上文字水印 文字为时间和地址
 *
 *	@param 	text 	内容
 *
 *	@return	为图片增加文字
 */
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1 orientation:(UIImageOrientation)orientation
{
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    CGContextRef cntxRef = UIGraphicsGetCurrentContext();
    [img drawInRect:CGRectMake(0, 0, w, h)];
    CGContextSaveGState(cntxRef);
    int temp=-1;
    switch (orientation) {
        case UIImageOrientationUp://上
            CGContextTranslateCTM(cntxRef, 0, h);
            temp=w;
            w=h;
            h=temp;
            CGContextRotateCTM(cntxRef, -M_PI_2);
            break;
        
        case UIImageOrientationDown://下
            CGContextTranslateCTM(cntxRef, w, 0);
            temp=w;
            w=h;
            h=temp;
            CGContextRotateCTM(cntxRef, M_PI_2);
            break;
        case UIImageOrientationLeft://左
            break;
        case UIImageOrientationRight://右
            CGContextTranslateCTM(cntxRef, w, h);
            CGContextRotateCTM(cntxRef, M_PI);
            break;
    }
    [[UIColor redColor] set];
    NSArray *array = [text1 componentsSeparatedByString:@";"];
    NSMutableString *value=[[NSMutableString alloc]init];
    NSInteger rowNum=0;
    for(int i=0;i<[array count];i++){
        NSString *item=array[i];
        if(item!=nil&&item.length>0){
            rowNum++;
            [value appendString:item];
            if(i<[array count]-1){
                [value appendString:@"\n"];
            }
        }
    }
    [value drawInRect:CGRectMake(10, h-rowNum*30, w-20, rowNum*30) withFont:[UIFont systemFontOfSize:20]];
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(cntxRef);
    UIGraphicsEndImageContext();
    img = nil;
    return aimg;
}
@end
