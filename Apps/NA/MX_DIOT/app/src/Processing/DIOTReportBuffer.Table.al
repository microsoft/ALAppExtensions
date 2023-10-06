// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 27032 "DIOT Report Buffer"
{
    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "Type of Operation"; Option)
        {
            Caption = 'Type of Operation';
            OptionMembers = " ","Prof. Services","Lease and Rent",Others;
            OptionCaption = ' ,Prof. Services,Lease and Rent,Others';
        }
        field(3; "DIOT Concept No."; Integer)
        {
            Caption = 'DIOT Concept No.';
        }
        field(4; Value; Decimal)
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Type of Operation", "DIOT Concept No.")
        {
            Clustered = true;
        }
    }
}
