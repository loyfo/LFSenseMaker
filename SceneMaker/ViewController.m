//
//  ViewController.m
//  SceneMaker
//
//  Created by ufoto on 2016/11/30.
//  Copyright © 2016年 ufoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextViewDelegate>

@property (nonatomic, strong) IBOutlet NSTextView* pathTextView;
@property (nonatomic, weak) IBOutlet NSImageView* imageView;

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *filter = @[@{@"type":@(1),@"class":@"beauty",@"property":@{@"intensity":@(0.65)}},@{@"type":@(10),@"class":@"GPUImageRuddyFilter",@"property":@{@"intensity_insta":@(0.65)}}];
    
    _groupDictionary = [@{
                          @"baseFaceWidth": @(450),
                          @"scaleToFace": @(1),
                          @"scaleToScreen": @(1),
                          @"filters":filter,
                          @"elements" : [@[] mutableCopy]
                          } mutableCopy];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
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
    NSArray *array = [self.topLeftOffsetField.stringValue componentsSeparatedByString:@","];
    
    NSPoint topleftOffset = CGPointZero;
    if (array.count == 2) {
        topleftOffset = NSMakePoint([array[0] floatValue], [array[1] floatValue]);
    }else {
        NSError *error = [NSError errorWithDomain:@"无效的左上角偏移点值，请确保正确输入并使用“,”分隔！" code:1005 userInfo:nil];
        NSAlert  *topleftAlert = [NSAlert alertWithError:error];
        [topleftAlert runModal];
        return;
    }
    
    NSString* path = [[self directoryPath] stringByAppendingPathComponent:_nameField.stringValue];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    [[NSFileManager defaultManager] copyItemAtPath:_pathTextView.string toPath:[path stringByAppendingPathComponent:@"0.png"] error:nil];
    
    
    NSMutableDictionary* element = [@{
                              @"folderName": _nameField.stringValue,
                              @"centerPoints": [_centerField.stringValue componentsSeparatedByString:@"&"],
                              @"size": NSStringFromSize(NSMakeSize(_widthField.floatValue, _heightField.floatValue)),
                              @"offset": NSStringFromSize(NSMakeSize(_offsetXField.floatValue, _offsetYField.floatValue)),
                              @"alignScreen": @"",
                              @"offsetScreenX": @(0),
                              @"offsetScreenY": @(0),
                              @"animateLoop": @(1),
                              @"frameDuration": @(40),
                              @"frameCount": @(1),
                              @"topleft":NSStringFromPoint(topleftOffset)
    } mutableCopy];
    
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
    
    _preferWField.stringValue = @"";
    _wpointField.stringValue = @"";
    _topLeftOffsetField.stringValue = @"";
}

- (IBAction)create:(id)sender
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:self.groupDictionary options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [jsonString writeToFile:[[self directoryPath] stringByAppendingPathComponent:@"Layout"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    _imageView.image = [[NSImage alloc] initWithContentsOfFile:_pathTextView.string];
}


@end
