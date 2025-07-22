// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Order Attribute (ID 30116).
/// </summary>
table 30116 "Shpfy Order Attribute"
{
    Caption = 'Shopify Order Attributes';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = CustomerContent;
        }
        field(2; "Key"; Text[100])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
#if not CLEANSCHEMA27
        field(3; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Replaced with Attribute Value';
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
        }
#endif
        field(4; "Attribute Value"; Text[2048])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Order Id", "Key")
        {
            Clustered = true;
        }
    }

}