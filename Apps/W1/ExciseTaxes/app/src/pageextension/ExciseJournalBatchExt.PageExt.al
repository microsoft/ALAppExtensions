// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.Sustainability.ExciseTax;

pageextension 7413 "Excise Journal Batch Ext" extends "Sust. Excise Jnl. Batches"
{
    layout
    {
        addafter(Description)
        {
            field("Excise Tax Type Filter"; Rec."Excise Tax Type Filter")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the excise tax type filter for this batch. Only journal lines with this tax type will be allowed.';
            }
        }
    }
}
