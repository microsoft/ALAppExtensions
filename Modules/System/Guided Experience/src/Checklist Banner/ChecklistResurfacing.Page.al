// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1997 "Checklist Resurfacing"
{
    PageType = ConfirmationDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Show the checklist';
    AdditionalSearchTerms = 'Tour,Checklist,Resurface,Banner';

    layout
    {
        area(Content)
        {
            label(Name)
            {
                ApplicationArea = All;
                Caption = 'Do you want to see the checklist on your home page?';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ChecklistImplementation: Codeunit "Checklist Implementation";
        UserNameCode: Code[50];
    begin
        if CloseAction = CloseAction::Yes then begin
            UserNameCode := CopyStr(UserId(), 1, 50);
            If not ChecklistImplementation.DoesUserHaveChecklistItemsAssigned(UserNameCode) then
                Message(EmptyChecklistMsg)
            else
                ChecklistImplementation.SetChecklistVisibility(UserId(), true, true);
        end;
    end;

    var
        EmptyChecklistMsg: Label 'Your checklist is empty. You can add items to it on the Checklist Administration page.';
}