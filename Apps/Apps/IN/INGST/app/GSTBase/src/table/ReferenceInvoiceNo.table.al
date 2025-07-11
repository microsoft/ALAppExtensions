// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

table 18011 "Reference Invoice No."
{
    Caption = 'Reference Invoice No.';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(2; "Document Type"; Enum "Document Type Enum")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(4; "Reference Invoice Nos."; Code[20])
        {
            Caption = 'Reference Invoice Nos.';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Source Type"; Enum "Party Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(8; Verified; Boolean)
        {
            Caption = 'Verified';
            DataClassification = CustomerContent;
        }
        field(9; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(10; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Document Type", "Source No.", "Reference Invoice Nos.", "Journal Template Name", "Journal Batch Name")
        {
            Clustered = true;
        }
    }
}
