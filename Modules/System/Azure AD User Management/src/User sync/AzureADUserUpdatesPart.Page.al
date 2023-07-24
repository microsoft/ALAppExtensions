// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list part page to view and remove synchronized user updates.
/// </summary>
page 9516 "Azure AD User Updates Part"
{
    Caption = 'Updates';
    PageType = ListPart;
    SourceTable = "Azure AD User Update Buffer";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    Permissions = tabledata "Azure AD User Update Buffer" = rd;

    layout
    {
        area(content)
        {
            repeater(Updates)
            {
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the display name of the user who the update relates to.';
                    ApplicationArea = All;
                }
                field("Authentication Object ID"; Rec."Authentication Object ID")
                {
                    ToolTip = 'Specifies the AAD user ID of the user who the update relates to.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Update Type"; Rec."Update Type")
                {
                    ToolTip = 'Specifies the type of update.';
                    ApplicationArea = All;
                }
                field("Information"; Rec."Update Entity")
                {
                    ToolTip = 'Specifies the user information that will be updated. Updates related to Contact Email, Full Name and Language ID are optional and may be removed.';
                    ApplicationArea = All;
                }
                field("Current Value"; Rec."Current Value")
                {
                    ToolTip = 'Specifies the current value of the target user information before the update.';
                    ApplicationArea = All;
                }
                field("New Value"; Rec."New Value")
                {
                    ToolTip = 'Specifies the new value of the target user information after the update.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Remove")
            {
                ApplicationArea = All;
                Caption = 'Remove';
                ToolTip = 'Removes the selected updates.';
                Image = DeleteRow;
                Enabled = RemoveAllowed;
                Scope = Repeater;

                trigger OnAction()
                var
                    ConfirmQst: Text;
                begin
                    if RequiredUpdateSelected() then
                        ConfirmQst := RemoveRowsExpandedQst
                    else
                        ConfirmQst := RemoveRowsQst;

                    if not Confirm(ConfirmQst) then
                        exit;

                    SetRemoveEnabledOrDeleteRecords(true);
                end;
            }
        }
    }

    var
        RemoveAllowed: Boolean;
        RemoveRowsQst: Label 'Do you want to remove the selected updates?';
        RemoveRowsExpandedQst: Label 'Do you want to remove the selected updates? Only updates related to Contact Email, Full Name and Language ID will be removed.';

    trigger OnAfterGetCurrRecord()
    begin
        RemoveAllowed := false;
        SetRemoveEnabledOrDeleteRecords(false);
    end;

    // If DeleteRecords is set to true, delete the selected, non-required updates. Otherwise, set RemoveAllowed for Remove action enabled.
    local procedure SetRemoveEnabledOrDeleteRecords(DeleteRecords: Boolean)
    var
        TempSelectedUpdates: Record "Azure AD User Update Buffer" temporary;
    begin
        TempSelectedUpdates.Copy(Rec, true);
        CurrPage.SetSelectionFilter(TempSelectedUpdates);
        if TempSelectedUpdates.FindSet() then
            repeat
                if not UpdateIsRequired(TempSelectedUpdates) then
                    if DeleteRecords then
                        TempSelectedUpdates.Delete()
                    else begin
                        RemoveAllowed := true;
                        break;
                    end;
            until TempSelectedUpdates.Next() = 0;
    end;

    local procedure RequiredUpdateSelected(): Boolean
    var
        TempSelectedUpdates: Record "Azure AD User Update Buffer" temporary;
    begin
        TempSelectedUpdates.Copy(Rec, true);
        CurrPage.SetSelectionFilter(TempSelectedUpdates);
        if TempSelectedUpdates.FindSet() then
            repeat
                if UpdateIsRequired(TempSelectedUpdates) then
                    exit(true);
            until TempSelectedUpdates.Next() = 0;
        exit(false);
    end;


    local procedure UpdateIsRequired(Update: Record "Azure AD User Update Buffer"): Boolean
    begin
        exit(not (Update."Update Entity" in [Update."Update Entity"::"Contact Email", Update."Update Entity"::"Full Name", Update."Update Entity"::"Language ID"]));
    end;

    internal procedure SetUpdates(var UpdateBuffer: Record "Azure AD User Update Buffer" temporary)
    begin
        Rec.Copy(UpdateBuffer, true);
    end;
}