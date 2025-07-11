// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

using Microsoft.Service.Reports;

tableextension 5021 "Serv. Decl. Value Entry" extends "Value Entry"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            TableRelation = "Service Transaction Type";
            Caption = 'Service Transaction Type Code';

        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
        }
    }
}
