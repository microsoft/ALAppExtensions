// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;

reportextension 10585 "Finance Charge Memo" extends "Finance Charge Memo"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/FinanceChargeMemo.rdlc';
#endif
    dataset
    {
        add(Integer)
        {
            column(CompanyInfoBankBranchNo_; CompanyInfo."Bank Branch No.")
            {
            }
            column(VATRegCaptionNo; "Issued Fin. Charge Memo Header".GetCustomerVATRegistrationNumberLbl())
            {
            }
            column(DocDate_Caption; DocDateCaptionLbl)
            {
            }
            column(Email_Caption; EmailCaptionLbl)
            {
            }
            column(HomePage_Caption; HomePageCaptionLbl)
            {
            }
            column(BankBranchCaptionNo; BankBranchNoCaptionLbl)
            {
            }
            column(CustNo_IssuedFinChrgMemoHeader_Caption; "Issued Fin. Charge Memo Header".FieldCaption("Customer No."))
            {
            }
        }
        add("Issued Fin. Charge Memo Line")
        {
            column(MultInterestRatesEntry__IssuedFinChrgMemoLine; "Issued Fin. Charge Memo Line"."Detailed Interest Rates Entry")
            {
            }
            column(DueDate__IssuedFinChrgMemoLine; "Issued Fin. Charge Memo Line"."Due Date")
            {
            }
            column(No__IssuedFinChrgMemoLine; "Issued Fin. Charge Memo Line"."No.")
            {
            }
            column(VatAmount__IssuedFinChrgMemoLine; "Issued Fin. Charge Memo Line"."VAT Amount")
            {
            }
            column(Total_RemainingAmount; TotalRemainingAmount)
            {
            }
            column(Add_FeeInclVAT; AddFeeInclVAT)
            {
            }
            column(VAT_Interest; VATInterest)
            {
            }
            column(AddFee__IssuedFinChrgMemoHeader; "Issued Fin. Charge Memo Header"."Additional Fee")
            {
            }
            column(AmtVATAmt__IssuedFinChrgMemoHeader; "Issued Fin. Charge Memo Line".Amount + "Issued Fin. Charge Memo Line"."VAT Amount")
            {
                AutoFormatExpression = "Issued Fin. Charge Memo Line".GetCurrencyCode();
                AutoFormatType = 1;
            }
        }
        modify("Issued Fin. Charge Memo Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                GLAcc: Record "G/L Account";
                CustPostingGroup: Record "Customer Posting Group";
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                CalcFields("Additional Fee");
                CustPostingGroup.Get("Customer Posting Group");
                if GLAcc.Get(CustPostingGroup."Additional Fee Account") then begin
                    VATPostingSetup.Get("VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group");
                    AddFeeInclVAT := "Additional Fee" * (1 + VATPostingSetup."VAT %" / 100);
                end else
                    AddFeeInclVAT := "Additional Fee";

                GLAcc.Get(CustPostingGroup."Interest Account");
                VATPostingSetup.Get("VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group");
                VATInterest := VATPostingSetup."VAT %";
            end;
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Finance Charge Memo GB localization';
            LayoutFile = './src/ReportExtensions/FinanceChargeMemo.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
        DocDateCaptionLbl: Label 'Document Date';
        EmailCaptionLbl: Label 'E-Mail';
        HomePageCaptionLbl: Label 'Home Page';
        TotalRemainingAmount: Decimal;
        AddFeeInclVAT: Decimal;
        VATInterest: Decimal;

    trigger OnPreReport()
    begin
        GLSetup.Get();
        SalesSetup.Get();
        case SalesSetup."Logo Position on Documents" of
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                begin
                    CompanyInfo3.Get();
                    CompanyInfo3.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Center:
                begin
                    CompanyInfo1.Get();
                    CompanyInfo1.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Right:
                begin
                    CompanyInfo2.Get();
                    CompanyInfo2.CalcFields(Picture);
                end;
        end;
    end;
}
