// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.IRS;
table 14600 "IS IRS Groups"
{
    Caption = 'IRS Groups';
    LookupPageID = "IS IRS Groups";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[2])
        {
            Caption = 'No.';
        }
        field(2; Class; Text[60])
        {
            Caption = 'Class';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

