// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.AuditCodes;

pageextension 31271 "Source Code Setup CZC" extends "Source Code Setup"
{
    layout
    {
        addlast(Sales)
        {
            field("Compensation CZC"; Rec."Compensation CZC")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for posted entries from compensation.';
            }
        }
    }
}
