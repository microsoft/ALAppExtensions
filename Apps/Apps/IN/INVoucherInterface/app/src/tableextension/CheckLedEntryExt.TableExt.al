// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Check;

tableextension 18935 "Check Led Entry Ext" extends "Check Ledger Entry"
{
    fields
    {
        field(18929; "Stale Cheque"; Boolean)
        {
            Caption = 'Stale Cheque';
            DataClassification = CustomerContent;
        }
        field(18930; "Stale Cheque Expiry Date"; Date)
        {
            Caption = 'Stale Cheque Expiry Date';
            DataClassification = CustomerContent;
        }
        field(18931; "Cheque Stale Date"; Date)
        {
            Caption = 'Cheque Stale Date';
            DataClassification = CustomerContent;
        }
    }
}
