// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Address;

table 5025 "Service Declaration Buffer"
{
    TableType = Temporary;
    fields
    {
        field(1; "Service Transaction Code"; Code[20])
        {
            Caption = 'Service Transaction Code';
            TableRelation = "Service Transaction Type";
        }
        field(2; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(11; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
        }
    }

    keys
    {
        key(Key1; "Service Transaction Code", "Country/Region Code", "Currency Code")
        {
            Clustered = true;
        }
    }
}

