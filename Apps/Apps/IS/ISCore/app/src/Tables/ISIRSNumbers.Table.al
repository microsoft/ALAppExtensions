
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.IRS;

table 14601 "IS IRS Numbers"
{
    Caption = 'IRS Numbers';
    LookupPageID = "IS IRS Numbers";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "IRS Number"; Code[10])
        {
            Caption = 'IRS Number';
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(3; "Reverse Prefix"; Boolean)
        {
            Caption = 'Reverse Prefix';
        }
        field(13; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
        }
    }

    keys
    {
        key(Key1; "IRS Number")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "IRS Number", Name)
        {
        }
    }
}

