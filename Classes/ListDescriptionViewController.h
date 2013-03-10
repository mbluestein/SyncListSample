//
//  ListDescriptionViewController.h
//  iPhoneListSample
//
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListEntity.h"

@interface ListDescriptionViewController : UIViewController {
	bool inAddMode;
	ListEntity *listToEdit;
	IBOutlet UITextField *nameField;
	IBOutlet UITextView *descriptionField;
}

@property (nonatomic) bool inAddMode;
@property (nonatomic, strong) ListEntity *listToEdit;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextView *descriptionField;

-(IBAction)dismissKeyboard: (id)sender;
@end
