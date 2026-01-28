// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;

table 11722 "VAT Report Entry Link CZL"
{
    Caption = 'VAT Report Entry Link';

    fields
    {
        field(1; "VAT Report No."; Code[20])
        {
            Caption = 'VAT Report No.';
            TableRelation = "VAT Report Header";
            DataClassification = CustomerContent;
        }
        field(2; "VAT Entry No."; Integer)
        {
            Caption = 'VAT Entry No.';
            TableRelation = "VAT Entry"."Entry No.";
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "VAT Report No.", "VAT Entry No.")
        {
            Clustered = true;
        }
    }
}
