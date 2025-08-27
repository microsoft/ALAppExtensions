// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using Microsoft.Sales.Setup;
using Microsoft.Finance.GeneralLedger.Setup;

reportextension 10584 Reminder extends Reminder
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/Reminder.rdlc';
#endif
    dataset
    {
        add("Issued Reminder Header")
        {
            column(Show_MIRLines; ShowMIRLines)
            {
            }
            column(CompanyInfo_BankBranchNo; CompanyInfo."Bank Branch No.")
            {
            }
            column(VAT_RegNoCaption; "Issued Reminder Header".GetCustomerVATRegistrationNumberLbl())
            {
            }
            column(Email_Caption; EmailCaptionLbl)
            {
            }
            column(HomePage_Caption; HomePageCaptionLbl)
            {
            }
            column(BankBranch_NoCaption; BankBranchNoCaptionLbl)
            {
            }
        }
        add("Issued Reminder Line")
        {
            column(VAT_AmtIssRemHdrAddFeeInclVAT; (TotalRemIntAmount + "VAT Amount" + "Issued Reminder Header"."Additional Fee" - AddFeeInclVAT) / (VATInterest / 100 + 1))
            {
                AutoFormatExpression = "Issued Reminder Line".GetCurrencyCodeFromHeader();
                AutoFormatType = 1;
            }
            column(Total_RemIntAmount; TotalRemIntAmount)
            {
            }
            column(VAT_AmountCaption; VATAmountCaptionLbl)
            {
            }
        }
        add(VATCounter)
        {
            column(VAT_AmountCaption1; VATAmountCaption1Lbl)
            {
            }
            column(VAT_BaseCaption; VATBaseCaptionLbl)
            {
            }
            column(VAT_PercentCaption; VATPercentCaptionLbl)
            {
            }
            column(VAT_AmountSpecificationCaption; VATAmountSpecificationCaptionLbl)
            {
            }
            column(Total_Caption; TotalCaptionLbl)
            {
            }
        }
        add(VATCounterLCY)
        {
            column(VAT_AmountCaption2; VATAmountCaption2Lbl)
            {
            }
            column(VAT_Base1Caption; VATBase1CaptionLbl)
            {
            }
            column(VAT_PercentCaption1; VATPercentCaption1Lbl)
            {
            }
        }
        add(LetterText)
        {
            column(Total_Caption1; TotalCaption1Lbl)
            {
            }
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Reminder GB localization';
            LayoutFile = './src/ReportExtensions/Reminder.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        AddFeeInclVAT: Decimal;
        VATInterest: Decimal;
        TotalRemIntAmount: Decimal;
        HomePageCaptionLbl: Label 'Home Page';
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATAmountCaption2Lbl: Label 'VAT Amount';
        VATBase1CaptionLbl: Label 'VAT Base';
        VATPercentCaption1Lbl: Label 'VAT %';
        TotalCaption1Lbl: Label 'Total';
        EmailCaptionLbl: Label 'E-Mail';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATPercentCaptionLbl: Label 'VAT %';
        TotalCaptionLbl: Label 'Total';
        VATAmountCaption1Lbl: Label 'VAT Amount';

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

    procedure SetVATInterest(NewVATInterest: Decimal)
    begin
        VATInterest := NewVATInterest;
    end;

    procedure SetAddFeeInclVAT(NewAddFeeInclVAT: Decimal)
    begin
        AddFeeInclVAT := NewAddFeeInclVAT;
    end;
}
