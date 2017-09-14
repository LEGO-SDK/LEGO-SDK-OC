//
//  LGOPicker.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/6.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPicker.h"
#import "LGOCore.h"

@interface LGOPickerRequest : LGORequest

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSString *> *columnTitles;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *columns;
@property (nonatomic, copy) NSArray<NSString *> *defaultValues;
@property (nonatomic, assign) BOOL isColumnsRelated; //标识是否是联动picker
@end

@implementation LGOPickerRequest

@end

@interface LGOPickerResponse : LGOResponse

@property (nonatomic, copy) NSArray<NSString *> *selectedValues;

@end

@implementation LGOPickerResponse

- (NSDictionary *)resData {
    if (self.selectedValues != nil) {
        return @{
                 @"selectedValues": self.selectedValues,
                 };
    }
    else {
        return @{};
    }
}

@end

@interface LGOPickerMockViewController : UIViewController

@end

@implementation LGOPickerMockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *targetViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([targetViewController isKindOfClass:[UITabBarController class]]) {
        targetViewController = [(UITabBarController *)targetViewController selectedViewController];
    }
    if ([targetViewController isKindOfClass:[UINavigationController class]]) {
        targetViewController = [(UINavigationController *)targetViewController visibleViewController];
    }
    return [targetViewController preferredStatusBarStyle];
}

@end

@interface LGOPickerOperation : LGORequestable<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) LGOPickerRequest *request;
@property (nonatomic, copy) LGORequestableAsynchronizeBlock responseBlock;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic,strong) NSMutableArray<NSString *> *currentSelectRows;  //当前选中行的值
@end

@implementation LGOPickerOperation

static UIWindow *optWindow;
static LGOPickerOperation *currentOperation;

