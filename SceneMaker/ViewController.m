//
//  ViewController.m
//  SceneMaker
//
//  Created by ufoto on 2016/11/30.
//  Copyright © 2016年 ufoto. All rights reserved.
//

#import "ViewController.h"
#import "LFWebServer.h"
#import "SSZipArchive.h"

static NSString *configVersion = @"1.0";

@interface ViewController () <NSTextViewDelegate,LFWebServerDelegate>
{
    BOOL pointTracker;
    BOOL fullScreenSticker;
    BOOL preferMouthOpen;
    NSInteger anchorPointNum;
}

@property (nonatomic, strong) NSMutableDictionary* groupDictionary;
@property (nonatomic, strong) NSMutableArray* elementsList;

//new
@property (weak) IBOutlet NSTextField *beautyLevelField;
@property (weak) IBOutlet NSTextField *slimIntensityField;
@property (weak) IBOutlet NSTextField *filtersField;

@property (nonatomic, weak) IBOutlet NSTextField* nameField;
@property (nonatomic, weak) IBOutlet NSTextField* widthField;
@property (nonatomic, weak) IBOutlet NSTextField* heightField;

@property (weak) IBOutlet NSPopUpButton *benchmarksTypeBtn;
@property (weak) IBOutlet NSTextField *anchorPointNumTF;
@property (weak) IBOutlet NSTextField *offsetTF;

@property (nonatomic, strong) IBOutlet NSTextView* pathTextView;
@property (nonatomic, weak) IBOutlet NSImageView* imageView;
@property (weak) IBOutlet NSTextField *imgCountField;
@property (weak) IBOutlet NSButton *animateImgButton;
@property (weak) IBOutlet NSTextField *animationDuritionField;
@property (weak) IBOutlet NSTextField *needFaceCountTF;

//素材需求
@property (weak) IBOutlet NSButton *dpMouthOpenBtn;
@property (weak) IBOutlet NSButton *dpLandscapeBtn;
@property (weak) IBOutlet NSButton *dpFrontCamBtn;
@property (weak) IBOutlet NSButton *dpBackCamBtn;
@property (weak) IBOutlet NSButton *dpSecondFaceBtn;
@property (weak) IBOutlet NSButton *dpThirdFaceBtn;
@property (weak) IBOutlet NSButton *dpPortraitBtn;

//用户提示
@property (weak) IBOutlet NSButton *preFrontCamBtn;
@property (weak) IBOutlet NSButton *preBackCamBtn;
@property (weak) IBOutlet NSButton *preLandscapeBtn;
@property (weak) IBOutlet NSButton *preMouthOpenBtn;
@property (weak) IBOutlet NSButton *preMoreFaceBtn;
@property (weak) IBOutlet NSButton *prePortraitBtn;

//webserver
@property (weak) IBOutlet NSTextField *serverConnectLbl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reInitScene];
    [self reInitElement];

    [LFWebServer shareServer].delegate = self;
    [[LFWebServer shareServer]startServer];
    // Do any additional setup after loading the view.
}

-(void)reInitScene {
    self.groupDictionary = nil;
    
    [self.animateImgButton  setNextState];
    self.filtersField.stringValue = @"";
    self.preFrontCamBtn.state = 0;
    self.preBackCamBtn.state = 0;
    self.preLandscapeBtn.state = 0;
    self.preMouthOpenBtn.state = 0;
    self.prePortraitBtn.state = 0;
    
    self.imgCountField.enabled = NO;
    self.animationDuritionField.enabled = NO;
    self.needFaceCountTF.intValue = 0;
    
    self.beautyLevelField.stringValue = @"0.65";
    self.slimIntensityField.stringValue = @"1.0";
    
}

-(void)reInitElement {
    _pathTextView.string = @"";
    _needFaceCountTF.stringValue = @"";
    _nameField.stringValue = @"";
    _widthField.stringValue = @"";
    _heightField.stringValue = @"";
    _anchorPointNumTF.stringValue = @"";
    _offsetTF.stringValue = @"0,0";
    
    anchorPointNum = -1;
    [self changeBenchMarksType:_benchmarksTypeBtn];
    _dpMouthOpenBtn.state = 0;
    _dpLandscapeBtn.state = 0;
    _dpFrontCamBtn.state = 0;
    _dpBackCamBtn.state = 0;
    _dpSecondFaceBtn.state = 0;
    _dpThirdFaceBtn.state = 0;
    _dpPortraitBtn.state = 0;
    
}

