//
//  PSPhotoKit.m
//  PSPhotoAlbum
//
//  Created by Ryan_Man on 16/8/25.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSPhotoKit.h"
#import <Photos/Photos.h>
@implementation PSPhotoKit

+ (PSPhotoKit*)shareInstance
{
    static PSPhotoKit * _photoKit = nil;
    
    static dispatch_once_t onceToken ;
    
    dispatch_once(&onceToken, ^{
       
        _photoKit = [[PSPhotoKit alloc] init];
    });
    
    return _photoKit;
}

#pragma mark - Method -


- (void)ps_Add
{
    //获取相册集合
    PHFetchResult * fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum) subtype:(PHAssetCollectionSubtypeAny) options:[PHFetchOptions new]];
    
    //对获取到的集合进行遍历
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetCollection * assetCollection = obj;

        if ([assetCollection.localizedTitle isEqualToString:@"Camera Roll"])
        {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                
            //请求创建一个Asset
            PHAssetChangeRequest * assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageNamed:@"qzl"]];
             
            //请求编辑相册
            PHAssetCollectionChangeRequest * collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
             
            //为Asset创建一个占位符，放到相册编辑请求中
            PHObjectPlaceholder * objectPlaceholder = [assetRequest placeholderForCreatedAsset];
            
            //相册中添加照片
            [collectonRequest addAssets:@[objectPlaceholder]];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                
                NSLog(@"error : %@",error);
                
            }]; 
        }
  
    }];

}



@end