- (void)showPickerView
{
    self.currentSelectRows = self.request.defaultValues.mutableCopy;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        optWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        optWindow.windowLevel = UIWindowLevelStatusBar + 1;
    });
    [optWindow setRootViewController:[LGOPickerMockViewController new]];
    [[optWindow subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [optWindow addSubview:self.maskView];
    [optWindow addSubview:self.contentView];
    optWindow.hidden = NO;
    self.maskView.alpha = 0.0;
    self.contentView.transform = CGAffineTransformMakeTranslation(0.0, 284);
    [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:24.0 options:kNilOptions animations:^{
        self.maskView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)onCancel {
    optWindow.hidden = YES;
    [[optWindow subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)onFinish {
    optWindow.hidden = YES;
    [[optWindow subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.responseBlock) {
        LGOPickerResponse *response = [LGOPickerResponse new];
        
        if (self.request.isColumnsRelated)
        {
            response.selectedValues = self.currentSelectRows;
        }
        else
        {
            NSMutableArray *selectedValues = [NSMutableArray array];
            for (NSInteger i = 0; i < self.request.columns.count; i++) {
                if ([self.pickerView selectedRowInComponent:i] < self.request.columns[i].count) {
                    [selectedValues addObject:self.request.columns[i][[self.pickerView selectedRowInComponent:i]]];
                }
            }
            response.selectedValues = selectedValues;

        }
        self.responseBlock([response accept:nil]);
    }
}

#pragma mark pickView dataSource & delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.request.isColumnsRelated)
    {
        return self.request.defaultValues.count;
    }
    
    return self.request.columns.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.request.isColumnsRelated)
    {
        id obj = [self targetWithColumn:component];
        
        if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray *targetArray = (NSArray *)obj;
            
            return targetArray.count;
        }
    }
    
    if (component < self.request.columns.count)
    {
        return self.request.columns[component].count;
    }
    return 0;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.request.isColumnsRelated)
    {
        id obj = [self targetWithColumn:component];
        
        if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray *targetArray = (NSArray *)obj;
            
            if (row < targetArray.count)
            {
                id target = targetArray[row];
                
                return [self titleOfObject:target];
            }
            
        }
        
        return @"";
    }
    
    
    if (component < self.request.columns.count) {
        if (row < self.request.columns[component].count) {
            return self.request.columns[component][row];
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.request.isColumnsRelated)
    {
        NSMutableArray *tempCurrentSelectRows = self.currentSelectRows.mutableCopy;
        for (NSInteger i = component; i < self.currentSelectRows.count; i++)
        {
            id target = [self targetWithColumn:i];
            
            if ([target isKindOfClass:[NSArray class]])
            {
                NSArray *targetArray = (NSArray *)target;

                if (i > component)
                {
                    id object = nil;
                    if (i > component) {
                        if ([tempCurrentSelectRows[i] isKindOfClass:[NSString class]]) {
                            for (int k = 0; k < targetArray.count; k++) {
                                if ([targetArray[k] isKindOfClass:[NSDictionary class]] && [targetArray[k][@"title"] isKindOfClass:[NSString class]]) {
                                    if ([((NSString *)targetArray[k][@"title"]) isEqualToString:self.currentSelectRows[i]]) {
                                        object = targetArray[k];
                                    }
                                }
                            }
                        }
                    }
                    if (object) {
                        self.currentSelectRows[i] = [self titleOfObject:object];
                    } else {
                        self.currentSelectRows[i] = [self titleOfObject:targetArray[0]];
                    }
                }
                else
                {
                    id object = nil;
                    if (i > component) {
                        if ([tempCurrentSelectRows[i] isKindOfClass:[NSString class]]) {
                            for (int k = 0; k < targetArray.count; k++) {
                                if ([targetArray[k] isKindOfClass:[NSDictionary class]]) {
                                    NSString *tempTitle = ((NSDictionary *) targetArray[k])[@"title"];
                                    if ([tempTitle isKindOfClass:[NSString class]] && [tempTitle isEqualToString:self.currentSelectRows[i]]) {
                                        object = targetArray[k];
                                        
                                    }
                                }
                            }
                        }
                    }
                    if (object) {
                        self.currentSelectRows[i] = [self titleOfObject:object];
                    } else {
                        self.currentSelectRows[i] = [self titleOfObject:targetArray[row]];
                    }
                }
            }
        }
        
        [self pickViewer:pickerView resetSelectedValue:self.currentSelectRows];
    }
    
}

#pragma mark OverWrite
- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    currentOperation = self;
    self.responseBlock = callbackBlock;
    [self showPickerView];
}

#pragma mark Getter
- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 284, [UIScreen mainScreen].bounds.size.width, 284)];
        _contentView.backgroundColor = [UIColor whiteColor];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(8, 0, 44, 44);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTintColor:[UIColor colorWithRed:0xaa / 255.0 green:0xb2 / 255.0 blue:0xdb / 255.0 alpha:1.0]];
        [cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
        UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeSystem];
        finishButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 8 - 44, 0, 44, 44);
        [finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [finishButton setTintColor:[UIColor colorWithRed:0x49 / 255.0 green:0xb4 / 255.0 blue:0xff / 255.0 alpha:1.0]];
        [finishButton addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0)];
        titleLabel.font = [UIFont systemFontOfSize:17.0];
        titleLabel.textColor = [UIColor colorWithRed:0x43 / 255.0 green:0x4a / 255.0 blue:0x54 / 255.0 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.request.title;
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addLineToPoint:CGPointMake(_contentView.frame.size.width, 0)];
        [shapeLayer setPath:bezierPath.CGPath];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.strokeColor = [UIColor colorWithRed:0xe7 / 255.0 green:0xe9 / 255.0 blue:0xee / 255.0 alpha:1.0].CGColor;
        shapeLayer.frame = CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 1);
        [_contentView addSubview:titleLabel];
        [_contentView addSubview:cancelButton];
        [_contentView addSubview:finishButton];
        [_contentView.layer addSublayer:shapeLayer];
        [_contentView addSubview:self.pickerView];
        [_contentView addSubview:[self headerTitleView]];
    }
    return _contentView;
}

