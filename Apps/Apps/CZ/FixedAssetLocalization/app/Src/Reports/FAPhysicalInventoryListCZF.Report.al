// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;

report 31253 "FA Physical Inventory List CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FAPhysicalInventoryList.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'FA Physical Inventory List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(DocumentNo; DocumentNo)
            {
            }
            column(DocumentDate; DocumentDate)
            {
            }
            column(PrintFAValues; PrintFAValues)
            {
            }
            column(NewPagePerGroup; NewPagePerGroup)
            {
            }
            column(GroupByNumber; Format(GroupBy, 0, 2))
            {
            }
            column(Member1; Member[1])
            {
            }
            column(Member2; Member[2])
            {
            }
            column(Member3; Member[3])
            {
            }
            column(GetGroupHeader; GetGroupHeader())
            {
            }
            column(FixedAsset_No; "No.")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_Description; Description)
            {
                IncludeCaption = true;
            }
            column(FixedAsset_SerialNo; "Serial No.")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_ResponsibleEmployee; "Responsible Employee")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_MainAssetComponent; "Main Asset/Component")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_FALocationCode; "FA Location Code")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_FASubclassCode; "FA Subclass Code")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_FAClassCode; "FA Class Code")
            {
                IncludeCaption = true;
            }
            column(FixedAsset_Description2; "Description 2")
            {
                IncludeCaption = true;
            }
            column(Qty; Qty)
            {
                DecimalPlaces = 0 : 0;
            }
            column(FADeprBook_AcquisitionCost; FADepreciationBook."Acquisition Cost")
            {
            }
            column(FADeprBook_Depreciation; -FADepreciationBook.Depreciation)
            {
            }
            column(FADeprBook_BookValue; FADepreciationBook."Book Value")
            {
            }
            column(FADeprBook_WriteDown; -FADepreciationBook."Write-Down")
            {
            }
            column(FADeprBook_Appreciation; FADepreciationBook.Appreciation)
            {
            }
            column(LineNo; LineNo)
            {
            }
            column(Totals1; Totals[1])
            {
            }
            column(Totals2; -Totals[2])
            {
            }
            column(Totals3; Totals[3])
            {
            }
            column(GetGroupFooter; GetGroupFooter())
            {
            }
            column(GroupExpression; GroupExpression)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not FADepreciationBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                FADepreciationBook.SetRange("FA Posting Date Filter", 0D, DocumentDate);
                FADepreciationBook.CalcFields("Acquisition Cost", Depreciation, "Book Value", "Write-Down", Appreciation);
                if (FADepreciationBook."Disposal Date" > 0D) and (FADepreciationBook."Disposal Date" < DocumentDate) then
                    FADepreciationBook."Book Value" := 0;
                if (FADepreciationBook."Book Value" = 0) and (not PrintZeroBookValue) then
                    CurrReport.Skip();

                Totals[1] := FADepreciationBook."Acquisition Cost";
                Totals[2] := FADepreciationBook.Depreciation;
                Totals[3] := FADepreciationBook."Book Value";
                Qty := 1;
                LineNo += 1;

                case GroupBy of
                    GroupBy::None:
                        GroupExpression := '';
                    GroupBy::"FA Location Code Only":
                        GroupExpression := "FA Location Code";
                    GroupBy::"Responsible and Location":
                        GroupExpression := "Responsible Employee" + "FA Location Code";
                    GroupBy::"FA Location and Responsible":
                        GroupExpression := "FA Location Code" + "Responsible Employee";
                    GroupBy::"Responsible Employee Only":
                        GroupExpression := "Responsible Employee";
                end;
            end;

            trigger OnPreDataItem()
            begin
                Qty := 0;
                LineNo := 0;
                case GroupBy of
                    GroupBy::"FA Location Code Only",
                  GroupBy::"FA Location and Responsible":
                        SetCurrentKey("FA Location Code", "Responsible Employee");
                    GroupBy::"Responsible Employee Only",
                  GroupBy::"Responsible and Location":
                        SetCurrentKey("Responsible Employee", "FA Location Code");
                end;
                Clear(Totals);
                Clear(Qty);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DeprBookCodeCZF; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';
                    }
                    field(DocumentNoCZF; DocumentNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document number for the document.';
                    }
                    field(DocumentDateCZF; DocumentDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Document Date';
                        ToolTip = 'Specifies a document date for the document.';
                    }
                    field(PrintFAValuesCZF; PrintFAValues)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print FA Values';
                        ToolTip = 'Specifies to print fixed asset values.';
                    }
                    field(PrintZeroBookValueCZF; PrintZeroBookValue)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print FA with Zero Book Value';
                        ToolTip = 'Specifies to print fixed assets with zero book values.';
                    }
                    field(GroupByCZF; GroupBy)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group By';
                        OptionCaption = 'None,FA Location Code Only,Responsible Employee Only,FA Location and Responsible,Responsible and Location';
                        ToolTip = 'Specifies how fixed assets should be grouped.';
                    }
                    field(NewPagePerGroupCZF; NewPagePerGroup)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'New Page Per Group';
                        ToolTip = 'Specifies if you want the report to print a new page for each group.';
                    }
                    field(Member1; Member[1])
                    {
                        ApplicationArea = FixedAssets;
                        Caption = '1. Persona';
                        TableRelation = "Company Official CZL";
                        ToolTip = 'Specifies an employee name from the company official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(Page::"Company Official List CZL", CompanyOfficialCZL) = ACTION::LookupOK then
                                Member[1] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field(Member2; Member[2])
                    {
                        ApplicationArea = FixedAssets;
                        Caption = '2. Persona';
                        ToolTip = 'Specifies an employee name from the company official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(Page::"Company Official List CZL", CompanyOfficialCZL) = ACTION::LookupOK then
                                Member[2] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field(Member3; Member[3])
                    {
                        ApplicationArea = FixedAssets;
                        Caption = '3. Persona';
                        ToolTip = 'Specifies an employee name from the company official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(Page::"Company Official List CZL", CompanyOfficialCZL) = ACTION::LookupOK then
                                Member[3] := CompanyOfficialCZL.FullName();
                        end;
                    }
                }
            }
        }
    }

    labels
    {
        ReportLbl = 'Fixed Asset Physical Inventory Document';
        PageLbl = 'Page';
        DocumentNoLbl = 'Document No.';
        AtDateLbl = 'At Date';
        CommitteeMembersLbl = 'Committee members';
        N1Lbl = '1.';
        N2Lbl = '2.';
        N3Lbl = '3.';
        DateSignatureLbl = 'Date, Signature';
        ApprovedLbl = 'Approved by Committee Members:';
        InventoryBeginLbl = 'Inventory Begin Date and Time';
        InventoryEndLbl = 'Inventory End Date and Time';
        AcquisitionCostLbl = 'Acquisition Cost';
        DepreciationLbl = 'Depreciation';
        BookValueLbl = 'Book Value';
        WriteDownLbl = 'Write-Down';
        AppreciationLbl = 'Appreciation';
        LineNoLbl = 'Line No.';
        QtyInvLbl = 'Quantity Inventored';
        TotalQuantityAmountLbl = 'Total (Quantity, Amount):';
    }

    trigger OnPreReport()
    begin
        if DeprBookCode = '' then
            Error(EmptyDeprBookErr);
        NewPagePerGroup := GroupBy <> GroupBy::None;
    end;

    var
        CompanyOfficialCZL: Record "Company Official CZL";
        FADepreciationBook: Record "FA Depreciation Book";
        PrintFAValues, PrintZeroBookValue : Boolean;
        DocumentNo, DeprBookCode : Code[10];
        LineNo: Integer;
        Qty: Decimal;
        Totals: array[3] of Decimal;
        GroupBy: Option "None","FA Location Code Only","Responsible Employee Only","FA Location and Responsible","Responsible and Location";
        Member: array[3] of Text;
        DocumentDate: Date;
        NewPagePerGroup: Boolean;
        GroupExpression: Code[30];
        EmptyDeprBookErr: Label 'Depreciation book code must not be empty.';
        TotalTxt: Label 'Totals for';
        TwoPlaceholdersTok: Label '%1: %2', Locked = true;
        ThreePlaceholdersTok: Label '%1 %2: %3', Locked = true;
        FourPlaceholdersTok: Label '%1: %2, %3: %4', Locked = true;
        FivePlaceholdersTok: Label '%1 %2: %3, %4: %5', Locked = true;

    procedure GetGroupHeader(): Text
    begin
        case GroupBy of
            GroupBy::"FA Location Code Only":
                exit(
                  StrSubstNo(TwoPlaceholdersTok,
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code"));
            GroupBy::"Responsible Employee Only":
                exit(
                  StrSubstNo(TwoPlaceholdersTok,
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee"));
            GroupBy::"FA Location and Responsible":
                exit(
                  StrSubstNo(FourPlaceholdersTok,
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code",
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee"));
            GroupBy::"Responsible and Location":
                exit(
                  StrSubstNo(FourPlaceholdersTok,
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee",
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code"));
            else
                exit('');
        end;
    end;

    procedure GetGroupFooter(): Text
    begin
        case GroupBy of
            GroupBy::"FA Location Code Only":
                exit(
                  StrSubstNo(ThreePlaceholdersTok, TotalTxt,
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code"));
            GroupBy::"Responsible Employee Only":
                exit(
                  StrSubstNo(ThreePlaceholdersTok, TotalTxt,
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee"));
            GroupBy::"FA Location and Responsible":
                exit(
                  StrSubstNo(FivePlaceholdersTok, TotalTxt,
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code",
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee"));
            GroupBy::"Responsible and Location":
                exit(
                  StrSubstNo(FivePlaceholdersTok, TotalTxt,
                    "Fixed Asset".FieldCaption("Responsible Employee"), "Fixed Asset"."Responsible Employee",
                    "Fixed Asset".FieldCaption("FA Location Code"), "Fixed Asset"."FA Location Code"));
            else
                exit('');
        end;
    end;
}
