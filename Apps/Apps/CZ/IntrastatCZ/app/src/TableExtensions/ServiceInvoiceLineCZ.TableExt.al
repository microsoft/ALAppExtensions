// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Service.History;

tableextension 31317 "Service Invoice Line CZ" extends "Service Invoice Line"
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