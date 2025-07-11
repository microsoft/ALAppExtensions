// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Ledger;

tableextension 18932 "Bank Acc Led Entry Ext" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(18929; "Cheque No."; Code[10])
        {
            Caption = 'Cheque No.';
            DataClassification = CustomerContent;
        }
        field(18930; "Cheque Date"; Date)
        {
            Caption = 'Cheque Date';
            DataClassification = CustomerContent;
        }
        field(18931; "Stale Cheque"; Boolean)
        {
            Caption = 'Stale Cheque';
            DataClassification = CustomerContent;
        }
        field(18932; "Stale Cheque Expiry Date"; Date)
        {
            Caption = 'Stale Cheque Expiry Date';
            DataClassification = CustomerContent;
        }
        field(18933; "Cheque Stale Date"; Date)
        {
            Caption = 'Cheque Stale Date';
            DataClassification = CustomerContent;
        }
    }
}
