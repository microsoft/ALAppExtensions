// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Inventory.Location;

page 11703 "Inc./Dec. Qty. per Loc. CZL"
{
    Caption = 'Increase/Decrease the Quantity per Location CZL';
    PageType = List;
    SourceTable = "User Setup per Code Buffer CZL";
    SourceTableTemporary = true;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Location Code"; Rec.Code)
                {
                    Caption = 'Location Code';
                    ToolTip = 'Specifies the location code.';
                    TableRelation = Location;
                }
                field("User ID"; Rec."User ID")
                {
                    LookupPageID = "User Lookup";
                }
                field("User Name"; Rec."User Name")
                {
                }
                field("Post Quantity Increase"; Rec."Post Quantity Increase")
                {
                }
                field("Post Quantity Decrease"; Rec."Post Quantity Decrease")
                {
                }
                field("Release Quantity Increase"; Rec."Release Quantity Increase")
                {
                }
                field("Release Quantity Decrease"; Rec."Release Quantity Decrease")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitBuffer();
    end;

    trigger OnClosePage()
    begin
        Rec.WriteChanges();
    end;

    local procedure InitBuffer()
    var
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        UserSetupLineCZL.Reset();
        Rec.CopyFilter(Code, UserSetupLineCZL."Code / Name");
        UserSetupLineCZL.Setfilter(Type, '%1|%2|%3|%4',
            UserSetupLineCZL.Type::"Location (quantity increase)",
            UserSetupLineCZL.Type::"Location (quantity decrease)",
            UserSetupLineCZL.Type::"Release Location (quantity increase)",
            UserSetupLineCZL.Type::"Release Location (quantity decrease)");
        Rec.ReadFrom(UserSetupLineCZL);
    end;
}