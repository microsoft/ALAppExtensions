// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

tableextension 18934 "Bank Account Ext" extends "Bank Account"
{
    fields
    {
        field(18929; "Stale Cheque Stipulated Period"; DateFormula)
        {
            Caption = 'Stale Cheque Stipulated Period';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                StipulatePeriod := Format("Stale Cheque Stipulated Period");
                if StrPos(StipulatePeriod, '-') <> 0 then
                    Error(StipulatedPeriodNegativeErr);
            end;
        }
        field(18930; "UPI ID"; Text[50])
        {
            Caption = 'UPI ID';
            DataClassification = CustomerContent;
        }
    }

    var
        StipulatePeriod: Text[30];
        StipulatedPeriodNegativeErr: Label 'Stale Cheque Stipulated Period can''t be negative.';
}
