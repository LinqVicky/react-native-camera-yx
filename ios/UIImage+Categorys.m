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
 *	@brief	缩放图片为指定大小
 *
 *	@param 	size 	缩放的图片大小
 *
 *	@return	缩放后的图片
 */
-(UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    if (self.size.width > self.size.height) {                                   // 交换宽高
        size.width = size.width + size.height;
        size.height = size.width - size.height;
        size.width  = size.width - size.height;
    }
    
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
    
   
    
    return scaledImage;
}

/**
 *	@brief	创建图片，并加上文字 缩放图片为指定大小
 *
 *	@param 	size 	缩放的图片大小
 *
 *	@return	缩放后的图片
 */
-(UIImage*)createImage:(CGSize)size text:(NSString*)text orientation:(UIImageOrientation)orientation
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
//    if (self.size.width > self.size.height) {                                   // 交换宽高
//        size.width = size.width + size.height;
//        size.height = size.width - size.height;
//        size.width  = size.width - size.height;
//    }
    
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
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
/**
 *	@brief	创建指定大小带圆角效果的图片对象
 *
 *	@param 	size 	图片大小
 *
 *	@return	创建得到的图片
 */
- (UIImage *)createRoundedRectImageWithsize:(CGSize)size 
{
    // the size of CGContextRef
//    int w = size.width;
//    int h = size.height;
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    CGRect rect = CGRectMake(0, 0, w, h);
//    
//    CGContextBeginPath(context);
//    addRoundedRectToPath(context, rect, 5, 5);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    return [UIImage imageWithCGImage:imageMasked];
    return nil;
}

@end
