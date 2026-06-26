#import "IGTestStoryboardSupplementarySource.h"
#import "IGTestStoryboardSupplementaryView.h"

@implementation IGTestStoryboardSupplementarySource

- (UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                        atIndex:(NSInteger)index {
    IGTestStoryboardSupplementaryView 
    *view = [self.collectionContext dequeueReusableSupplementaryViewFromStoryboardOfKind:elementKind
      withIdentifier:@"IGTestStoryboardSupplementaryView" forSectionController:self.sectionController
                    atIndex:index];
    view.label.text = @"Header";
    return view;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    return CGSizeMake([self.collectionContext containerSize].width, 45);
}

@end
