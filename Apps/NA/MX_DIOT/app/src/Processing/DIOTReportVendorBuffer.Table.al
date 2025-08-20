// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 27033 "DIOT Report Vendor Buffer"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
#pragma warning disable AS0070
        field(2; "Type of Operation"; Enum "DIOT Type of Operation")
        {
            Caption = 'Type of Operation';
        }
#pragma warning restore AS0070
        field(3; "Type of Vendor Text"; Text[2])
        {
            Caption = 'Type of Vendor Text';
        }
        field(4; "Type of Operation Text"; Text[2])
        {
            Caption = 'Type of Operation Text';
        }
        field(5; "RFC Number"; Text[13])
        {
            Caption = 'RFC Number';
        }
        field(6; "TAX Registration ID"; Text[40])
        {
            Caption = 'TAX Registration ID';
        }
        field(7; "Vendor Name"; Text[250])
        {
            Caption = 'Vendor Name';
        }
#pragma warning disable AS0086
        field(8; "Country/Region Code"; Text[10])
        {
            Caption = 'Country/Region Code';
        }
#pragma warning restore AS0086
        field(9; Nationality; Text[250])
        {
            Caption = 'Nationality';
        }
        field(10; "Tax Effects Applied"; Boolean)
        {
            Caption = 'Tax Effects Applied';
        }
        field(11; "Tax Jurisdiction Location"; Text[300])
        {
            Caption = 'Tax Jurisdiction Location';
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Type of Operation")
        {
            Clustered = true;
        }
    }
}
