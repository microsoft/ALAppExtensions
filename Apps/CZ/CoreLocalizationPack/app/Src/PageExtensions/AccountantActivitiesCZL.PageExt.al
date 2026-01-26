// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.VAT.Reporting;

pageextension 31263 "Accountant Activities CZL" extends "Accountant Activities"
{
    layout
    {
        addlast(Financials)
        {
            field("Opened VAT Reports"; Rec."Opened VAT Reports")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "VAT Report List";
                ToolTip = 'Specifies the number of opened VAT reports.';
            }
        }
    }
}