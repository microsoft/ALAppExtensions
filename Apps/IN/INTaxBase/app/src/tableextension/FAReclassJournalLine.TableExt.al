// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Journal;

using Microsoft.Inventory.Location;

tableextension 18580 "FA Reclass. Journal Line" extends "FA Reclass. Journal Line"
{
    fields
    {
        field(18580; "From Location Code"; Code[10])
        {
            Caption = 'From Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(18581; "To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
    }
}