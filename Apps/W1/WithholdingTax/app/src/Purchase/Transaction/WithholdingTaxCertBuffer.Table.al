// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

table 6789 "Withholding Tax Cert. Buffer"
{
    Caption = 'Withholding Tax Certificate Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Document No.")
        {
        }
    }
}