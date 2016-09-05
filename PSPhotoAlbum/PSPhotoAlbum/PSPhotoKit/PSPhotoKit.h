//
//  PSPhotoKit.h
//  PSPhotoAlbum
//
//  Created by Ryan_Man on 16/8/25.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPhotoKit : NSObject

/**
 *  单列
 *
 *  @return
 */
+ (PSPhotoKit*)shareInstance;


- (void)ps_Add;



@end
