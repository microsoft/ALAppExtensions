// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Inventory.Location;

tableextension 31269 "Std. Item Journal Line CZA" extends "Standard Item Journal Line"
{
    fields
    {
        field(31050; "New Location Code CZA"; Code[10])
        {
            Caption = 'New Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Entry Type", "Entry Type"::Transfer);
            end;
        }
    }
}
