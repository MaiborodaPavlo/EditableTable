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
    
    // Navigation
    
    self.navigationItem.title = @"Employees";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                                                target: self
                                                                                action: @selector(actionEdit:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                               target: self
                                                                               action: @selector(actionAddSection:)];
    
    self.navigationItem.leftBarButtonItem = addButton;
    
}

#pragma mark - Actions

- (void) actionSectionButton: (UIButton *) sender {
    
    NSInteger section = sender.tag;
    
    PMCompany *company = [self.companiesArray objectAtIndex: section];
    
    NSMutableArray *tempArray = nil;
    
    if (company.employees) {
        tempArray = [NSMutableArray arrayWithArray: company.employees];
    } else {
        tempArray = [NSMutableArray array];
    }
    
    NSInteger newEmployeeIndex = 0;
    
    [tempArray insertObject: [PMEmployee randomEmployee] atIndex: newEmployeeIndex];
    company.employees = tempArray;
    
    // Обновление секции
    [self.tableView beginUpdates];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow: newEmployeeIndex inSection: section];
    
    [self.tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation: UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
    
}

- (void) actionAddSection: (UIBarButtonItem *) sender {
 
    PMCompany *company = [[PMCompany alloc] init];
    company.name = [NSString stringWithFormat: @"Company #%li", [self.companiesArray count] + 1];
    
    company.employees = @[[PMEmployee randomEmployee], [PMEmployee randomEmployee]];
    
    NSInteger newSectionIndex = 0;
    
    [self.companiesArray insertObject: company atIndex: newSectionIndex];
    
    // анимированное обновление данных в таблице
    [self.tableView beginUpdates];
    
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    
    if ([self.companiesArray count] > 1) {
        animation = [self.companiesArray count] % 2 ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
    }
    
    NSIndexSet *insertSection = [NSIndexSet indexSetWithIndex: newSectionIndex];
    [self.tableView insertSections: insertSection withRowAnimation: animation];
    
    [self.tableView endUpdates];
    
    // запрещаем пользователю кликать много раз подряд
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
    
}

- (void) actionEdit: (UIBarButtonItem *) sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing: !isEditing animated: YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: item
                                                                                target: self
                                                                                action: @selector(actionEdit:)];
    
    [self.navigationItem setRightBarButtonItem: editButton animated: YES];
    
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    PMCompany *sourceCompany = [self.companiesArray objectAtIndex: sourceIndexPath.section];
    PMEmployee *employee = [sourceCompany.employees objectAtIndex: sourceIndexPath.row];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray: sourceCompany.employees];
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        
        [tempArray exchangeObjectAtIndex: sourceIndexPath.row withObjectAtIndex: destinationIndexPath.row];
        sourceCompany.employees = tempArray;
        
    } else {
        
        [tempArray removeObject: employee];
        sourceCompany.employees = tempArray;
        
        PMCompany *destinationCompany= [self.companiesArray objectAtIndex: destinationIndexPath.section];
        tempArray = [NSMutableArray arrayWithArray: destinationCompany.employees];
        [tempArray insertObject: employee atIndex: destinationIndexPath.row];
        destinationCompany.employees = tempArray;
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PMCompany *company = [self.companiesArray objectAtIndex: indexPath.section];
        PMEmployee *employee = [company.employees objectAtIndex: indexPath.row];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray: company.employees];
        [tempArray removeObject: employee];
        company.employees = tempArray;
        
        // Обновление таблицы
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationRight];
        
        if ([company.employees isEqualToArray: @[]]) {
            [self.companiesArray removeObject: company];
            [self.tableView deleteSections: [NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation: UITableViewRowAnimationFade];
        }
        
        
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(tableView.bounds))];
    
    view.layoutMargins = UIEdgeInsetsMake(30, 10, 5, 10);
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 200, 50)];
    label.textColor = [UIColor grayColor];
    label.text = [[self.companiesArray objectAtIndex: section] name];
    label.layoutMargins = UIEdgeInsetsMake(30, 10, 5, 10);
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.tag = section;
    [addButton addTarget:self action:@selector(actionSectionButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview: label];
    [view addSubview: addButton];
    
    return view;
    
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Remove old button from re-used header
    if ([view.subviews.lastObject isKindOfClass: [UIButton class]])
        [view.subviews.lastObject removeFromSuperview];
    
    
        UIButton *addButton = [UIButton buttonWithType: UIButtonTypeContactAdd];
        addButton.tag = section;
        [addButton addTarget:self action:@selector(actionSectionButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:addButton];
    
        // Place button on far right margin of header
        addButton.translatesAutoresizingMaskIntoConstraints = NO; // use autolayout constraints instead
        [addButton.trailingAnchor constraintEqualToAnchor: view.layoutMarginsGuide.trailingAnchor].active = YES;
        [addButton.bottomAnchor constraintEqualToAnchor: view.layoutMarginsGuide.bottomAnchor].active = YES;
    
}

@end
