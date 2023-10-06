// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 31344 "Intrastat Report CZ" extends "Intrastat Report"
{
    layout
    {
        addlast(General)
        {
            field("Statement Type CZ"; Rec."Statement Type CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statement type of the Intrastat Report.';

                trigger OnValidate()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
}