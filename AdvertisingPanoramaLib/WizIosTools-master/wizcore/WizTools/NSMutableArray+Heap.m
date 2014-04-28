//
//  NSMutableArray+Heap.m
//  WizNote
//
//  Created by dzpqzb on 13-5-28.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "NSMutableArray+Heap.h"
@protocol WizHeapCompareProtocol
- (NSString*) heapKey;
- (NSComparisonResult) compareHeapObject:(id<WizHeapCompareProtocol>)objcect;
@end

int (^HeapParent)(int) = ^(int i)
{
    return (int)floor(i/2);
};

int (^HeapLeftChild)(int) = ^(int i )
{
    return i*2;
};

int (^HeapRightChild)(int) = ^(int i )
{
    return i*2 +1;
};

@interface HeapTest : NSObject <WizHeapCompareProtocol>
@property (nonatomic, strong) NSString* indetifier;
@end

@implementation HeapTest
@synthesize indetifier = _indetifier;
- (id) initWithString:(NSString*)str
{
    self =[super init];
    if (self) {
        _indetifier = str;
    }
    return self;
}
- (NSString*) heapKey
{
    return _indetifier;
}

- (NSComparisonResult) compareHeapObject:(id<WizHeapCompareProtocol>)objcect
{
    return [self.heapKey compare:[objcect heapKey]];
}
- (NSString*) description
{
    return _indetifier;
}
@end

@implementation NSMutableArray (Heap)
- (void) makeMaxHeapify:(int)i
{
    int count = [self count];
    id<WizHeapCompareProtocol> object = self[i];
    int leftIndex = HeapLeftChild(i);
    int rightIndex = HeapRightChild(i);
    int largest = i;
    if (leftIndex < count && [self[leftIndex] compareHeapObject:object] == NSOrderedDescending) {
        largest = leftIndex;
    }
    if (rightIndex < count && [self[rightIndex] compareHeapObject:self[largest]] == NSOrderedDescending){
        largest = rightIndex;
    }
    if (largest != i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:largest];
        [self makeMaxHeapify:largest];
    }
}

- (void) buildMaxHeap
{
    for (int i = floor(self.count/2); i >= 1; --i) {
        [self makeMaxHeapify:i];
    }
}

- (void) printSelf
{
    for (id each in self) {
        NSLog(@"%@",each);
    }
}

- (id) heapExtractMax
{
    if (self.count < 1) {
        return nil;
    }
    id max = self[1];
    [self exchangeObjectAtIndex:1 withObjectAtIndex:self.count-1];
    [self removeLastObject];
    [self makeMaxHeapify:1];
    return max;
}

- (void) heapIncreaseObject:(id<WizHeapCompareProtocol>)object
{
    [self addObject:object];
    int i  = self.count -1;
    NSLog(@"%@ %@",self[HeapParent(i)], self[i]);
    NSLog(@"%d",[self[HeapParent(i)] compareHeapObject:self[i]] == NSOrderedAscending);
    while (i > 1 && [self[HeapParent(i)] compareHeapObject:self[i]] == NSOrderedAscending) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:HeapParent(i)];
        i = HeapParent(i);
    }
}

+ (void) test
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 10; i++) {
        HeapTest* a = [[HeapTest alloc] initWithString:[NSString stringWithFormat:@"%d",i]];
        [array addObject:a];
    }
    
    [array buildMaxHeap];
    
    for (int i = 0; i < 4; i++) {
        HeapTest* b = [[HeapTest alloc] initWithString:[NSString stringWithFormat:@"%d", (i+10)*3]];
        [array heapIncreaseObject:b];

    }
}

@end
