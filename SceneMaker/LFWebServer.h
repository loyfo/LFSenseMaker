//
//  LFWebServer.h
//  GCDServer
//
//  Created by 黄维平 on 2017/3/7.
//  Copyright © 2017年 UFotoSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LFWebServerDelegate

-(void)clientConnectedToServer;

@end

@interface LFWebServer : NSObject

@property (nonatomic,assign)BOOL  clientConnected;

@property (nonatomic,weak)id<LFWebServerDelegate>  delegate;

+(instancetype)shareServer;

-(BOOL)startServer;

@end
