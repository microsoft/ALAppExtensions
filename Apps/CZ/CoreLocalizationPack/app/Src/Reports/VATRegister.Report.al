// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;


report 31122 "VAT Register CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VATRegister.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Register';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(GLSetupLCYCode; GeneralLedgerSetup."LCY Code")
            {
            }
            column(GLSetupAddReportCurr; GeneralLedgerSetup."Additional Reporting Currency")
            {
            }
            column(AllamountsareIn; AllamountsareInLbl)
            {
            }
            column(GLRegFilter_GLRegister; TableCaption + ': ' + GLRegFilter)
            {
            }
            column(GLRegFilter; GLRegFilter)
            {
            }
            column(No_GLRegister; "No.")
            {
            }
            column(VATRegisterCaption; VATRegisterCaptionLbl)
            {
            }
            column(PageNoCaption; PageNoCaptionLbl)
            {
            }
            column(PostingDateCaption; PostingDateCaptionLbl)
            {
            }
            column(DocumentTypeCaption; DocumentTypeCaptionLbl)
            {
            }
            column(GenBusPostingGroupCaption; GenBusPostingGroupCaptionLbl)
            {
            }
            column(GenProdPostingGroupCaption; GenProdPostingGroupCaptionLbl)
            {
            }
            column(VATCalculationTypeCaption; VATCalculationTypeCaptionLbl)
            {
            }
            column(EU3PartyTradeCaption; EU3PartyTradeCaptionLbl)
            {
            }
            column(VATEntryClosedCaption; CaptionClassTranslate("VAT Entry".FieldCaption(Closed)))
            {
            }
            column(GLRegisterNoCaption; GLRegisterNoCaptionLbl)
            {
            }
            dataitem("VAT Entry"; "VAT Entry")
            {
                DataItemTableView = sorting("Entry No.");
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
                column(GenBusPostGroup_VatEntry; "Gen. Bus. Posting Group")
                {
                }
                column(GenPostGroup_VatEntry; "Gen. Prod. Posting Group")
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
                column(Closed_VatEntry; Format(Closed))
                {
                }
                column(ClosedEntryNo_VatEntry; "Closed by Entry No.")
                {
                    IncludeCaption = true;
                }
                column(EntryNo_VatEntry; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(AdditionalCurr_VatEntry; UseAmtsInAddCurrReq)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if UseAmtsInAddCurrReq then begin
                        Base := "Additional-Currency Base";
                        Amount := "Additional-Currency Amount";
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
                    SetRange("Entry No.", "G/L Register"."From VAT Entry No.", "G/L Register"."To VAT Entry No.");
                end;
            }

            trigger OnPreDataItem()
            begin
                GeneralLedgerSetup.Get();
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
                    field(UseAmtsInAddCurr; UseAmtsInAddCurrReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if the reported amounts are shown in the additional reporting currency.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        GLRegFilter := "G/L Register".GetFilters;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLRegFilter: Text;
        UseAmtsInAddCurrReq: Boolean;
        AllamountsareInLbl: Label 'All amounts are in';
        VATRegisterCaptionLbl: Label 'VAT Register';
        PageNoCaptionLbl: Label 'Page';
        PostingDateCaptionLbl: Label 'VAT Date';
        DocumentTypeCaptionLbl: Label 'Document Type';
        GenBusPostingGroupCaptionLbl: Label 'Gen. Bus. Posting Group';
        GenProdPostingGroupCaptionLbl: Label 'Gen. Prod. Posting Group';
        VATCalculationTypeCaptionLbl: Label 'VAT Calculation Type';
        EU3PartyTradeCaptionLbl: Label 'EU 3-Party Trade';
        GLRegisterNoCaptionLbl: Label 'Register No.';

    local procedure GetCurrency(): Code[10]
    begin
        if UseAmtsInAddCurrReq then
            exit(GeneralLedgerSetup."Additional Reporting Currency");

        exit('');
    end;

    procedure InitializeRequest(NewUseAmtsInAddCurr: Boolean)
    begin
        UseAmtsInAddCurrReq := NewUseAmtsInAddCurr;
    end;
}

