// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

table 30144 "Shpfy FulFillment Order Line"
{
    Caption = 'FulFillment Order Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Fulfillment Order Id"; BigInteger)
        {
            Caption = 'Shopify Fulfillment Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Fulfillm. Ord. Line Id"; BigInteger)
        {
            Caption = 'Shopify FulfillmentLine Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Shopify Location Id"; BigInteger)
        {
            Caption = 'Shopify Location Id';
            DataClassification = SystemMetadata;
        }
        field(4; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
        }
        field(5; "Shopify Product Id"; BigInteger)
        {
            Caption = 'Shopify Product Id';
            DataClassification = SystemMetadata;
        }
        field(6; "Total Quantity"; Integer)
        {
            Caption = 'Total Quantity';
            DataClassification = CustomerContent;
        }
        field(7; "Remaining Quantity"; Integer)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
        }
        field(8; "Quantity to Fulfill"; Decimal)
        {
            Caption = 'Qty. to Fulfill';
            DataClassification = CustomerContent;
            AutoFormatType = 0;
        }
        field(9; "Shopify Variant Id"; BigInteger)
        {
            Caption = 'Shopify Variant Id';
            DataClassification = SystemMetadata;
        }
        field(10; "Delivery Method Type"; Enum "Shpfy Delivery Method Type")
        {
            Caption = 'Delivery Method Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Fulfillment Status"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Shopify Fulfillment Order Id", "Shopify Fulfillm. Ord. Line Id")
        {
            Clustered = true;
        }
    }
}