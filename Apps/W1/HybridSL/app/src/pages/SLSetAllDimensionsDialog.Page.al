// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

page 47019 "SL Set All Dimensions Dialog"
{
    ApplicationArea = All;
    Caption = 'Set All Company Dimensions';
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            label(HeaderText)
            {
                Caption = 'Select the two segments from Dynamics SL you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
            }

            field("Dimension 1"; Dimension1)
            {
                Caption = 'Dimension 1';
                TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = const(''));
                ToolTip = 'Specifies the value for Dimension 1';
            }

            field("Dimension 2"; Dimension2)
            {
                Caption = 'Dimension 2';
                TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = const(''));
                ToolTip = 'Specifies the value for Dimension 2';

                trigger OnValidate()
                begin
                    if (Dimension1 <> '') and (Dimension1 = Dimension2) then
                        Error(GlobalDimensionsCannotBeTheSameErr);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionOK)
            {
                Caption = 'OK';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if (Dimension1 = '') and (Dimension2 = '') then
                        BlanksClearValue := Confirm(BothDimensionsBlankConfirmMsg)
                    else begin
                        if Dimension1 = '' then
                            BlanksClearValue := Confirm(OneDimensionBlankConfirmMsg, false, 1);

                        if Dimension2 = '' then
                            BlanksClearValue := Confirm(OneDimensionBlankConfirmMsg, false, 2);
                    end;

                    ConfirmedYes := true;
                    CurrPage.Close();
                end;
            }

            action(ActionCancel)
            {
                Caption = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SLDimensions.GetSegmentNames();
    end;

    internal procedure DeleteUniqueSegmentIndex()
    var
        SLSegmentName: Record "SL Segment Name";
    begin
        SLSegmentName.SetRange("Company Name", '');
        SLSegmentName.DeleteAll();
    end;

    internal procedure GenerateUniqueSegmentIndex()
    var
        HybridCompany: Record "Hybrid Company";
        SLSegmentName: Record "SL Segment Name";
        SLSegmentNameUnique: Record "SL Segment Name";
    begin
        DeleteUniqueSegmentIndex();

        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                MigratingCompanyList.Add(HybridCompany.Name);
            until HybridCompany.Next() = 0;

        SLSegmentName.SetFilter("Company Name", '<>%1', '');
        if SLSegmentName.FindSet() then
            repeat
                if not SLSegmentNameUnique.Get(SLSegmentName."Segment Name", '') then
                    if MigratingCompanyList.IndexOf(SLSegmentName."Company Name") > 0 then begin
                        SLSegmentNameUnique."Company Name" := '';
                        SLSegmentNameUnique."Segment Name" := SLSegmentName."Segment Name";
                        SLSegmentNameUnique."Segment Number" := SLSegmentName."Segment Number";
                        SLSegmentNameUnique.Insert();
                    end;
            until SLSegmentName.Next() = 0;
    end;

    internal procedure GetDimension1(): Text[30]
    begin
        exit(Dimension1);
    end;

    internal procedure GetDimension2(): Text[30]
    begin
        exit(Dimension2);
    end;

    internal procedure GetBlanksClearValue(): Boolean
    begin
        exit(BlanksClearValue);
    end;

    internal procedure GetConfirmedYes(): Boolean
    begin
        exit(ConfirmedYes);
    end;

    var
        SLDimensions: Codeunit "SL Dimensions";
        BlanksClearValue: Boolean;
        ConfirmedYes: Boolean;
        GlobalDimensionsCannotBeTheSameErr: Label 'Dimension 1 and Dimension 2 cannot be the same.';
        BothDimensionsBlankConfirmMsg: Label 'Both dimensions are empty. Do you want to clear both dimensions for all companies?';
        OneDimensionBlankConfirmMsg: Label 'You don''t have a value for Dimension %1. Do you want to clear Dimension %1 for all companies?', Comment = '%1 - Dimension name';
        MigratingCompanyList: List of [Text];
        Dimension1: Text[30];
        Dimension2: Text[30];
}