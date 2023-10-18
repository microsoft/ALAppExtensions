// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

tableextension 31307 "Purch. Inv. Line CZ" extends "Purch. Inv. Line"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No. CZL"));
        }
    }
}