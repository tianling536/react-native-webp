#import "DBAWebpImageDecoder.h"
#include "WebP/decode.h"
#include "WebP/demux.h"

static void free_data(void *info, const void *data, size_t size)
{
    free((void *) data);
}

@implementation DBAWebpImageDecoder

RCT_EXPORT_MODULE()

- (BOOL)canDecodeImageData:(NSData *)imageData
{
    int result = WebPGetInfo([imageData bytes], [imageData length], NULL, NULL);
    if (result == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (RCTImageLoaderCancellationBlock)decodeImageData:(NSData *)imageData
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(UIViewContentMode)resizeMode
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler
{
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    
    UIImage *image;
    WebPBitstreamFeatures features;
    WebPGetFeatures([imageData bytes], [imageData length], &features);
    
    int width = 0, height = 0;
    uint8_t *data = WebPDecodeRGBA([imageData bytes], [imageData length], &width, &height);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_data);


    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];

    CGDataProviderRelease(provider);
    CGImageRelease(imageRef);
    
    CGColorSpaceRelease(colorSpaceRef);
    completionHandler(nil, image);
    return ^{};
}
@end
