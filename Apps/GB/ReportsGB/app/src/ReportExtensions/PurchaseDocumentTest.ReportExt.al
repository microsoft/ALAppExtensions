// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.Reports;

reportextension 10580 "Purchase Document - Test" extends "Purchase Document - Test"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/PurchaseDocumentTestGB.rdlc';
#endif
    dataset
    {
        add(PageCounter)
        {
            column(Purchase_Header___VAT_Base_Discount___Control1040000; "Purchase Header"."VAT Base Discount %")
            {
            }
            column(Purchase_Header___VAT_Base_Discount___Control1040002; "Purchase Header"."VAT Base Discount %")
            {
            }
            column(Purchase_Header___VAT_Base_Discount___Control1040004; "Purchase Header"."VAT Base Discount %")
            {
            }
            column(Purchase_Header___VAT_Base_Discount___Control1040000Caption; Purchase_Header___VAT_Base_Discount___Control1040000CaptionLbl)
            {
            }
            column(Purchase_Header___VAT_Base_Discount___Control1040002Caption; Purchase_Header___VAT_Base_Discount___Control1040002CaptionLbl)
            {
            }
            column(Purchase_Header___VAT_Base_Discount___Control1040004Caption; Purchase_Header___VAT_Base_Discount___Control1040004CaptionLbl)
            {
            }
        }
        add(RoundLoop)
        {
            column(TotalReverseChargeVAT; "Purchase Header".GetTotalReverseCharge())
            {
                AutoFormatExpression = "Purchase Header"."Currency Code";
                AutoFormatType = 1;
            }
            column(ReverseChargeCaption_Control1040006; ReverseChargeCaption_Control1040006Lbl)
            {
            }
        }
        modify("Purchase Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                "Purchase Header".SetReverseCharge(0);
                "Purchase Header".SetTotalReverseCharge(0);
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
            LayoutFile = './src/ReportExtensions/PurchaseDocumentTestGB.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        ReverseChargeCaption_Control1040006Lbl: Label 'Reverse Charge';
        Purchase_Header___VAT_Base_Discount___Control1040000CaptionLbl: Label 'VAT Base Discount %';
        Purchase_Header___VAT_Base_Discount___Control1040002CaptionLbl: Label 'VAT Base Discount %';
        Purchase_Header___VAT_Base_Discount___Control1040004CaptionLbl: Label 'VAT Base Discount %';
}