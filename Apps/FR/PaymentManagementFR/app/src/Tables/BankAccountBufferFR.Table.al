// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

table 10831 "Bank Account Buffer FR"
{
    Caption = 'Bank Account Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(2; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
        }
        field(3; "Agency Code"; Text[20])
        {
            Caption = 'Agency Code';
        }
        field(4; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Bank Branch No.", "Agency Code", "Bank Account No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

