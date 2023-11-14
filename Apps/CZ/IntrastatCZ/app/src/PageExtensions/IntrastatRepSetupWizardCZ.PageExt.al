// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 31376 "Intrastat Rep. Setup Wizard CZ" extends "Intrastat Report Setup Wizard"
{
    layout
    {
        addafter("Default Trans. Type - Returns")
        {
            field("Def. Phys. Trans. - Returns CZ"; Rec."Def. Phys. Trans. - Returns CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default value of the Physical Movement field for sales returns and service returns, and purchase returns.';
            }
        }
    }
}