#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.Finance.RoleCenters;

pageextension 10800 "Finance Manager Role Center" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("List1")
        {
            action("FA Projected Value (Derogatory) FR")
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Projected Value (Derogatory)';
                RunObject = report "FA-Proj. Value (Derogatory) FR";
                Tooltip = 'Run the FA-Projected Value (Derogatory) FR report.';
            }
            action("Professional Tax FR")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Professional Tax';
                RunObject = report "Fixed Asset-Professional TaxFR";
                Tooltip = 'Run the Fixed Asset-Professional Tax FR report.';
            }
        }
    }
}
#endif