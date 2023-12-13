// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1869 "C5 VatGroup"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Inventory,Customer,Vendor;
        }
        field(4; Group; Code[10])
        {
            Caption = 'VAT group';
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

