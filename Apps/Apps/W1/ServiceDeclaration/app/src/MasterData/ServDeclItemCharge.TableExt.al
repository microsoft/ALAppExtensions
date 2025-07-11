// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Service.Reports;

tableextension 5013 "Serv. Decl. Item Charge" extends "Item Charge"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";
        }
        field(5011; "Exclude From Service Decl."; Boolean)
        {
            Caption = 'Exclude From Service Declaration';
        }
    }
}
