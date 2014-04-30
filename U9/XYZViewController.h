//
//  XYZViewController.h
//  U9
//
//  Created by Alexander Jägbeck on 2014-04-26.
//  Copyright (c) 2014 Alexander Jägbeck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XYZViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, AVSpeechSynthesizerDelegate, UITextViewDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableArray *languages;
@property (strong, nonatomic) NSMutableDictionary *languageDictionary;

-(void)setSelectedLanguages:(NSMutableArray *)array;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@end