//切换对点方式
- (IBAction)changeBenchMarksType:(NSPopUpButton *)sender {
    _anchorPointNumTF.editable = NO;
    NSLog(@"切换对点方式:%ld",(long)sender.selectedTag);
    
    if (sender.selectedTag == 0) {
        return;
    }
    
     _needFaceCountTF.intValue = MAX(_needFaceCountTF.intValue, 1);
    
    switch (sender.selectedTag) {
        case 0:  //固定
            
            break;
        case 1:  //指定识别点
           
            _anchorPointNumTF.editable = YES;
            [_anchorPointNumTF becomeFirstResponder];
            break;
        case 2:  //鼻尖
        
            break;
        case 3:  //嘴部
           
            break;
        case 4:  //左上角
            
            break;
        default:
            break;
    }
}

//切换动态素材
- (IBAction)changeIfAnimateImg:(NSButton *)sender {
    self.imgCountField.enabled = !self.imgCountField.enabled;
    self.animationDuritionField.enabled = !self.animationDuritionField.enabled;
    if (self.imgCountField.enabled) {
        [self.imgCountField becomeFirstResponder];
    }else {
        self.imgCountField.stringValue = @"";
        self.animationDuritionField.stringValue = @"";
    }
}

- (NSString*)directoryPath
{
    NSString* directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Scene"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directoryPath;
}

