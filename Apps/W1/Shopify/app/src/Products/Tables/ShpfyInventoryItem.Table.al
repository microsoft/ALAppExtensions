// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Inventory Item (ID 30126).
/// </summary>
table 30126 "Shpfy Inventory Item"
{
    Access = Internal;
    Caption = 'Shopify Inventory Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Variant Id"; BigInteger)
        {
            Caption = 'Variant Id';
            DataClassification = CustomerContent;
        }
        field(3; "Country/Region of Origin"; Text[50])
        {
            Caption = 'Country/Region of Origin';
            DataClassification = CustomerContent;
        }
        field(4; "Create At"; DateTime)
        {
            Caption = 'Create At';
            DataClassification = CustomerContent;
        }
        field(5; "History URL"; Text[250])
        {
            Caption = 'History URL';
            DataClassification = CustomerContent;
        }
        field(6; "Province of Origin"; Text[50])
        {
            Caption = 'Province of Origin';
            DataClassification = CustomerContent;
        }
        field(7; "Requires Shipping"; Boolean)
        {
            Caption = 'Requires Shipping';
            DataClassification = CustomerContent;
        }
        field(8; Tracked; Boolean)
        {
            Caption = 'Tracked';
            DataClassification = CustomerContent;
        }
        field(9; "Tracked Editable"; Boolean)
        {
            Caption = 'Tracked Editable';
            DataClassification = CustomerContent;
        }
        field(10; "Tracked Reason"; Text[100])
        {
            Caption = 'Tracked Reason';
            DataClassification = CustomerContent;
        }
        field(11; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            AutoFormatExpression = '';
        }
        field(12; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}