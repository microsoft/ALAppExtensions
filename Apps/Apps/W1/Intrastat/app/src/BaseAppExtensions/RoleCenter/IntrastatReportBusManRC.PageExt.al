// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.RoleCenters;

pageextension 4816 "Intrastat Report Bus.Man. RC" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action39)
        {
            action(IntrastatReports)
            {
                ApplicationArea = All;
                Caption = 'Intrastat Reports';
                RunObject = Page "Intrastat Report List";
                Image = ListPage;
                ToolTip = 'Summarize the value of your purchases and sales with business partners in the EU for statistical purposes and prepare to send it to the relevant authority.';
            }
        }
    }
}