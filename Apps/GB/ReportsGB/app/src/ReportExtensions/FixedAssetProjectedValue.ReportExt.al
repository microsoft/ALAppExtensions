// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Depreciation;

reportextension 10583 "Fixed Asset - Projected Value" extends "Fixed Asset - Projected Value"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/FixedAssetProjectedValue.rdlc';
#endif
    dataset
    {
        add("Fixed Asset")
        {
            column(FORMAT_TODAY_0_4__; Format(Today, 0, 4))
            {
            }
            column(USER_ID; UserId)
            {
            }
            column(GroupAmounts_1__; GroupAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalBookValue_1__; TotalBookValue[1])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts_2__; GroupAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts_1____GroupAmounts_2__; GroupAmounts[1] + GroupAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(FA_Ledger_Entry___FA_Posting_Type_Caption; "FA Ledger Entry".FieldCaption("FA Posting Type"))
            {
            }
            column(FA__Ledger_Entry_AmountCaption; "FA Ledger Entry".FieldCaption(Amount))
            {
            }
            column(FA__Ledger_Entry__No__of_Depreciation_Days_Caption; "FA Ledger Entry".FieldCaption("No. of Depreciation Days"))
            {
            }
        }
        add(ProjectedDepreciation)
        {
            column(Fixed_Asset___No____Control29; "Fixed Asset"."No.")
            {
            }
            column(UntilDate__Control30; Format(UntilDate))
            {
            }
            column(Fixed_Asset___No____Control42; "Fixed Asset"."No.")
            {
            }
            column(DeprText2__Control51; DeprText2)
            {
            }
            column(EntryAmounts__1__Control50; EntryAmounts_1)
            {
                AutoFormatType = 1;
            }
            column(Custom1Text__Control22; Custom1Text)
            {
            }
            column(ProjectedDepreciation__Number; Number)
            {
            }
        }
        add(ProjectionTotal)
        {
            column(ProjectionTotal__Number; Number)
            {
            }
        }
        add(Buffer)
        {
            column(FORMAT__TODAY_0_4__Control68; Format(Today, 0, 4))
            {
            }
            column(USERID__Control72; UserId)
            {
            }
            column(COMPANYNAME__Control76; COMPANYPROPERTY.DisplayName())
            {
            }
            column(Buffer__Number; Number)
            {
            }
            column(CurrReport__PAGENO_Control73Caption; CurrReport_PAGENO_Control73CaptionLbl)
            {
            }
        }
        add("FA Ledger Entry")
        {
            column(FA__Ledger_Entry__FA_Posting_Type_; "FA Posting Type")
            {
            }
            column(FA__Ledger_Entry_Amount; Amount)
            {
            }
            column(FA__Ledger_Entry__No__of_Depreciation_Days_; "No. of Depreciation Days")
            {
            }
        }
        modify("Fixed Asset")
        {
            trigger OnAfterAfterGetRecord()
            begin
                FillDeprText2andCustom1Text();
            end;
        }
        modify(ProjectedDepreciation)
        {
            trigger OnAfterAfterGetRecord()
            begin
                FillEntryAmounts1();
            end;
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Fixed Asset Projected Value GB localization';
            LayoutFile = './src/ReportExtensions/FixedAssetProjectedValue.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        DeprBook: Record "Depreciation Book";
        FALedgEntry2: Record "FA Ledger Entry";
        FADeprBook: Record "FA Depreciation Book";
        GroupAmounts: array[4] of Decimal;
        TotalBookValue: array[2] of Decimal;
        EntryAmounts_1: Decimal;
        CurrReport_PAGENO_Control73CaptionLbl: Label 'Page';
        DeprText: Text[50];
        DeprText2: Text[50];
        Custom1Text: Text[50];
        UntilDate: Date;

    procedure FillEntryAmounts1()
    begin
        FADeprBook.CalcFields("Book Value", "Custom 1");
        EntryAmounts_1 := FADeprBook."Book Value";
    end;

    procedure FillDeprText2andCustom1Text()
    begin
        DeprBook.Get(DeprBookCode);
        FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::Depreciation;
        DeprText := StrSubstNo('%1', FALedgEntry2."FA Posting Type");

        if DeprBook."Use Custom 1 Depreciation" then begin
            DeprText2 := DeprText;
            FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::"Custom 1";
            Custom1Text := StrSubstNo('%1', FALedgEntry2."FA Posting Type");
        end;
    end;

    procedure SetUntilDate(NewUntilDate: Date)
    begin
        UntilDate := NewUntilDate;
    end;

    procedure SetGroupAmounts(Group_Amounts: array[4] of Decimal)
    var
        i: Integer;
    begin
        for i := 1 to 4 do
            GroupAmounts[i] := Group_Amounts[i];
    end;

    procedure SetTotalBookValue(Total_BookValue: array[2] of Decimal)
    begin
        TotalBookValue[1] := Total_BookValue[1];
    end;
}
