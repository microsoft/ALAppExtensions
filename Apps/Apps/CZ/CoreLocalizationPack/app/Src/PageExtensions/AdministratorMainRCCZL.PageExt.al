// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.RoleCenters;

using Microsoft.Finance;

pageextension 31161 "Administrator Main RC CZL" extends "Administrator Main Role Center"
{
    actions
    {
        addlast(Group27)
        {
            action(EETServiceSetupCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'EET Service Setup';
                RunObject = page "EET Service Setup CZL";
                ToolTip = 'Open the EET Service Setup page.';
            }
        }
    }
}
