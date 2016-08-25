//
//  PSAssetsLibrary.h
//  PSPhotoAlbum
//
//  Created by Ryan_Man on 16/8/24.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _API_UNAVAILABLE(INFO)    __attribute__((unavailable(INFO)))

NS_ASSUME_NONNULL_BEGIN

#define PSAssetsLibraryInstance  [PSAssetsLibrary  shareInstance]

@interface PSAssetsLibrary : NSObject

+ (instancetype)new _API_UNAVAILABLE("使用shareInstance来获取实例");

/**
 *  单列
 *
 *  @return
 */
+ (PSAssetsLibrary*)shareInstance;

/**
 *  检查 App 是否有照片操作授权
 *
 *  @param target 响应对象
 *  @param block  响应对象回调事件
 */
- (void)ps_HandlePhotosAlbumVaildEventWithTarget:(id)target withBlock:(void (^)(id sender))block;

/**
 *  创建相簿
 *
 *  @param albumName    相簿名称
 *  @param failureBlock 
 */
- (void)ps_AddAssetsGroupAlbumWithName:(NSString*)albumName failureBlock:(void (^)(NSString *error))failureBlock;


/**
 *  保存图片到自定义相簿
 *
 *  @param metadata        图片信息
 *  @param imageData       图片资源数据
 *  @param customAlbumName 自定义相簿名称
 *  @param completionBlock
 *  @param failureBlock
 */
- (void)ps_SaveToAlbumWithMetadata:(nullable NSDictionary *)metadata  imageData:(NSData *)imageData  customAlbumName:(NSString *)customAlbumName completionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(NSString *error))failureBlock;

@end
NS_ASSUME_NONNULL_END
