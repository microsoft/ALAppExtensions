// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Foundation.AuditCodes;

pageextension 6795 WithholdingSourceCodeSetup extends "Source Code Setup"
{
    layout
    {
        addafter("VAT Settlement")
        {
            field("Withholding Tax Settlement"; Rec."Withholding Tax Settlement")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that another source code is added for Withholding Tax settlement transactions.';
            }
        }
    }
}