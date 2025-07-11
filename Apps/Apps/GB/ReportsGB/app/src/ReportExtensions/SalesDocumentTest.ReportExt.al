// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reports;

using Microsoft.Sales.Setup;
using Microsoft.Finance.VAT.Setup;

reportextension 10581 "Sales Document - Test" extends "Sales Document - Test"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/SalesDocumentTestGB.rdlc';
#endif
    dataset
    {
        add(PageCounter)
        {
            column(Sales_Header___VAT_Base_Discount; "Sales Header"."VAT Base Discount %")
            {
            }
            column(PaymentDiscount; PaymentDiscountDisplay)
            {
            }
            column(DiscountTextCaption; PaymentDiscountText)
            {
            }
            column(SalesHeader__VAT_Base_Discount___Control1040003; "Sales Header"."VAT Base Discount %")
            {
            }
            column(SalesHeader__VAT_Base_Discount___Control1040005; "Sales Header"."VAT Base Discount %")
            {
            }
            column(SalesHeader__VAT_Base_Discount__Caption; SalesHeader__VAT_Base_Discount__CaptionLbl)
            {
            }
            column(SalesHeader__VAT_Base_Discount___Control1040003Caption; SalesHeader__VAT_Base_Discount___Control1040003CaptionLbl)
            {
            }
            column(SalesHeader__VAT_Base_Discount___Control1040005Caption; SalesHeader__VAT_Base_Discount___Control1040005CaptionLbl)
            {
            }
        }
        add(RoundLoop)
        {
            column(SalesLine__Reverse_Charge; "Sales Line"."Reverse Charge GB")
            {
            }
            column(SalesSetup__Invoice_Wording; SalesReceivablesSetup."Invoice Wording GB")
            {
            }
            column(SalesLine__ReverseCharge__Control10410094; "Sales Line"."Reverse Charge GB")
            {
            }
            column(TotalReverseChargeVAT; TotalReverseChargeVAT)
            {
            }
            column(ReverseChargeCaption; ReverseChargeCaptionLbl)
            {
            }
            column(ReverseChargeCaption_Control1040093; ReverseChargeCaption_Control1040093Lbl)
            {
            }
        }
        modify(RoundLoop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                TotalReverseChargeVAT := TotalReverseChargeVAT + "Sales Line"."Reverse Charge GB";
            end;

            trigger OnAfterPreDataItem()
            begin
                TotalReverseChargeVAT := 0;
            end;
        }
        modify("Sales Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                ReverseChargeVATProcedures: Codeunit "Reverse Charge VAT Procedures";
            begin
                if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
                    "Sales Header".SetReverseChargeApplies(ReverseChargeVATProcedures.CheckIfReverseChargeApplies("Sales Header"));
                PaymentDiscountDisplay := "Payment Discount %" <> 0;
                PaymentDiscountText := StrSubstNo(PaymentDiscountLbl, "Payment Discount %", "Pmt. Discount Date");
            end;
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Purchase Document Test GB localization';
            LayoutFile = './src/ReportExtensions/SalesDocumentTestGB.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    trigger OnPreReport()
    begin
        SalesReceivablesSetup.Get();
    end;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TotalReverseChargeVAT: Decimal;
        ReverseChargeCaptionLbl: Label 'Reverse Charge';
        ReverseChargeCaption_Control1040093Lbl: Label 'Reverse Charge';
        SalesHeader__VAT_Base_Discount__CaptionLbl: Label 'VAT Base Discount %';
        SalesHeader__VAT_Base_Discount___Control1040003CaptionLbl: Label 'VAT Base Discount %';
        SalesHeader__VAT_Base_Discount___Control1040005CaptionLbl: Label 'VAT Base Discount %';
        PaymentDiscountText: Text[500];
        PaymentDiscountDisplay: Boolean;
        PaymentDiscountLbl: Label 'A discount of %1% of the full price applies if payment is made on or before %2. No credit memo will be issued after you have made the payment. Therefore, you must make sure that you only recover the VAT actually paid.', Comment = '%1 = payment discount, %2 = payment discount date';
}