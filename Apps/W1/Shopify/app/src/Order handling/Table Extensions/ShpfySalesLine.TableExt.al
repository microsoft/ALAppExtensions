// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

/// <summary>
/// TableExtension Shpfy Sales Line (ID 30104) extends Record Sales Line.
/// </summary>
tableextension 30104 "Shpfy Sales Line" extends "Sales Line"
{
    fields
    {
        field(30100; "Shpfy Order Line Id"; BigInteger)
        {
            Caption = 'Shopify Order Line Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(30101; "Shpfy Order No."; Code[50])
        {
            Caption = 'Shopify Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30103; "Shpfy Refund Id"; BigInteger)
        {
            Caption = 'Shopify Refund Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(30104; "Shpfy Refund Line Id"; BigInteger)
        {
            Caption = 'Shopify Refund Line Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30105; "Shpfy Refund Shipping Line Id"; BigInteger)
        {
            Caption = 'Shopify Refund Shipping Line Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

