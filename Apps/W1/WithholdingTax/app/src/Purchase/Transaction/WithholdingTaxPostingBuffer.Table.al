// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

table 6791 "Withholding Tax Posting Buffer"
{
    Caption = 'Withholding Tax Posting Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Tax Invoice No."; Code[20])
        {
            Caption = 'Tax Invoice No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Invoice No."; Text[30])
        {
            Caption = 'Invoice No.';
            DataClassification = SystemMetadata;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Purchase Invoice,Sales Invoice,Purchase Credit Memo,Sales Credit Memo';
            OptionMembers = "Purchase Invoice","Sales Invoice","Purchase Credit Memo","Sales Credit Memo";
        }
    }

    keys
    {
        key(Key1; "Tax Invoice No.", Type)
        {
            Clustered = true;
        }
    }
}