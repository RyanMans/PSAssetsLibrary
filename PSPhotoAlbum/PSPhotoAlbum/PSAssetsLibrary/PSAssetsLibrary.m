//
//  PSAssetsLibrary.m
//  PSPhotoAlbum
//
//  Created by Ryan_Man on 16/8/24.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSAssetsLibrary.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <UIKit/UIKit.h>
@interface PSAssetsLibrary ()

@end

@implementation PSAssetsLibrary

+ (PSAssetsLibrary*)shareInstance
{
    static PSAssetsLibrary * _library = nil;
    
    static   dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _library = [[PSAssetsLibrary alloc] init];
    });
    
    return _library;
}

//主线程
void runBlockWithMain(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

//检查 App 是否有照片操作授权
- (void)ps_HandlePhotosAlbumVaildEventWithTarget:(id)target withBlock:(void (^)(id sender))block
{
    if ([NSThread isMainThread] == NO)
    {
        runBlockWithMain(^{
          
            [self ps_HandlePhotosAlbumVaildEventWithTarget:target withBlock:block];
        });
        return;
    }
    
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    
    if (authorizationStatus == ALAuthorizationStatusNotDetermined || authorizationStatus == ALAuthorizationStatusAuthorized)
    {
        
        if (block)block(target);
        return;
    }
    
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString * appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    NSString * message = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    
    UIAlertView * _albumAlert  = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [_albumAlert show];
    
}

//创建相簿
- (void)ps_AddAssetsGroupAlbumWithName:(NSString *)albumName failureBlock:(void (^)(NSString *error))failureBlock
{
    if ( !albumName || albumName.length == 0)
    {
        runBlockWithMain(^{
           
            if (failureBlock) {
                failureBlock(@"相簿名称不能为空");
            }
        });
        return;
    }
    
    ALAssetsLibrary * _alLibrary = [[ALAssetsLibrary alloc] init];

    __block NSMutableArray * groups = [NSMutableArray array];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listResultsBlock= ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group) {
            
            [groups addObject:group];
        }
        else
        {
            
            BOOL _isHaveGroup = NO;
            
            for (ALAssetsGroup * gp in groups)
            {
                NSString * name = [gp valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:albumName])
                {
                    _isHaveGroup = YES;
                }
            }
            if (!_isHaveGroup)
            {
                [_alLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                   
                    [groups addObject:group];
                    
                } failureBlock:^(NSError *error) {
                    
                   runBlockWithMain(^{
                       
                       if (failureBlock) {
                           failureBlock(error.localizedDescription);
                       }
                   });
                }];
                
                _isHaveGroup = YES;
            }
        }
    };
    
    //创建相簿
    [_alLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listResultsBlock failureBlock:^(NSError *error) {
       
        runBlockWithMain(^{
            
            if (failureBlock) {
                failureBlock(error.localizedDescription);
            }
        });
    }];

}

//添加图片到自定义相簿
- (void)ps_SaveToAlbumWithMetadata:(NSDictionary *)metadata  imageData:(NSData *)imageData  customAlbumName:(NSString *)customAlbumName completionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(NSString *error))failureBlock
{

    if (!customAlbumName || customAlbumName.length == 0)
    {
        runBlockWithMain(^{
            
            if (failureBlock) {
                failureBlock(@"相簿名称不能为空");
            }
        });
        return;
    }
    
    if ( !imageData ||imageData.length == 0)
    {
        runBlockWithMain(^{
            
            if (failureBlock) {
                failureBlock(@"图片不能为空");
            }
        });

        return;
    }
    
    ALAssetsLibrary * _alLibrary = [[ALAssetsLibrary alloc] init];
    
    __weak ALAssetsLibrary * _weakLibrary = _alLibrary;
    
    void(^addAsset)(ALAssetsLibrary * ,NSURL *) = ^(ALAssetsLibrary * assetsLibrary,NSURL * assetURL)
    {
        [_alLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset)
        {
         
            [_alLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
            {
              
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName])
                {
                    [group addAsset:asset];
                    
                    runBlockWithMain(^{
                        
                        if (completionBlock) {
                            completionBlock();
                        }
                    });
                }
                
            } failureBlock:^(NSError *error)
             {
                 runBlockWithMain(^{
                     
                     if (failureBlock) {
                         failureBlock(error.localizedDescription);
                     }
                 });
            }];
            
        } failureBlock:^(NSError *error) {
            
            runBlockWithMain(^{
                
                if (failureBlock) {
                    failureBlock(error.localizedDescription);
                }
            });
        }];
    };

    [_alLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
      
        if (customAlbumName)
        {
            [_alLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                
                if (group)
                {
                    [_weakLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        
                        [group addAsset:asset];
                        
                        runBlockWithMain(^{
                            
                            if (completionBlock) {
                                completionBlock();
                            }
                        });
                        
                        
                    } failureBlock:^(NSError *error)
                    {
                        runBlockWithMain(^{
                            
                            if (failureBlock) {
                                failureBlock(error.localizedDescription);
                            }
                        });
                    }];
                    
                }
                else
                {
                    addAsset(_weakLibrary,assetURL);
                }
                
            } failureBlock:^(NSError *error) {
                
                addAsset(_weakLibrary,assetURL);

          }];
        }
        else
        {
            runBlockWithMain(^{
                
                if (failureBlock) {
                    failureBlock(@"相簿名称不能为空");
                }
            });
        }
    }];
}





@end
