// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;

tableextension 31347 "Fixed Asset CZ" extends "Fixed Asset"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No."));
        }
        field(31305; "Specific Movement CZ"; Code[10])
        {
            Caption = 'Specific Movement';
            DataClassification = CustomerContent;
            TableRelation = "Specific Movement CZ".Code;
        }
    }
}