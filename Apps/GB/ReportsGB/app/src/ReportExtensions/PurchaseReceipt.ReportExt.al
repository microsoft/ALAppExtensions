// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

reportextension 10588 "Purchase - Receipt" extends "Purchase - Receipt"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/PurchaseReceipt.rdlc';
#endif
    dataset
    {
        add(CopyLoop)
        {
            column(PaytoVenNo__PurchRcptHeader; "Purch. Rcpt. Header"."Pay-to Vendor No.")
            {
            }
            column(CompanyInfo_BankBranchNo; CompanyInfo."Bank Branch No.")
            {
            }
            column(BankBranchNo_Caption; BankBranchNoCaptionLbl)
            {
            }
            column(DocDate_Caption; DocDateCaptionLbl)
            {
            }
            column(Email_Caption; EmailCaptionLbl)
            {
            }
            column(PaytoVendNo__PurchRcptHeaderCaption; "Purch. Rcpt. Header".FieldCaption("Pay-to Vendor No."))
            {
            }
        }
        add("Purch. Rcpt. Line")
        {
            column(Show_CorrectionLines; ShowCorrectionLines)
            {
            }
            column(Log_Interaction; LogInteraction)
            {
            }
            column(Type__PurchRcptLine; Format("Purch. Rcpt. Line".Type, 0, 2))
            {
            }
            column(Qty_Caption; QtyCaptionLbl)
            {
            }
            column(UOM_CodeCaption; FieldCaption("Unit of Measure"))
            {
            }
            column(Desc_Caption; DescCaptionLbl)
            {
            }
            column(LineNo__PurchRcptLine; "Line No.")
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
            Caption = 'Purchase Receipt GB localization';
            LayoutFile = './src/ReportExtensions/PurchaseReceipt.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
        QtyCaptionLbl: Label 'Quantity';
        DescCaptionLbl: Label 'Description';
        DocDateCaptionLbl: Label 'Document Date';
        EmailCaptionLbl: Label 'Email';
        LogInteraction: Boolean;
        ShowCorrectionLines: Boolean;

    procedure SetLogInteraction(NewLogInteraction: Boolean)
    begin
        LogInteraction := NewLogInteraction;
    end;

    procedure SetShowCorrectionLines(NewShowCorrectionLines: Boolean)
    begin
        ShowCorrectionLines := NewShowCorrectionLines;
    end;
}
