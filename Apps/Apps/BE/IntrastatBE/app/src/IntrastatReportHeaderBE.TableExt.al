// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 11346 "Intrastat Report Header BE" extends "Intrastat Report Header"
{
    fields
    {
        field(11346; "Nihil Declaration"; Boolean)
        {
            Caption = 'Nihil Declaration';
        }
        field(11347; "Enterprise No./VAT Reg. No."; Text[30])
        {
            Caption = 'Enterprise No./VAT Reg. No.';
        }
    }
}