// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 18931 "Gen.Jnl Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        modify("Document No.")
        {
            trigger OnAfterValidate()
            begin
                TestField("Check Printed", false);
            end;
        }
        field(18929; "Narration Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18930; "Cheque Date"; Date)
        {
            Caption = 'Cheque Date';
            DataClassification = CustomerContent;
        }
        field(18931; "Cheque No."; Code[10])
        {
            Caption = 'Cheque No.';
            DataClassification = CustomerContent;
        }
        field(18932; "Stale Cheque"; Boolean)
        {
            Caption = 'Stale Cheque';
            DataClassification = CustomerContent;
        }
    }
}
