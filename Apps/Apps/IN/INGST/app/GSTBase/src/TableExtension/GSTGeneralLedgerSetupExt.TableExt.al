// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.NoSeries;

tableextension 18003 "GST General Ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(18000; "GST Distribution Nos."; code[20])
        {
            caption = 'GST Distribution Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(18001; "GST Credit Adj. Jnl Nos."; code[20])
        {
            Caption = 'GST Credit Adj. Jnl Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(18002; "GST Settlement Nos."; code[20])
        {
            Caption = 'GST Settlement Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(18003; "GST Recon. Tolerance"; Decimal)
        {
            Caption = 'GST Recon. Tolerance';
            DataClassification = CustomerContent;
        }
        field(18009; "State Code - Kerala"; Code[10])
        {
            Caption = 'State Code - Kerala';
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(18010; "Custom Duty Component Code"; Text[30])
        {
            Caption = 'Custom Duty Component Code';
            DataClassification = CustomerContent;
        }
        field(18011; "GST Opening Account"; Code[20])
        {
            Caption = 'GST Opening Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(False), "Account Type" = filter(Posting));
        }
        field(18012; "Sub-Con Interim Account"; Code[20])
        {
            Caption = 'Sub-Con Interim Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(False), "Account Type" = filter(Posting));
        }
        field(18013; "Generate E-Inv. on Sales Post"; Boolean)
        {
            Caption = 'Generate E-Inv. on Sales Post';
            DataClassification = CustomerContent;
        }
    }
}
