// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Vat.Ledger;

report 31123 "VAT Exceptions CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VATExceptions.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Exceptions';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
#if not CLEAN22
#pragma warning disable AL0432
            RequestFilterFields = "VAT Date CZL";
#pragma warning restore AL0432
#else
            RequestFilterFields = "VAT Reporting Date";
#endif
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(Filter1_VatEntry; TableCaption() + ': ' + VATEntryFilter)
            {
            }
            column(MinVatDifference; MinVATDifferenceReq)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
            }
            column(MinVatDiffText; MinVATDiffText)
            {
            }
            column(AddCurrAmt_VatEntry; AddCurrAmtTxt)
            {
            }
            column(PostingDate_VatEntry; Format("VAT Reporting Date"))
            {
            }
            column(DocumentType_VatEntry; "Document Type")
            {
            }
            column(DocumentNo_VatEntry; "Document No.")
            {
                IncludeCaption = true;
            }
            column(Type_VatEntry; Type)
            {
                IncludeCaption = true;
            }
            column(GenBusPostGrp_VatEntry; "Gen. Bus. Posting Group")
            {
            }
            column(GenProdPostGrp_VatEntry; "Gen. Prod. Posting Group")
            {
            }
            column(Base_VatEntry; Base)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
                IncludeCaption = true;
            }
            column(Amount_VatEntry; Amount)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
                IncludeCaption = true;
            }
            column(VatCalType_VatEntry; "VAT Calculation Type")
            {
            }
            column(BillToPay_VatEntry; "Bill-to/Pay-to No.")
            {
                IncludeCaption = true;
            }
            column(Eu3PartyTrade_VatEntry; Format("EU 3-Party Trade"))
            {
            }
            column(FormatClosed; Format(Closed))
            {
            }
            column(EntrtyNo_VatEntry; "Entry No.")
            {
                IncludeCaption = true;
            }
            column(VatDiff_VatEntry; "VAT Difference")
            {
                IncludeCaption = true;
            }
            column(VATExceptionsCaption; VATExceptionsCaptionLbl)
            {
            }
            column(CurrReportPageNoOCaption; CurrReportPageNoOCaptionLbl)
            {
            }
            column(FORMATEU3PartyTradeCap; FORMATEU3PartyTradeCapLbl)
            {
            }
            column(FORMATClosedCaption; FORMATClosedCaptionLbl)
            {
            }
            column(VATEntryVATCalcTypeCap; VATEntryVATCalcTypeCapLbl)
            {
            }
            column(GenProdPostingGrpCaption; GenProdPostingGrpCaptionLbl)
            {
            }
            column(GenBusPostingGrpCaption; GenBusPostingGrpCaptionLbl)
            {
            }
            column(DocumentTypeCaption; DocumentTypeCaptionLbl)
            {
            }
            column(PostingDateCaption; PostingDateCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not PrintReversedEntries then
                    if Reversed then
                        CurrReport.Skip();
                if UseAmtsInAddCurr then begin
                    Base := "Additional-Currency Base";
                    Amount := "Additional-Currency Amount";
                    "VAT Difference" := "Add.-Curr. VAT Difference";
                end;
#if not CLEAN22
#pragma warning disable AL0432
                if not IsReplaceVATDateEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
            end;

            trigger OnPreDataItem()
            begin
                if UseAmtsInAddCurr then
                    SetFilter("Add.-Curr. VAT Difference", '<=%1|>=%2', -Abs(MinVATDifferenceReq), Abs(MinVATDifferenceReq))
                else
                    SetFilter("VAT Difference", '<=%1|>=%2', -Abs(MinVATDifferenceReq), Abs(MinVATDifferenceReq));
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
                    field(AmountsInAddReportingCurrency; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if the reported amounts are shown in the additional reporting currency.';
                    }
                    field(IncludeReversedEntries; PrintReversedEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Reversed Entries';
                        ToolTip = 'Specifies if you want to include reversed entries in the report.';
                    }
                    field(MinVATDifference; MinVATDifferenceReq)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = GetCurrency();
                        AutoFormatType = 1;
                        Caption = 'Min. VAT Difference';
                        ToolTip = 'Specifies the minimum VAT difference that you want to include in the report.';

                        trigger OnValidate()
                        begin
                            MinVATDifferenceReq := Abs(Round(MinVATDifferenceReq));
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        VATEntryFilter := "VAT Entry".GetFilters();
        if UseAmtsInAddCurr then
            AddCurrAmtTxt := StrSubstNo(AmountsShownLbl, GeneralLedgerSetup."Additional Reporting Currency");
        MinVATDiffText := StrSubstNo(ShowEqualOrGreaterLbl, "VAT Entry".FieldCaption("VAT Difference"));
#if not CLEAN22
#pragma warning disable AL0432
        if "VAT Entry".IsReplaceVATDateEnabled() then begin
            "VAT Entry".CopyFilter("VAT Date CZL", "VAT Entry"."VAT Reporting Date");
            "VAT Entry".SetRange("VAT Date CZL");
        end;
#pragma warning restore AL0432
#endif
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AmountsShownLbl: Label 'Amounts are shown in %1.', Comment = '%1 = general ledger setup additional reporting currency';
        ShowEqualOrGreaterLbl: Label 'Show %1 equal to or greater than', Comment = '%1 = fieldcaption of "VAT Difference"';
        VATEntryFilter: Text;
        UseAmtsInAddCurr: Boolean;
        AddCurrAmtTxt: Text[50];
        MinVATDifferenceReq: Decimal;
        MinVATDiffText: Text[250];
        PrintReversedEntries: Boolean;
        VATExceptionsCaptionLbl: Label 'VAT Exceptions';
        CurrReportPageNoOCaptionLbl: Label 'Page';
        FORMATEU3PartyTradeCapLbl: Label 'EU 3-Party Trade';
        FORMATClosedCaptionLbl: Label 'Closed';
        VATEntryVATCalcTypeCapLbl: Label 'VAT Calculation Type';
        GenProdPostingGrpCaptionLbl: Label 'Gen. Prod. Posting Group';
        GenBusPostingGrpCaptionLbl: Label 'Gen. Bus. Posting Group';
        DocumentTypeCaptionLbl: Label 'Document Type';
        PostingDateCaptionLbl: Label 'VAT Date';

    local procedure GetCurrency(): Code[10]
    begin
        if UseAmtsInAddCurr then
            exit(GeneralLedgerSetup."Additional Reporting Currency");

        exit('');
    end;

    procedure InitializeRequest(NewUseAmtsInAddCurr: Boolean; NewPrintReversedEntries: Boolean; NewMinVATDifference: Decimal)
    begin
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        PrintReversedEntries := NewPrintReversedEntries;
        MinVATDifferenceReq := Abs(Round(NewMinVATDifference));
    end;
}

