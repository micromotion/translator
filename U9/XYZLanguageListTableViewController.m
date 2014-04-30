//
//  XYZLanguageListTableViewController.m
//  U9
//
//  Created by Alexander Jägbeck on 2014-04-27.
//  Copyright (c) 2014 Alexander Jägbeck. All rights reserved.
//

#import "XYZLanguageListTableViewController.h"
#import "XYZViewController.h"
#import "XYZLanguage.h"

@interface XYZLanguageListTableViewController ()
@property NSMutableArray *languages;
@property (strong, nonatomic) NSMutableArray *indexPaths;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@end

// User can not select more than 2 rows
int selectedRows = 0;

@implementation XYZLanguageListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Some initial setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
        
    XYZViewController *controler = [[XYZViewController alloc] init];
    self.indexPaths = [[NSMutableArray alloc] init];
    
    self.languages = [[NSMutableArray alloc] init];

    // Create new instance of a language class for every language
    for(NSString *language in controler.languages) {
    
        XYZLanguage *instance = [[XYZLanguage alloc] init];
        instance.name = language;
        instance.code = [controler.languageDictionary valueForKey:language];
         [self.languages addObject:instance];
        
    }
}

-(void)viewWillAppear:(BOOL)animated {
    selectedRows = 0;
    [self.doneButton setEnabled:NO];
}

// When the user presses 'done' button, sends the selected languages to view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (sender != self.doneButton)  {
        return;
    }
   
    if ([self.indexPaths count] > 1) {
        
    
        NSMutableArray *userChoises = [[NSMutableArray alloc] init];
   
        // Get language object corresponding to the rows selected
        for(NSNumber *path in self.indexPaths) {
            [userChoises addObject:[self.languages objectAtIndex:[path integerValue]]];
        }
    
        // Send the selected language objects to view controller
        XYZViewController *vc = [segue destinationViewController];
        [vc setSelectedLanguages:userChoises];
    }
}

#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.languages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"languageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    XYZLanguage *language = [self.languages objectAtIndex:indexPath.row];
    cell.textLabel.text = language.name;
    cell.imageView.image = [UIImage imageNamed:language.code];
    return cell;
}

#pragma mark -
#pragma === Table view delegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRows++;
    
    [self.indexPaths addObject:[NSNumber numberWithInteger:indexPath.row]];
    
    if (selectedRows == 2) {
        [self.doneButton setEnabled: YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRows--;
        
    [self.indexPaths removeObject:[NSNumber numberWithInteger:indexPath.row]];
    
    [self.doneButton setEnabled:NO];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (selectedRows == 2) return nil;
        
    return indexPath;
}

@end
