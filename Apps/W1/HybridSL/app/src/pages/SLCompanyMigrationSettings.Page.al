// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 47010 "SL Company Migration Settings"
{
    ApplicationArea = All;
    Caption = 'Select company settings for data migration';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "SL Company Migration Settings";
    SourceTableView = where(Replicate = const(true));

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;

                field(Name; Rec.Name)
                {
                    Editable = false;
                    ToolTip = 'Name of the company';
                    Width = 6;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    Caption = 'Global Dimension 1';
                    ToolTip = 'Global Dimension 1';
                    Width = 10;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    Caption = 'Global Dimension 2';
                    ToolTip = 'Global Dimension 2';
                    Width = 10;
                }
                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    Caption = 'Migrate Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';
                    Width = 8;
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Migrate Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    Width = 8;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SLSegmentNames: Record "SL Segment Name";
    begin
        SLSegmentNames.SetFilter("Company Name", Rec.Name);
        if Rec."Global Dimension 1" = '' then
            if SLSegmentNames.FindFirst() then
                Rec."Global Dimension 1" := SLSegmentNames."Segment Name";
        if Rec."Global Dimension 2" = '' then begin
            SLSegmentNames.SetFilter("Segment Name", '<> %1', Rec."Global Dimension 1");
            if SLSegmentNames.FindFirst() then
                Rec."Global Dimension 2" := SLSegmentNames."Segment Name";
        end;

        Rec.Modify();
    end;
}