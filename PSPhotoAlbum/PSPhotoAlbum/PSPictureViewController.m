//
//  PSPictureViewController.m
//  PSPhotoAlbum
//
//  Created by Ryan_Man on 16/8/24.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSPictureViewController.h"
#import "PSAssetsLibrary.h"
#import "PSPhotoKit.h"
@interface PSPictureViewController ()
{
    UIImageView * _pictureView;
}
@end

@implementation PSPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemSave) target:self action:@selector(savePhotoEvent:)];
    
    
    _pictureView = [UIImageView new];
    _pictureView.userInteractionEnabled = YES;
    _pictureView.contentMode = UIViewContentModeScaleAspectFill;
    _pictureView.frame = CGRectMake(0, 128, self.view.frame.size.width, 200);
    _pictureView.backgroundColor = [UIColor whiteColor];
    
    _pictureView.image = [UIImage imageNamed:@"qzl"];
    
    [self.view addSubview:_pictureView];
    
    
    [[PSPhotoKit shareInstance] ps_Add];
    
    return;
    
    
    [PSAssetsLibraryInstance ps_AddAssetsGroupAlbumWithName:@"PSAssetsLibrary" failureBlock:^(NSString * _Nonnull error) {
        
    }];
}

- (void)savePhotoEvent:(UIBarButtonItem*)sender
{
    
    [PSAssetsLibraryInstance ps_SaveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation([UIImage imageNamed:@"qzl"]) customAlbumName:@"PSAssetsLibrary" completionBlock:^{
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        
    } failureBlock:^(NSString * _Nonnull error) {
        
        //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下

        if ([error rangeOfString:@"User denied access"].location != NSNotFound || [error rangeOfString:@"用户拒绝访问"].location != NSNotFound)
        {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
            
            [alert show];
        }
        else
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
