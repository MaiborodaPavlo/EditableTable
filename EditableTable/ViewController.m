//
//  ViewController.m
//  EditableTable
//
//  Created by Pavel on 22.01.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "ViewController.h"
#import "PMEmployee.h"
#import "PMCompany.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *companiesArray;

@end

@implementation ViewController

- (void) loadView {
    [super loadView];
    
    // TableView initialization
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame: frame style: UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview: tableView];
    
    self.tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.companiesArray = [NSMutableArray array];
    
    for (int i = 0; i < arc4random() % 6 + 5; i++) {
        
        PMCompany *company = [[PMCompany alloc] init];
        company.name = [NSString stringWithFormat: @"Company #%i", i];
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (int j = 0; j < arc4random() % 11 + 15; j++) {
            [array addObject: [PMEmployee randomEmployee]];
        }
        
        company.employees = array;
        
        [self.companiesArray addObject: company];
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.companiesArray count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[self.companiesArray objectAtIndex: section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    PMCompany *company = [self.companiesArray objectAtIndex: section];
    
    return [company.employees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: identifier];
    }
    
    PMCompany *company = [self.companiesArray objectAtIndex: indexPath.section];
    PMEmployee *employee = [company.employees objectAtIndex: indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", employee.firstName, employee.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%1.2f", employee.experience];
    
    if (employee.experience >= 5.0) {
        cell.detailTextLabel.textColor = [UIColor greenColor];
    } else if (employee.experience >= 2.0) {
        cell.detailTextLabel.textColor = [UIColor orangeColor];
    } else {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
    
}

@end
