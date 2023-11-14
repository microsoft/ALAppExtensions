// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.RoleCenters;

pageextension 31290 "Administrator RC CZB" extends "Administrator Main Role Center"
{
    actions
    {
        addafter("Bank Export/Import Setup")
        {
            action("Search Rules CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Search Rules';
                RunObject = page "Search Rule List CZB";
                ToolTip = 'View or edit search rules.';
            }
        }
    }
}
