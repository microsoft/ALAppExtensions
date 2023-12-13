// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

table 11754 "Unrel. Payer Service Setup CZL"
{
    Caption = 'Unreliable Payer Service Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Enabled then
                    TestField("Unreliable Payer Web Service");
            end;
        }
        field(80; "Unreliable Payer Web Service"; Text[250])
        {
            Caption = 'Unreliable Payer Web Service URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(81; "Public Bank Acc.Chck.Star.Date"; Date)
        {
            Caption = 'Public Bank Account Check Starting Date';
            DataClassification = CustomerContent;
        }
        field(82; "Public Bank Acc.Check Limit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Public Bank Account Check Limit';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(85; "Unr.Payer Request Record Limit"; Integer)
        {
            BlankZero = true;
            Caption = 'Unreliable Payer Request Record Limit';
            InitValue = 99;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
