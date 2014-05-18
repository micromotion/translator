//
//  XYZViewController.m
//  U9
//
//  Created by Alexander Jägbeck on 2014-04-26.
//  Copyright (c) 2014 Alexander Jägbeck. All rights reserved.
//

#import "XYZViewController.h"
#import "XYZLanguageListTableViewController.h"
#import "XYZLanguage.h"

@interface XYZViewController ()

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pitchSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rateSegment;

@property (strong, nonatomic)  NSMutableArray *langsToTranslate;
@property (weak, nonatomic) IBOutlet UIImageView *toFlag;
@property (weak, nonatomic) IBOutlet UIImageView *fromFlag;

@end

NSMutableData *_responseData;

@implementation XYZViewController



#pragma mark -
#pragma mark - === ViewController loaded into memory ===
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Set a border around textView
    [self.textView.layer setBorderWidth:0.5];
    self.textView.layer.cornerRadius = 25;
    [self.textView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    // Set delegates
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.textView.delegate = self;
    
    // Get system language and region country (system lang and system region must be equal for som calcualtions)
    NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
    NSString *identifier = [currentLocale localeIdentifier];
    NSString *langName = [currentLocale displayNameForKey:NSLocaleIdentifier value:identifier];
    
    // Check wether user system language exist in array,if not then he's probably using another language than english
    int index = 0;
    for(NSString *language in self.languages) {
        
        if([language isEqualToString:langName]) {
            break;
        }
        index++;
    }
    
    // Can't resolve user language, set another default language
    if(index == 35){
        UIImage *firstFlag = [UIImage imageNamed:@"fr-FR"];
        [self.fromFlag setImage:firstFlag];
        [self.langsToTranslate addObject:@"fr-FR"];
    } else {
        // Set user system language to default 'from language'
        [self.langsToTranslate addObject:identifier];
    
        identifier = [identifier stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
        UIImage *firstFlag = [UIImage imageNamed:identifier];
        [self.fromFlag setImage:firstFlag];
    }
   
    // Set default 'to langauge'
    NSString *to = @"";
    if ([identifier rangeOfString:@"en"].location == NSNotFound) {
        to = @"en-GB";
    } else {
        to = @"sv-SE";
    }
    
    [self.langsToTranslate addObject:to];
    UIImage *secondFlag = [UIImage imageNamed:to];
    [self.toFlag setImage:secondFlag];
    
    [self setPickerRow];
    
}

#pragma mark -
#pragma mark === Accessors ===
#pragma mark -

- (AVSpeechSynthesizer *)synthesizer {
    
    if (!_synthesizer) {
       
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
   
    return _synthesizer;
}

- (NSMutableArray *)langsToTranslate {
   
    if (!_langsToTranslate) {
        _langsToTranslate = [[NSMutableArray alloc] init];
    }
    
    return _langsToTranslate;
}

- (NSMutableDictionary *)languageDictionary {
    
    if (!_languageDictionary) {
       
        _languageDictionary = [[NSMutableDictionary alloc] init];
        
        // get all voice code objects
        NSArray *voices = AVSpeechSynthesisVoice.speechVoices;
        NSArray *langs = [voices valueForKey:@"language"];
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        
        for (NSString *code in langs) {
            
            _languageDictionary[[currentLocale displayNameForKey:NSLocaleIdentifier value:code]] = code;
        }
    }
    
    return _languageDictionary;
}

- (NSMutableArray *)languages {
    
    if (!_languages) {
       
        _languages = [[NSMutableArray alloc] init];
        
        // get all voice code objects
        NSArray *voices = AVSpeechSynthesisVoice.speechVoices;
        NSArray *langs = [voices valueForKey:@"language"];
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        
        for (NSString *code in langs) {
            
            [_languages addObject:[currentLocale displayNameForKey:NSLocaleIdentifier value:code]];
        }
        // Sort array alphabetical
        [_languages sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    return _languages;
}

#pragma mark -
#pragma mark === IBAction event ===
#pragma mark -

// Speak utterance
- (IBAction)speak:(UIButton *)sender {
    
    if(self.textView.text && !self.synthesizer.isSpeaking) {
    
        NSInteger row = [self.picker selectedRowInComponent:0];
    
        // Get selected voice
        NSString *selectedVoice = [self.languages objectAtIndex:row];
        
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[self.languageDictionary valueForKey:selectedVoice]];
        
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.textView.text];
        utterance.voice = voice;
    
        // Get selected pitch
        NSInteger selectedPitchIndex = self.pitchSegment.selectedSegmentIndex;
        utterance.pitchMultiplier = [self selectedPitch:selectedPitchIndex];
    
        // Get selected rate
        NSInteger selectedRateIndex = self.rateSegment.selectedSegmentIndex;
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * [self selectedRate:selectedRateIndex];
    
        [self.synthesizer speakUtterance:utterance];
    }
}

// Returns the pitch to be used in utterance
- (float)selectedPitch:(NSInteger)atIndex {
    
    float pitch = 1.0;
    
    switch (atIndex) {
        case 0:
            pitch = 0.75;
            break;
        case 1:
            pitch = 1.0;
            break;
        case 2:
            pitch = 1.5;
            break;
        default:
            pitch = 1.0;
            break;
    }
    return pitch;
}

// Returns the rate to be used in utterance
- (float)selectedRate:(NSInteger)atIndex {
    
    float rate = 0.5;
    
    switch (atIndex) {
        case 0:
            rate = 0.25;
            break;
        case 1:
            rate = 0.5;
            break;
        case 2:
            rate = 1.0;
            break;
        default:
            rate = 0.5;
            break;
    }
    return rate;
}

// Sends request to server when translate button is pressed
- (IBAction)translateText:(UIBarButtonItem *)sender {
    
    NSString *textToTranslate = self.textView.text;
    NSString *from = [self.langsToTranslate objectAtIndex:0];
    NSLog(@"%@", from);
    NSString *to = [self.langsToTranslate objectAtIndex:1];
    NSLog(@"%@", to);
    
    // Need first to charachters in country code for translation
    from = [from substringToIndex:2];
    to = [to substringToIndex:2];
    
    //If the language is 'Chinese' i need to change the string a little bit for the translator
    if([from isEqualToString:@"zh"]) {
        from = @"zh-CHS";
    }
    
    if([to isEqualToString:@"zh"]) {
        to = @"zh-CHS";
    }
    
   NSString *unencodedString = [NSString stringWithFormat:@"http://alexanderjagbeck.se/home/translator/?text=%@&from=%@&to=%@", textToTranslate, from, to];
    NSLog(@"%@", unencodedString);
    
    
    NSString *encodedString = [unencodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", encodedString);
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// Does nothing but needs to be here for the segue to work
- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

// Called after user has choosen languages in the Tableview and segues
-(void)setSelectedLanguages:(NSMutableArray *)array {
    
    // Since the array is mutable, i must erase the same index twice
    [self.langsToTranslate removeObjectAtIndex:0];
    [self.langsToTranslate removeObjectAtIndex:0];
    
    // Add newly selected languages in array
    for(XYZLanguage *selected in array) {
        [self.langsToTranslate addObject:selected.code];
    }
    
    // Change the flags
    NSString *from = [self.langsToTranslate objectAtIndex:0];
    NSString *to = [self.langsToTranslate objectAtIndex:1];
    NSLog(@"from: %@", from);
    NSLog(@"To: %@", to);
    
    UIImage *firstFlag = [UIImage imageNamed:from];
    UIImage *secondFlag = [UIImage imageNamed:to];
    
    [self.fromFlag setImage:firstFlag];
    [self.toFlag setImage:secondFlag];
    
    [self setPickerRow];
}

-(void)setPickerRow {
    int index = 0;
    for (NSString *language in self.languages) {
    
        if ([[self.languageDictionary valueForKey:language] isEqualToString:[self.langsToTranslate objectAtIndex:1]]){
            [self.picker selectRow:index inComponent:0 animated:NO];
            break;
        }
        index++;
    }
}

#pragma mark -
#pragma mark === UIPickerViewDataSource ===
#pragma mark -

// Returns number of components/columns in picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// Returns number of rows in picker
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.languageDictionary.count;
}

#pragma mark -
#pragma mark === UIPickerViewDelegate ===
#pragma mark -

// Returns the title of each row in picker
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *languageName = self.languages[row];
    
    return languageName;
}

#pragma mark -
#pragma mark === AVSpeechSynthesizerDelegate ===
#pragma mark -

// Tells the delegate when the synthesizer is about to speak a portion of an utterance’s text
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    
    [text removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, [text length])];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:characterRange];
    self.textView.attributedText = text;
    [self.textView scrollRangeToVisible:characterRange];
}

// Tells the delegate when the synthesizer has finished speaking an utterance.
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [text removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, [text length])];
    self.textView.attributedText = text;
}

#pragma mark -
#pragma mark === UITextViewDelegate ===
#pragma mark -

// Asks the delegate whether the specified text should be replaced in the text view.
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //Closes keyboard on 'return'
    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];        
    }
    return YES;
}

#pragma mark -
#pragma mark === NSURL delegate methods ===
#pragma mark -

// Connection established with server
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

 // Append the new data to the instance variable
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
   
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

// Request is completed, print result
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *response = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", response);
    self.textView.text = response;
}

// The request has failed for some reason
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"Error: %@", error);
}

@end
