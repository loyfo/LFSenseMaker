//
//  LFWebServer.m
//  GCDServer
//
//  Created by 黄维平 on 2017/3/7.
//  Copyright © 2017年 UFotoSoft. All rights reserved.
//

#import "LFWebServer.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerFileResponse.h"
#import "GCDAsyncUdpSocket.h"

@interface LFWebServer ()<GCDAsyncUdpSocketDelegate>
{
    NSTimer *broadcastTimer;
}

@property (nonatomic,strong)GCDWebServer *webServer;

@property (nonatomic,strong)GCDAsyncUdpSocket *udpServer;

@end

@implementation LFWebServer

+(instancetype)shareServer {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

-(BOOL)startServer {
    return [self startBroadcastServer]&&[self startWebServer];
}

#pragma mark - webServer
-(BOOL)startWebServer {
    _webServer = [[GCDWebServer alloc]init];
    
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            GCDWebServerResponse* response;
            NSData *data;
            NSString* directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Scene.zip"];
            if ([[NSFileManager defaultManager]fileExistsAtPath:directoryPath]) {
                //            [[NSFileManager defaultManager]createFileAtPath:@"~/1.zip" contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http"]] attributes:nil];
                data = [NSData dataWithContentsOfFile:directoryPath];
            }
            
            if (data) {
                response =  [GCDWebServerFileResponse responseWithFile:directoryPath isAttachment:YES];
            }else {
                response = [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>file not exit!</p></body></html>"];
                response.statusCode = 404;
            }
            
            completionBlock(response);
            
        });
        
    }];
    
    return [_webServer startWithPort:10086 bonjourName:@"sceneServer"];
}


#pragma mark - brodcastServer

-(BOOL)startBroadcastServer {
    self.udpServer = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    int port = 3339;
    NSError *error = nil;
    
    if (![self.udpServer bindToPort:port error:&error]) {
        NSLog(@"Error starting server (bind): %@", error);
        return NO;
    }
    
    if (![self.udpServer enableBroadcast:YES error:&error]) {
        NSLog(@"Error enableBroadcast (bind): %@", error);
        return NO;
    }
    if (![self.udpServer joinMulticastGroup:@"224.0.0.1"  error:&error]) {
        NSLog(@"Error joinMulticastGroup (bind): %@", error);
        return NO;
    }
    
    if (![self.udpServer beginReceiving:&error]) {
        [self.udpServer close];
        NSLog(@"Error starting server (recv): %@", error);
        return NO;
    }
    NSLog(@"udp servers success starting %hd", [self.udpServer localPort]);
    
    //    isRunning =true;
    __weak  LFWebServer*  weakself = self;
    broadcastTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!_clientConnected ) {
             [weakself sendBroadcast];
        }
    }];
    
    return YES;
}

- (void)sendBroadcast{
    
    NSString *s = self.webServer.serverURL.host;
    
    [self.udpServer sendData:[s dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:23333 withTimeout:-1 tag:0];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    NSString *reveiveMsg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@:%d",reveiveMsg,[sock connectedPort]);
    if ([reveiveMsg isEqualToString:@"accept"]) {
        _clientConnected = YES;
         [self.delegate clientConnectedToServer];
    
    }else if ([reveiveMsg isEqualToString:@"willCloseConnect"]) {
        _clientConnected = NO;
    }
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    
}




@end
