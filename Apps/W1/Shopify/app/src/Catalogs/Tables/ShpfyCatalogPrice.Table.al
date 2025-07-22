// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Catalog Price (ID 30153).
/// </summary>
table 30153 "Shpfy Catalog Price"
{
    Caption = 'Shopify Catalog Price';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Variant Id"; BigInteger)
        {
            Caption = 'Variant Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Price List Id"; BigInteger)
        {
            Caption = 'Price List Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Shop";
        }
        field(4; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Price List Currency";
        }
        field(5; "Compare at Price"; Decimal)
        {
            Caption = 'Compare at Price';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Price List Currency";
        }
        field(6; "Price List Currency"; Code[3])
        {
            Caption = 'Price List Currency';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Variant Id", "Price List Id")
        {
            Clustered = true;
        }
    }
}
