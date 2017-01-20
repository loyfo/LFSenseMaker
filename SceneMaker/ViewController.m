//
//  ViewController.m
//  SceneMaker
//
//  Created by ufoto on 2016/11/30.
//  Copyright © 2016年 ufoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextViewDelegate>
{
    BOOL pointTracker;
    BOOL fullScreenSticker;
}

@property (nonatomic, strong) IBOutlet NSTextView* pathTextView;
@property (nonatomic, weak) IBOutlet NSImageView* imageView;
@property (weak) IBOutlet NSTextField *imgCountField;
@property (weak) IBOutlet NSButton *animateImgButton;
@property (weak) IBOutlet NSTextField *animationDuritionField;
@property (weak) IBOutlet NSButton *pointTrakButton;
@property (weak) IBOutlet NSTextField *faceWidthField;
@property (weak) IBOutlet NSTextField *toFaceScaleField;
@property (weak) IBOutlet NSTextField *beautyLevelField;
@property (weak) IBOutlet NSTextField *ancherpointField;

@property (nonatomic, weak) IBOutlet NSTextField* nameField;
@property (nonatomic, weak) IBOutlet NSTextField* widthField;
@property (nonatomic, weak) IBOutlet NSTextField* heightField;
@property (nonatomic, weak) IBOutlet NSTextField* centerField;
@property (nonatomic, weak) IBOutlet NSTextField* offsetXField;
@property (nonatomic, weak) IBOutlet NSTextField* offsetYField;

@property (nonatomic, weak) IBOutlet NSTextField* preferWField;
@property (nonatomic, weak) IBOutlet NSTextField* wpointField;

@property (nonatomic, strong) NSMutableDictionary* groupDictionary;
@property (nonatomic, strong) NSMutableArray* elementsList;
@property (weak) IBOutlet NSTextField *topLeftOffsetField;

@property (weak) IBOutlet NSButton *fullscreenStickerBtn;

@property (weak) IBOutlet NSButton *needFaceButton;
@property (weak) IBOutlet NSButton *preferFrontCamBtn;
@property (weak) IBOutlet NSButton *preferBackCamBtn;

@property (weak) IBOutlet NSTextField *slimIntensityField;
@property (weak) IBOutlet NSTextField *filtersField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.animateImgButton  setNextState];
    [self.fullscreenStickerBtn setNextState];
    
    [self reInit];
    
    
    // Do any additional setup after loading the view.
}

