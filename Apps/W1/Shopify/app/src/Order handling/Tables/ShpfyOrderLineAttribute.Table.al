// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Order Line Attribute (ID 30123).
/// </summary>
table 30149 "Shpfy Order Line Attribute"
{
    Caption = 'Shopify Order Attributes';
    DataClassification = SystemMetadata;
    DrillDownPageID = "Shpfy Order Lines Attributes";
    LookupPageID = "Shpfy Order Lines Attributes";
    Extensible = false;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetaData;
        }
        field(2; "Order Line Id"; Guid)
        {
            Caption = 'Line Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Key"; Text[100])
        {
            Caption = 'Key';
            DataClassification = SystemMetaData;
        }
        field(4; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = SystemMetaData;
        }
    }
    keys
    {
        key(PK; "Order Id", "Order Line Id", "Key")
        {
            Clustered = true;
        }
    }
}