- (UIView *)headerTitleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 30)];
    
    if (self.request.isColumnsRelated)
    {
        if (self.currentSelectRows.count == 0)
        {
            return titleView;
        }
        
        CGFloat eachWidth = [UIScreen mainScreen].bounds.size.width / self.currentSelectRows.count;
        for (NSInteger i = 0; i < self.currentSelectRows.count; i++)
        {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * eachWidth, 0, eachWidth, 30.0)];
            titleLabel.font = [UIFont systemFontOfSize:13.0];
            titleLabel.textColor = [UIColor colorWithRed:0x44 / 255.0 green:0x4a / 255.0 blue:0x53 / 255.0 alpha:1.0];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            if (i < self.request.columnTitles.count) {
                titleLabel.text = self.request.columnTitles[i];
            }
            [titleView addSubview:titleLabel];
        }
        return titleView;
    }
    
    
    
    
    if (self.request.columns.count == 0)
    {
        return titleView;
    }
    
    CGFloat eachWidth = [UIScreen mainScreen].bounds.size.width / self.request.columns.count;
    for (NSInteger i = 0; i < self.request.columns.count; i++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * eachWidth, 0, eachWidth, 30.0)];
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        titleLabel.textColor = [UIColor colorWithRed:0x44 / 255.0 green:0x4a / 255.0 blue:0x53 / 255.0 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        if (i < self.request.columnTitles.count) {
            titleLabel.text = self.request.columnTitles[i];
        }
        [titleView addSubview:titleLabel];
    }
    return titleView;
}

- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 240)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        
        if (self.request.isColumnsRelated)
        {
            [self pickViewer:_pickerView resetSelectedValue:self.request.defaultValues];
        }
        else
        {
            [self.request.defaultValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx < self.request.columns.count) {
                    NSInteger sIdx = [self.request.columns[idx] indexOfObject:obj];
                    if (sIdx != NSNotFound) {
                        [_pickerView selectRow:sIdx inComponent:idx animated:NO];
                    }
                }
            }];
        }
    }
    return _pickerView;
}

#pragma mark Private
- (id)targetWithColumn:(NSInteger)column
{
    NSInteger traverseCount = 0;
    
    NSArray *obj = self.request.columns.copy;
    
    id target;
    
    while (traverseCount <= column)
    {
        if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray *realObj = (NSArray *)obj;
            
            if (column <= self.currentSelectRows.count - 1 && column > 0) //最后一层是Array不需要取 && 第一层数据不需要遍历去除
            {
                NSString *levelKey = self.currentSelectRows[traverseCount];
                
                for (id tempObj in realObj)
                {
                    if ([tempObj isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *tempObjDic = (NSDictionary *)tempObj;
                        
                        if ([tempObjDic[@"title"] isKindOfClass:[NSString class]])
                        {
                            if ([tempObjDic[@"title"] isEqualToString:levelKey])
                            {
                                obj = tempObjDic[@"item"];
                                break;
                            }
                        }
                    }
                }
            }
            
            traverseCount ++ ;
            
            if (traverseCount >= column)
            {
                target = obj;
                break;
            }
        }
        else
        {
            return nil;
        }
    }
    
    return target;
}

- (void)pickViewer:(UIPickerView *)pickerView resetSelectedValue:(NSArray *)selectArray
{
    [selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        {
            if (idx < self.currentSelectRows.count)
            {
                id target = [self targetWithColumn:idx];
                
                if ([target isKindOfClass:[NSArray class]])
                {
                    NSArray *targetArray = (NSArray *)target;
                    
                    [targetArray enumerateObjectsUsingBlock:^(id  _Nonnull tempObj, NSUInteger tempIdx, BOOL * _Nonnull tempStop) {
                        
                        if ([tempObj isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *tempObjDic = (NSDictionary *)tempObj;
                            
                            if ([tempObjDic[@"title"] isKindOfClass:[NSString class]])
                            {
                                if ([tempObjDic[@"title"] isEqualToString:obj])
                                {
                                    [pickerView selectRow:tempIdx inComponent:idx animated:NO];
                                    [pickerView reloadAllComponents];
                                }
                            }
                        }
                        else if ([tempObj isKindOfClass:[NSString class]])
                        {
                            NSString *tempObjString = (NSString *)tempObj;
                            if ([tempObjString isEqualToString:obj])
                            {
                                [pickerView selectRow:tempIdx inComponent:idx animated:NO];
                                [pickerView reloadAllComponents];
                            }
                        }
                        
                    }];
                }
            }
        }
        
    }];
}