-(void)reInit {
    self.groupDictionary = nil;
    
    
    self.filtersField.stringValue = @"";
    self.needFaceButton.state = 1;
    self.preferFrontCamBtn.state = 0;
    self.preferBackCamBtn.state = 0;
    
    self.imgCountField.enabled = NO;
    self.topLeftOffsetField.enabled = NO;
    self.animationDuritionField.enabled = NO;
    pointTracker = YES;
    
    self.faceWidthField.stringValue = @"450";
    self.toFaceScaleField.stringValue = @"1";
    self.beautyLevelField.stringValue = @"0.65";
    self.slimIntensityField.stringValue = @"1.0";
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

- (IBAction)pointTrackClick:(id)sender {
    pointTracker = !pointTracker;
    self.topLeftOffsetField.enabled = !pointTracker;
    self.ancherpointField.enabled = pointTracker;
}
- (IBAction)fullScreenClick:(id)sender {
    fullScreenSticker = !fullScreenSticker;
    if (fullScreenSticker) {
        self.faceWidthField.floatValue = 0;
    }
}



- (IBAction)add:(id)sender
{
    //目标路径
    NSString* path = [[self directoryPath] stringByAppendingPathComponent:_nameField.stringValue];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    //源图路径
    NSString *pathText = _pathTextView.string;
    
    NSRange range = [pathText rangeOfString:[pathText lastPathComponent]];
    NSString *floderPath = [pathText substringToIndex:range.location];
    NSString *firstFileName = [pathText substringFromIndex:range.location];
    
    //原图文件名前缀
    NSString *scenePrefixString = [firstFileName substringToIndex:firstFileName.length - 5];
 
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@",_pathTextView.string] toPath:[path stringByAppendingPathComponent:@"0.png"] error:nil];

    if (self.imgCountField.integerValue > 1) {
        for (int i = 1 ; i < self.imgCountField.integerValue; i++) {
            NSString *sourceItemPath = [floderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png",scenePrefixString,i]];
            [[NSFileManager defaultManager] copyItemAtPath:sourceItemPath toPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",i]] error:nil];
        }
    }

    //左上方偏移(普通对点方式)
    NSArray *topleftOffsetArray = [self.topLeftOffsetField.stringValue componentsSeparatedByString:@","];
    
    NSPoint topleftOffset = CGPointZero;
    
    if (!pointTracker) {
        if (topleftOffsetArray.count == 2) {
            topleftOffset = NSMakePoint([topleftOffsetArray[0] floatValue], [topleftOffsetArray[1] floatValue]);
        }else {
            NSError *error = [NSError errorWithDomain:@"无效的左上角偏移点值，请确保正确输入并使用“,”分隔！" code:1005 userInfo:nil];
            NSAlert  *topleftAlert = [NSAlert alertWithError:error];
            [topleftAlert runModal];
            return;
        }
    }
    
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
    
    NSInteger pointTrack = pointTracker;
    
    //特殊点偏移
    NSArray *ancherpointArray = [self.ancherpointField.stringValue componentsSeparatedByString:@","];
    NSPoint ancherpoint = NSMakePoint(self.widthField.floatValue / 2.0, self.heightField.floatValue / 2.0);

    if (pointTracker) {
        if (ancherpointArray.count == 2) {
            ancherpoint = NSMakePoint(ancherpoint.x + [ancherpointArray[0] floatValue],ancherpoint.y + [ancherpointArray[1] floatValue]);
        }
        
   
    }
    
    
    NSMutableDictionary* element = [@{
                                      @"folderName": _nameField.stringValue,
                                      @"centerPoints":@[NSStringFromPoint(NSMakePoint(0, 0))],
                                      @"size": NSStringFromSize(NSMakeSize(_widthField.floatValue, _heightField.floatValue)),
                                      @"offset": NSStringFromSize(NSMakeSize(0, 0)),
                                      @"alignScreen": @"",
                                      @"offsetScreenX": @(0),
                                      @"offsetScreenY": @(0),
                                      @"animateLoop": @(1),
                                      @"frameDuration": @([frameDuration integerValue]),
                                      @"frameCount": @([faceCount integerValue]),
                                      @"topleft":NSStringFromPoint(topleftOffset),
                                      @"pointTrack":@(pointTrack),
                                      @"ancherpoint":NSStringFromPoint(ancherpoint)
                                      } mutableCopy];
    
    if (fullScreenSticker) {
        [element removeObjectForKey:@"centerPoints"];
    }
    
    
    if (_preferWField.floatValue > 0) {
        element[@"preferWidth"] = @(_preferWField.floatValue);
        element[@"edgePoints"] = [_wpointField.stringValue componentsSeparatedByString:@"&"];
    }
    
    [self.groupDictionary[@"elements"] addObject:element];
    
    
    _pathTextView.string = @"";
    
    _nameField.stringValue = @"";
    _widthField.stringValue = @"";
    _heightField.stringValue = @"";
    _centerField.stringValue = @"";
    _offsetXField.stringValue = @"";
    _offsetYField.stringValue = @"";
    self.ancherpointField.stringValue = @"";
    
    _preferWField.stringValue = @"";
    _wpointField.stringValue = @"";
    _topLeftOffsetField.stringValue = @"";
}

- (IBAction)create:(id)sender
{
    if ( self.faceWidthField.stringValue.length == 0) {
        ;
    }
    NSMutableArray *filter = [@[@{@"type":@(1),@"class":@"beauty",@"property":@{@"intensity":@(self.beautyLevelField.floatValue)}},@{@"type":@(2),@"class":@"slim",@"property":@{@"intensity":@(self.slimIntensityField.floatValue)}},@{@"type":@(10),@"class":@"GPUImageRuddyFilter",@"property":@{@"intensity_insta":@(1)}}] mutableCopy];
    NSArray *filterTmpArray = [self.filtersField.stringValue componentsSeparatedByString:@","];
    for (NSString *filterName in filterTmpArray) {
        [filter addObject:@{@"type":@(10),@"class":filterName,@"property":@{@"intensity_insta":@(1)}}];
    }

    
    self.groupDictionary[@"baseFaceWidth"] = @(450);
    self.groupDictionary[@"scaleToFace"] =@(1);
    
    if (fullScreenSticker) {
        self.groupDictionary[@"baseFaceWidth"] = @(0);
        self.groupDictionary[@"scaleToFace"] = @(1);
    }
    
    //用户交互提示
    NSMutableDictionary *userPromptDict = [NSMutableDictionary dictionary];
    
    userPromptDict[@"preferFontCam"] = @(self.preferFrontCamBtn.state);
    userPromptDict[@"preferBackCam"] = @(self.preferBackCamBtn.state);
    userPromptDict[@"needFace"] = [self.groupDictionary[@"baseFaceWidth"] integerValue] == 0?@(0):@(1);
    
    [self.groupDictionary setObject:filter forKey:@"filters"];
    [self.groupDictionary setObject:userPromptDict forKey:@"userPrompts"];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:self.groupDictionary options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [jsonString writeToFile:[[self directoryPath] stringByAppendingPathComponent:@"Layout"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self reInit];
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
        _groupDictionary = [@{
                              @"scaleToScreen": @(1),
                              @"elements" : [@[] mutableCopy]
                              } mutableCopy];
    }
    return _groupDictionary;
}


@end
