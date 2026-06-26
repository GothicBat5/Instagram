#import "IGListBatchUpdateData.h"
#import <unordered_map>

#if !__has_include(<IGListDiffKit/IGListDiffKit.h>)
#import "IGListAssert.h"
#else
#import <IGListDiffKit/IGListAssert.h>
#endif

#import "IGListCompatibility.h"

static void convertMoveToDeleteAndInsert(NSMutableSet<IGListMoveIndex *> *moves,
                                         IGListMoveIndex *move,
                                         NSMutableIndexSet *deletes,
                                         NSMutableIndexSet *inserts) {
    [moves removeObject:move];

    [deletes addIndex:move.from];
    [inserts addIndex:move.to];
}

@implementation IGListBatchUpdateData
+ (void)_cleanIndexPathsWithMap:(const std::unordered_map<NSInteger, IGListMoveIndex*> &)map
                         moves:(NSMutableSet<IGListMoveIndex *> *)moves
                    indexPaths:(NSMutableArray<NSIndexPath *> *)indexPaths
                       deletes:(NSMutableIndexSet *)deletes
                       inserts:(NSMutableIndexSet *)inserts {
    if (indexPaths.count == 0) 
    {
        return;
    }
    //std
    for (NSInteger i = indexPaths.count - 1; i >= 0; i--) 
    {
        NSIndexPath *path = indexPaths[i];
        const auto it = map.find(path.section);
        
        if (it != map.end() && it->second != nil) 
        {
            [indexPaths removeObjectAtIndex:i];
            convertMoveToDeleteAndInsert(moves, it->second, deletes, inserts);
        }
    }
}

- (instancetype)initWithInsertSections:(nonnull NSIndexSet *)insertSections
                        deleteSections:(nonnull NSIndexSet *)deleteSections
                          moveSections:(nonnull NSSet<IGListMoveIndex *> *)moveSections
                      insertIndexPaths:(nonnull NSArray<NSIndexPath *> *)insertIndexPaths
                      deleteIndexPaths:(nonnull NSArray<NSIndexPath *> *)deleteIndexPaths
                      updateIndexPaths:(nonnull NSArray<NSIndexPath *> *)updateIndexPaths
                        moveIndexPaths:(nonnull NSArray<IGListMoveIndexPath *> *)moveIndexPaths {
    IGParameterAssert(insertSections != nil);
    IGParameterAssert(deleteSections != nil);
    IGParameterAssert(moveSections != nil);
    IGParameterAssert(insertIndexPaths != nil);
    IGParameterAssert(deleteIndexPaths != nil);
    IGParameterAssert(updateIndexPaths != nil);
    IGParameterAssert(moveIndexPaths != nil);
    if (self = [super init]) 
    {
        NSMutableSet<IGListMoveIndex *> *mMoveSections = [moveSections mutableCopy];
        NSMutableIndexSet *mDeleteSections = [deleteSections mutableCopy];
        NSMutableIndexSet *mInsertSections = [insertSections mutableCopy];
        NSMutableSet<IGListMoveIndexPath *> *mMoveIndexPaths = [moveIndexPaths mutableCopy];

        const NSInteger moveCount = [moveSections count];
        std::unordered_map<NSInteger, IGListMoveIndex*> fromMap(MAX(moveCount, 1));
        std::unordered_map<NSInteger, IGListMoveIndex*> toMap(MAX(moveCount, 1));
        
        for (IGListMoveIndex *move in moveSections) 
        {
            const NSInteger from = move.from;
            const NSInteger to = move.to;

            if ([deleteSections containsIndex:from] || 
            [insertSections containsIndex:to]) 
            {
                [mMoveSections removeObject:move];
            } 
            else {
                fromMap[from] = move;
                toMap[to] = move;
            }
        }

        NSMutableArray<NSIndexPath *> *mDeleteIndexPaths;
        NSMutableArray<NSIndexPath *> *mInsertIndexPaths;
        NSMutableDictionary<NSIndexPath *, NSNumber *> *const deleteCounts = [NSMutableDictionary new];

        for (NSIndexPath *deleteIndexPath in deleteIndexPaths) 
        {
            const NSInteger deleteCount = deleteCounts[deleteIndexPath].integerValue;
            deleteCounts[deleteIndexPath] = @(deleteCount + 1);
        }

        NSMutableArray<NSIndexPath *> *const trimmedInsertIndexPath = [NSMutableArray new];
        for (NSIndexPath *insertIndexPath in insertIndexPaths) 
        {
            const NSInteger deleteCount = deleteCounts[insertIndexPath].integerValue;
            if (deleteCount > 1) 
            {
                // Skip!
                deleteCounts[insertIndexPath] = @(deleteCount - 1);
            } 
            else {
                [trimmedInsertIndexPath addObject:insertIndexPath];
            }
        }

        mDeleteIndexPaths = [[deleteCounts allKeys] mutableCopy];
        mInsertIndexPaths = trimmedInsertIndexPath;

        [IGListBatchUpdateData _cleanIndexPathsWithMap:fromMap moves:mMoveSections indexPaths:mDeleteIndexPaths 
        deletes:mDeleteSections inserts:mInsertSections];

        [IGListBatchUpdateData _cleanIndexPathsWithMap:toMap moves:mMoveSections 
        indexPaths:mInsertIndexPaths deletes:mDeleteSections inserts:mInsertSections];

        for (IGListMoveIndexPath *move in moveIndexPaths) 
        {
            if ([deleteSections containsIndex:move.from.section]) 
            {
                [mMoveIndexPaths removeObject:move];
            }

            const auto it = fromMap.find(move.from.section);
            if (it != fromMap.end() && it->second != nil) 
            {
                IGListMoveIndex *sectionMove = it->second;
                [mMoveIndexPaths removeObject:move];
                [mMoveSections removeObject:sectionMove];
                [mDeleteSections addIndex:sectionMove.from];
                [mInsertSections addIndex:sectionMove.to];
            }
        }

        _deleteSections = [mDeleteSections copy];
        _insertSections = [mInsertSections copy];
        _moveSections = [mMoveSections copy];
        _deleteIndexPaths = [mDeleteIndexPaths copy];
        _insertIndexPaths = [mInsertIndexPaths copy];
        _updateIndexPaths = [updateIndexPaths copy];
        _moveIndexPaths = [mMoveIndexPaths copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) 
    {
        return YES;
    }
    if ([object isKindOfClass:[IGListBatchUpdateData class]]) 
    {
        return ([self.insertSections isEqual:[object insertSections]]
                && [self.deleteSections isEqual:[object deleteSections]]
                && [self.moveSections isEqual:[object moveSections]]
                && [self.insertIndexPaths isEqual:[object insertIndexPaths]]
                && [self.deleteIndexPaths isEqual:[object deleteIndexPaths]]
                && [self.updateIndexPaths isEqual:[object updateIndexPaths]]
                && [self.moveIndexPaths isEqual:[object moveIndexPaths]]);
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; deleteSections: %lu; insertSections: %lu; moveSections: %lu; deleteIndexPaths: %lu; insertIndexPaths: %lu; updateIndexPaths: %lu>",
            NSStringFromClass(self.class), self, 
            (unsigned long)self.deleteSections.count, (unsigned long)self.insertSections.count, 
            (unsigned long)self.moveSections.count,
            (unsigned long)self.deleteIndexPaths.count, (unsigned long)self.insertIndexPaths.count, 
            (unsigned long)self.updateIndexPaths.count];
}

@end