- (NSString *)titleOfObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objectDic = (NSDictionary *)object;
        
        id result = objectDic[@"title"];
        
        return ([result isKindOfClass:[NSString class]]) ? (NSString *)result : @"";
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        return (NSString *)object;
    }
    
    return @"";
}
@end

@implementation LGOPicker

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.Picker" instance:[self new]];
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOPickerRequest class]]) {
        LGOPickerOperation *operation = [LGOPickerOperation new];
        operation.request = (id)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"UI.Picker" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOPickerRequest *request = [LGOPickerRequest new];
    
    request.isColumnsRelated = [dictionary[@"isColumnsRelated"] boolValue];
    
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : nil;
    
    if (request.isColumnsRelated)
    {
        if ([dictionary[@"columns"] isKindOfClass:[NSArray class]])
        {
            request.columns = [dictionary[@"columns"] copy];
        }
        
        {
            
            NSMutableArray *outDefaultValues = [NSMutableArray array];
            if ([dictionary[@"defaultValues"] isKindOfClass:[NSArray class]]) {
                for (NSArray *defaultValue in dictionary[@"defaultValues"]) {
                    if ([defaultValue isKindOfClass:[NSString class]]) {
                        [outDefaultValues addObject:defaultValue];
                    }
                }
            }
            request.defaultValues = outDefaultValues;
        }
        {
            NSMutableArray *outColumnTitles = [NSMutableArray array];
            if ([dictionary[@"defaultValues"] isKindOfClass:[NSArray class]]) {
                for (NSArray *columnTitle in dictionary[@"columnTitles"]) {
                    if ([columnTitle isKindOfClass:[NSString class]]) {
                        [outColumnTitles addObject:columnTitle];
                    }
                    else {
                        [outColumnTitles addObject:@""];
                    }
                }
            }
            request.columnTitles = outColumnTitles;
        }
    }
    else
    {
        {
            
            NSMutableArray *outColumns = [NSMutableArray array];
            if ([dictionary[@"columns"] isKindOfClass:[NSArray class]]) {
                for (NSArray *column in dictionary[@"columns"]) {
                    if ([column isKindOfClass:[NSArray class]]) {
                        NSMutableArray *outColumn = [NSMutableArray array];
                        for (NSString *element in column) {
                            if ([element isKindOfClass:[NSString class]]) {
                                [outColumn addObject:element];
                            }
                        }
                        [outColumns addObject:outColumn];
                    }
                }
            }
            
            request.columns = outColumns;
            
        }
        {
            
            NSMutableArray *outDefaultValues = [NSMutableArray array];
            if ([dictionary[@"defaultValues"] isKindOfClass:[NSArray class]]) {
                for (NSArray *defaultValue in dictionary[@"defaultValues"]) {
                    if ([defaultValue isKindOfClass:[NSString class]]) {
                        [outDefaultValues addObject:defaultValue];
                    }
                }
            }
            request.defaultValues = outDefaultValues;
        }
        {
            NSMutableArray *outColumnTitles = [NSMutableArray array];
            if ([dictionary[@"defaultValues"] isKindOfClass:[NSArray class]]) {
                for (NSArray *columnTitle in dictionary[@"columnTitles"]) {
                    if ([columnTitle isKindOfClass:[NSString class]]) {
                        [outColumnTitles addObject:columnTitle];
                    }
                    else {
                        [outColumnTitles addObject:@""];
                    }
                }
            }
            request.columnTitles = outColumnTitles;
        }
    }
    
    
    
    return [self buildWithRequest:request];
}

@end
