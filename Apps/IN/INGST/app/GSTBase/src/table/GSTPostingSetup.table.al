// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.TaxBase;

table 18007 "GST Posting Setup"
{
    Caption = 'GST Posting Setup';
    DataCaptionFields = "State Code";

    fields
    {
        field(1; "State Code"; Code[10])
        {
            Caption = 'State Code';
            NotBlank = true;
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(2; "Component ID"; Integer)
        {
            Caption = 'Component ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; "Receivable Account"; code[20])
        {
            Caption = 'Receivable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(4; "Payable Account"; Code[20])
        {
            Caption = 'Payable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(5; "Receivable Account (Interim)"; code[20])
        {
            Caption = 'Receivable Account (Interim)';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(6; "Payables Account (Interim)"; code[20])
        {
            Caption = 'Payables Account (Interim)';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(7; "Expense Account"; code[20])
        {
            Caption = 'Expense Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(9; "Refund Account"; code[20])
        {
            Caption = 'Refund Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(10; "Receivable Acc. Interim (Dist)"; code[20])
        {
            Caption = 'Receivable Acc. Interim (Dist)';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(11; "Receivable Acc. (Dist)"; code[20])
        {
            Caption = 'Receivable Acc. (Dist)';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(12; "GST Credit Mismatch Account"; code[20])
        {
            Caption = 'GST Credit Mismatch Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(13; "GST TDS Receivable Account"; code[20])
        {
            Caption = 'GST TDS Receivable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(14; "GST TCS Receivable Account"; code[20])
        {
            Caption = 'GST TCS Receivable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(15; "GST TCS Payable Account"; code[20])
        {
            Caption = 'GST TCS Payable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(16; "IGST Payable A/c (Import)"; code[20])
        {
            Caption = 'IGST Payable A/c (Import)';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(false), "Account Type" = filter(Posting));
        }
        field(17; "GST TDS Payable Account"; code[20])
        {
            Caption = 'GST TDS Payable Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
    }

    keys
    {
        key(PK; "State Code", "Component ID")
        {
            Clustered = true;
        }
    }
}
