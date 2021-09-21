// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page to view address entities
/// </summary>
page 8945 "Email Address Entity"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Address Entity";
    Caption = 'Entities';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Type"; "Source Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Entity Name.';
                }
            }
        }
    }

    internal procedure GetSelectedAddresses(var AddressEntity: Record "Address Entity")
    begin
        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            AddressEntity.Copy(Rec);
            AddressEntity.Insert();
        until Rec.Next() = 0;
    end;

    internal procedure InsertAddresses(var AddressEntity: Record "Address Entity")
    begin
        if AddressEntity.FindSet() then
            repeat
                Rec.Copy(AddressEntity);
                Rec.Insert();
            until AddressEntity.Next() = 0;
    end;
}