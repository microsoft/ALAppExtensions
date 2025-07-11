// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

table 18282 "GST Recon. Mapping"
{
    Caption = 'GST Recon. Mapping';

    fields
    {
        field(1; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(2; "GST Reconciliation Field No."; Integer)
        {
            Caption = 'GST Reconciliation Field No.';
            DataClassification = CustomerContent;
        }
        field(3; "GST Reconciliation Field Name"; Text[30])
        {
            Caption = 'GST Reconciliation Field Name';
            DataClassification = CustomerContent;
        }
        field(4; "ISD Ledger Field No."; Integer)
        {
            Caption = 'ISD Ledger Field No.';
            DataClassification = CustomerContent;
        }
        field(5; "ISD Ledger Field Name"; Text[30])
        {
            Caption = 'ISD Ledger Field Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "GST Component Code", "GST Reconciliation Field No.")
        {
            Clustered = true;
        }
    }
}
