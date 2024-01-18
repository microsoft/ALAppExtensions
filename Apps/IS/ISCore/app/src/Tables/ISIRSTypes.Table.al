
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.IRS;
table 14602 "IS IRS Types"
{
    Caption = 'IRS Types';
    LookupPageID = "IS IRS Types";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[4])
        {
            Caption = 'No.';
        }
        field(2; Type; Text[60])
        {
            Caption = 'Type';
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

