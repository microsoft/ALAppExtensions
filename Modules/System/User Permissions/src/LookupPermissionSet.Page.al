// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Look up page for selecting a permission set.
/// </summary>
page 9854 "Lookup Permission Set"
{
    Caption = 'Permission Set Lookup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Aggregate Permission Set";
    SourceTableView = sorting(Scope, "Role ID", "App ID")
                      order(ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID"; Rec."Role ID")
                {
                    Caption = 'Permission Set';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a permission set that defines the role.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the permission set.';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension that provides the permission set.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set is specific to your tenant or generally available in the system.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SelectedRecord := Rec;
    end;

    procedure GetSelectedRecord(var CurrSelectedRecord: Record "Aggregate Permission Set")
    begin
        CurrSelectedRecord := SelectedRecord;
    end;

    procedure GetSelectedRecords(var CurrSelectedRecords: Record "Aggregate Permission Set")
    begin
        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            CurrSelectedRecords.Copy(Rec);
            CurrSelectedRecords.Insert();
        until Rec.Next() = 0;
    end;

    var
        SelectedRecord: Record "Aggregate Permission Set";
}


