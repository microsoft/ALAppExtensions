// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

pageextension 18812 "Source Code Setup" extends "Source Code Setup"
{
    layout
    {
        addlast(General)
        {
            field("TDS Adjustment Journal"; Rec."TCS Adjustment Journal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for TCS Adjustment Journal.';
            }
        }
    }
}
