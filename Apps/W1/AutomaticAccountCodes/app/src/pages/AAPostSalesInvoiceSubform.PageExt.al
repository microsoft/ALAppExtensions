// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Sales.History;

pageextension 4858 "AA Post. Sales Invoice Subform" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {

            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the automatic account group on the sales invoice line which was posted.';
            }
        }
    }
}
