// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;

tableextension 6796 "Withholding Purch Setup Ext" extends "Purchases & Payables Setup"
{
    fields
    {
        field(6784; "Wthldg. Tax Certificate Nos."; Code[20])
        {
            Caption = 'Withholding Tax Certificate Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(6785; "WHT Print Dialog"; Boolean)
        {
            Caption = 'Print Dialog';
            DataClassification = CustomerContent;
        }
        field(6786; "Print Wthldg. Tax Docs PayPost"; Boolean)
        {
            Caption = 'Print Withholding Docs. on Pay. Post';
            DataClassification = CustomerContent;
        }
        field(6787; "Print Wthldg. Tax Docs Cr.Memo"; Boolean)
        {
            Caption = 'Print Withholding Docs. on Credit Memo';
            DataClassification = CustomerContent;
        }
        field(6788; "WHT Posted Tax Invoice Nos."; Code[20])
        {
            Caption = 'Posted Tax Invoice Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(6789; "WHT Posted Tax Credit Memo Nos"; Code[20])
        {
            Caption = 'Posted Tax Credit Memo Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(6790; "WHT Posted Non Tax Inv. Nos."; Code[20])
        {
            Caption = 'Posted Non Tax Invoice Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(6791; "WHT Pstd. Non Tax Cr. Memo Nos"; Code[20])
        {
            Caption = 'Posted Non Tax Credit Memo Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(6792; "WHT Enable Vend. GST Amt.(ACY)"; Boolean)
        {
            Caption = 'Enable Vendor GST Amount (ACY)';
            DataClassification = CustomerContent;
        }
        field(6793; "WHT Post Dated Check Template"; Code[10])
        {
            Caption = 'Post Dated Check Template';
            TableRelation = "Gen. Journal Template";
            DataClassification = CustomerContent;
        }
        field(6794; "WHT Post Dated Check Batch"; Code[10])
        {
            Caption = 'Post Dated Check Batch';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("WHT Post Dated Check Template"),
                                                             "Bal. Account Type" = const("Bank Account"));
        }
        field(6795; "WHT Default Cancel Reason Code"; Code[10])
        {
            Caption = 'Default Cancel Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
    }
}