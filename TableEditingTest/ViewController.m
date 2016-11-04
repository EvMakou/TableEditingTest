//
//  ViewController.m
//  TableEditingTest
//
//  Created by supermacho on 13.10.16.
//  Copyright © 2016 supermacho. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "Group.h"
@interface ViewController () <UITableViewDataSource,UITableViewDelegate >

@property (weak, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* groupsArray;

@end

@implementation ViewController

- (void) loadView {
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UITableView* tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //tableView.editing = YES;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.groupsArray = [[NSMutableArray alloc]init ];
    for (int i = 0; i < ((arc4random() % 6) + 5); i++){// первая секция она же первая группа
        Group* group = [[Group alloc]init];
        group.name = [NSString stringWithFormat:@"Group #%d",i+1];
        NSMutableArray* array = [[NSMutableArray alloc]init];
        for (int j = 0; j < ((arc4random() % 11) + 15); j++) {//заполнение секции или группы студентами
            [array addObject:[Student randomStudent]];
        }
        group.students = array;
        [self.groupsArray addObject:group];
    }
    [self.tableView reloadData];
    self.navigationItem.title = @"Students";
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                               target:self
                                                                               action:@selector(actionEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(actionAddSection:)];
    self.navigationItem.leftBarButtonItem = addButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action

- (void) actionEdit:(UIBarButtonItem*) sender {
    BOOL isEditing = self.tableView.editing; //self.tableView.editing режим редактирования
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item
                                                                               target:self
                                                                               action:@selector(actionEdit:)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];

    
    
}


- (void) actionAddSection:(UIBarButtonItem*) sender {
    
    Group* group = [[Group alloc]init];
    group.name = [NSString stringWithFormat:@"Group #%ld",[self.groupsArray count] + 1];
    
    group.students = @[[Student randomStudent], [Student randomStudent]];
    
    NSInteger newSectionIndex = 0;
    
    [self.groupsArray insertObject:group atIndex:newSectionIndex];
    
    [self.tableView beginUpdates];
    
    NSIndexSet* insertSection = [NSIndexSet indexSetWithIndex:newSectionIndex];
                 
    [self.tableView insertSections:insertSection
                  withRowAnimation:[self.groupsArray count] % 2 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight ];
    
    [self.tableView endUpdates];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        
    });
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupsArray count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[self.groupsArray objectAtIndex:section]name];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Group* group = [self.groupsArray objectAtIndex:section];
    
    
    return [group.students count] + 1;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        static NSString* addStudentidentifier = @"addStudentCell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:addStudentidentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addStudentidentifier];
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"Add Student";
        }
        
        return cell;
        
    } else {
        
        static NSString* studentIdentifier = @"studentCell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:studentIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:studentIdentifier];
        }
        
        Group* group = [self.groupsArray objectAtIndex:indexPath.section];//группа соотвествует секции
        Student* student = [group.students objectAtIndex:indexPath.row - 1];//студент соответстует ряду
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",student.firstName, student.lastName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f",student.averageGrade];
        
        if (student.averageGrade >= 4) {
            cell.detailTextLabel.textColor = [UIColor greenColor];
        } else if (student.averageGrade >= 3) {
            cell.detailTextLabel.textColor = [UIColor orangeColor];//detailTextLabel text UITableViewCellStyleValue1
        } else {
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        
        
        
        return cell;
    }
    
    
    
    
   
    
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    if (proposedDestinationIndexPath.row == 0) {
        return sourceIndexPath;
    } else {
        return proposedDestinationIndexPath;
    }
    
}




- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        Group* group = [self.groupsArray objectAtIndex:indexPath.section];
        
        NSMutableArray* tempArray = nil;
        
        if (group.students) {
            tempArray = [NSMutableArray arrayWithArray:group.students];
        } else {
            tempArray = [NSMutableArray array];
        }
        
        NSInteger newStudentIndex = 0;
        
        [tempArray insertObject:[Student randomStudent] atIndex:newStudentIndex];
        group.students = tempArray; 
        
        
        
        [self.tableView beginUpdates];
        
        //NSIndexSet* insertSection = [NSIndexSet indexSetWithIndex:newSectionIndex];
        
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:newStudentIndex + 1 inSection:indexPath.section];
        
        
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
       
        
        [self.tableView endUpdates];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
            }
            
        });

        
        
    }
    
}



//- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

//}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {//МЕТОД ВЫЗ ОВИТСЯ ТОЛЬКО ЕСЛИ ПЕРЕМЕЩАЕМ РЯД,IndexPath путь индекса,ряд по IndexPath хочет перейти в другой IndexPath перемещаются ui,но не массив 43:01
    Group* sourceGroup = [self.groupsArray objectAtIndex:sourceIndexPath.section];
    Student* student = [sourceGroup.students objectAtIndex:sourceIndexPath.row - 1];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:sourceGroup.students];
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        [tempArray exchangeObjectAtIndex:sourceIndexPath.row - 1 withObjectAtIndex:destinationIndexPath.row - 1];
        sourceGroup.students = tempArray;
    } else {
        [tempArray removeObject:student];
        sourceGroup.students = tempArray;
        
        Group* destionationGroup = [self.groupsArray objectAtIndex:destinationIndexPath.section];
        tempArray = [NSMutableArray arrayWithArray:destionationGroup.students];
        [tempArray insertObject:student atIndex:destinationIndexPath.row - 1 ];//вставить объект srudent в другой ряд
        destionationGroup.students = tempArray;
    }
    
    
    
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Group* sourceGroup = [self.groupsArray objectAtIndex:indexPath.section];
        Student* student = [sourceGroup.students objectAtIndex:indexPath.row - 1];
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:sourceGroup.students];
        [tempArray removeObject:student];
        sourceGroup.students = tempArray;
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
        
    }
}


@end
