// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Transfer;

tableextension 31323 "Direct Trans. Line CZ" extends "Direct Trans. Line"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No. CZL"));
        }
    }
}