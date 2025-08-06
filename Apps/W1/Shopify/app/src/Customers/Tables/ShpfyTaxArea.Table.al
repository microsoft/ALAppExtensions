// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Setup;

/// <summary>
/// Table Shpfy Tax Area (ID 30109).
/// </summary>
table 30109 "Shpfy Tax Area"
{
    Access = Internal;
    Caption = 'Shopify Tax Area';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Country/Region Code"; Code[20])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(2; County; Text[50])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(3; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(4; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(5; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(6; "County Code"; Code[10])
        {
            Caption = 'County Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Country/Region Code", County)
        {
            Clustered = true;
        }
        key(Indx01; "Country/Region Code", "County Code") { }
    }
}