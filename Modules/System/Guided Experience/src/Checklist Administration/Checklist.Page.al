// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists all checklist items and provides capabilities to edit and insert new ones based on existing guided experience items.
/// </summary>
page 1993 Checklist
{
    Caption = 'Checklist Administration';
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Checklist Item Buffer";
    SourceTableTemporary = true;
    UsageCategory = Lists;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Title; Title)
                {
                    Caption = 'Task';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the checklist item as it will display in the checklist. Choose from the list of previously defined tasks.';

                    trigger OnDrillDown()
                    begin
                        RunCardPage();
                        CurrPage.Update();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the checklist item.';
                }
                field("Expected Duration"; "Expected Duration")
                {
                    Caption = 'Expected Duration (in minutes)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies how long you expect it will take to complete the checklist item, such as 2 minutes or 10 minutes.';
                }
                field("Completition Requirements"; "Completion Requirements")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the completition requirements of the checklist item.';
                }
                field("Assigned To"; "Assigned To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which users or roles the checklist item is assigned to.';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which step in the checklist this task will appear at.';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action("Create checklist item")
            {
                ApplicationArea = All;
                Image = New;
                ToolTip = 'Add a new task for the checklist.';
                ShortcutKey = return;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ChecklistItemBuffer: Record "Checklist Item Buffer";
                begin
                    ChecklistItemBuffer.ID := CreateGuid();
                    ChecklistItemBuffer.Code := '0';
                    ChecklistItemBuffer.Insert();
                    Page.RunModal(Page::"Checklist Administration", ChecklistItemBuffer);
                    GetPageContent();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        GetPageContent();
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        ChecklistImplementation.Delete(Code);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        RunCardPage();
    end;

    local procedure RunCardPage()
    begin
        Page.RunModal(Page::"Checklist Administration", Rec);
    end;

    local procedure GetPageContent()
    var
        ChecklistBanner: Codeunit "Checklist Banner";
    begin
        ChecklistBanner.GetAllChecklistItems(Rec);
        Rec.SetCurrentKey("Order ID");
    end;
}