- (IBAction)add:(id)sender
{
    //目标路径
    NSString* path = [[self directoryPath] stringByAppendingPathComponent:_nameField.stringValue];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    //源图路径
    NSString *pathText = _pathTextView.string;
    
    NSRange range = [pathText rangeOfString:[pathText lastPathComponent]];
    NSString *folderPath = [pathText substringToIndex:range.location];
    NSString *firstFileName = [pathText substringFromIndex:range.location];
    
    //原图文件名前缀
    NSString *scenePrefixString = [firstFileName substringToIndex:firstFileName.length - 5];
 
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@",_pathTextView.string] toPath:[path stringByAppendingPathComponent:@"0.png"] error:nil];

    if (self.imgCountField.integerValue > 1) {
        for (int i = 1 ; i < self.imgCountField.integerValue; i++) {
            NSString *sourceItemPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png",scenePrefixString,i]];
            [[NSFileManager defaultManager] copyItemAtPath:sourceItemPath toPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",i]] error:nil];
        }
    }

    //偏移量
    NSArray *offsetArray = [self.offsetTF.stringValue componentsSeparatedByString:@","];
    
    NSPoint offset = CGPointZero;
    
    if (_benchmarksTypeBtn.selectedTag) {
        if (offsetArray.count == 2) {
            offset = NSMakePoint([offsetArray[0] floatValue], [offsetArray[1] floatValue]);
        }else {
            NSError *error = [NSError errorWithDomain:@"无效的左上角偏移点值，请确保正确输入并使用“,”分隔！" code:1005 userInfo:nil];
            NSAlert  *topleftAlert = [NSAlert alertWithError:error];
            [topleftAlert runModal];
            return;
        }
    }
    
    if (_benchmarksTypeBtn.selectedTag == 1) {
        anchorPointNum = _anchorPointNumTF.intValue;
        if (anchorPointNum < 0 || anchorPointNum > 94) {
            NSError *error = [NSError errorWithDomain:@"识别点范围不正确（0 ~ 94）！" code:1006 userInfo:nil];
            NSAlert  *ncherPointNumAlert = [NSAlert alertWithError:error];
            [ncherPointNumAlert runModal];
            return;
        }
    }
    
    //动画相关
    NSString *faceCount = @"1";
    NSString *frameDuration = @"4";
    if (self.imgCountField.enabled) {
        if (self.imgCountField.stringValue.length) {
            faceCount = self.imgCountField.stringValue;
        }
        
        if (self.animationDuritionField.stringValue.length) {
            frameDuration = self.animationDuritionField.stringValue;
        }
        
    }
    
    //素材前置条件
    NSMutableArray *dependentConditionArray = [NSMutableArray array];
    if (self.dpMouthOpenBtn.state) {
        [dependentConditionArray addObject:@"MouthOpen"];
    }
    
    if (self.dpLandscapeBtn.state) {
        [dependentConditionArray addObject:@"Landscape"];
    }
    
    if (self.dpPortraitBtn.state) {
        [dependentConditionArray addObject:@"Portait"];
    }
    
    if (self.dpFrontCamBtn.state) {
        [dependentConditionArray addObject:@"FrontCam"];
    }
    
    if (self.dpBackCamBtn.state) {
        [dependentConditionArray addObject:@"BackCam"];
    }
    
    if (self.dpSecondFaceBtn.state) {
        [dependentConditionArray addObject:@"SecondFace"];
    }
    
    if (self.dpThirdFaceBtn.state) {
        [dependentConditionArray addObject:@"ThirdFace"];
    }
    
    NSMutableDictionary* element = [@{
                                      @"folderName": _nameField.stringValue,
                                      @"size": NSStringFromSize(NSMakeSize(_widthField.floatValue, _heightField.floatValue)),
                                      @"offset": NSStringFromPoint(offset),
                                      @"animateLoop": @(0),
                                      @"frameDuration": @([frameDuration integerValue]),
                                      @"frameCount": @([faceCount integerValue]),
                                     @"scale":@(1.0),
                                     @"BenchmarksType":@(_benchmarksTypeBtn.selectedTag),
                                    @"anchorPointNum":@(_anchorPointNumTF.integerValue),
                                    @"dependentCondition":dependentConditionArray
                                      } mutableCopy];

    [self.groupDictionary[@"elements"] addObject:element];
    
    
    [self reInitElement];
}

- (IBAction)create:(id)sender
{
    NSMutableArray *filtersMArray = [NSMutableArray array];
    
    [filtersMArray addObject:@{@"type":@(1),@"class":@"beauty",@"property":@{@"intensity":@(self.beautyLevelField.floatValue)}}];
    
    [filtersMArray addObject:@{@"type":@(10),@"class":@"GPUImageRuddyFilter",@"property":@{@"intensity_insta":@(1)}}];
    
    if ([_needFaceCountTF integerValue]>0) {
        [filtersMArray addObject:@{@"type":@(2),@"class":@"slim",@"property":@{@"intensity":@(self.slimIntensityField.floatValue)}}];
    }
    
    NSArray *filterTmpArray = [self.filtersField.stringValue componentsSeparatedByString:@","];
    for (NSString *filterName in filterTmpArray) {
        if (filterName.length) {
            [filtersMArray addObject:@{@"type":@(10),@"class":filterName,@"property":@{@"intensity_insta":@(1)}}];
        }
    }

    self.groupDictionary[@"configVersion"] = configVersion;
    self.groupDictionary[@"needFaceCount"] = @(_needFaceCountTF.integerValue);

    //用户交互提示
    NSMutableDictionary *userPromptDict = [NSMutableDictionary dictionary];
    userPromptDict[@"preferFrontCam"] = @(self.preFrontCamBtn.state);
    userPromptDict[@"preferBackCam"] = @(self.preBackCamBtn.state);
    userPromptDict[@"preferLandscape"] = @(self.preLandscapeBtn.state);
    userPromptDict[@"preferPortait"] = @(self.prePortraitBtn.state);
    userPromptDict[@"preferMoreFace"] = @(self.preMoreFaceBtn.state);
    userPromptDict[@"preferMouthOpen"] = @(self.preMouthOpenBtn.state);
 
    [self.groupDictionary setObject:filtersMArray forKey:@"filters"];
    [self.groupDictionary setObject:userPromptDict forKey:@"userPrompts"];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:self.groupDictionary options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [jsonString writeToFile:[[self directoryPath] stringByAppendingPathComponent:@"Layout"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
     NSString* directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Scene.zip"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:directoryPath error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL zipResult = [SSZipArchive createZipFileAtPath:directoryPath   withContentsOfDirectory:[self directoryPath]];
        if (zipResult) {
            [self refreshServerScene:nil];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                  self.serverConnectLbl.stringValue = @"Scene包生成失败";
            });
          
        }
        
    });
    
    
    [self reInitScene];
}

- (void)textDidChange:(NSNotification *)notification
{
    _imageView.image = [[NSImage alloc] initWithContentsOfFile:_pathTextView.string];
    if (self.widthField.stringValue.length == 0 || self.heightField.stringValue.length == 0) {
        self.widthField.stringValue = [NSString stringWithFormat:@"%.0f",_imageView.image.size.width];
        self.heightField.stringValue = [NSString stringWithFormat:@"%.0f",_imageView.image.size.height];
    }
}

-(NSMutableDictionary *)groupDictionary {
    if (_groupDictionary == nil) {
        _groupDictionary = [@{@"elements" : [@[] mutableCopy]} mutableCopy];
    }
    return _groupDictionary;
}

- (IBAction)refreshServerScene:(NSButton *)sender {
     self.serverConnectLbl.stringValue = @"等待客户端连接";
     [LFWebServer shareServer].clientConnected = NO;
}

-(void)clientConnectedToServer {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.serverConnectLbl.stringValue = @"客户端已连接";
    });
    
}

@end
