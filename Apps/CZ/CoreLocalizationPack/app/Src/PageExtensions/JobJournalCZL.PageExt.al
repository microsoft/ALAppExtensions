// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

pageextension 11714 "Job Journal CZL" extends "Job Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
            }
        }
        addafter("Transport Method")
        {
            field("Transaction Specification CZL"; Rec."Transaction Specification")
            {
                ApplicationArea = Jobs;
                ToolTip = 'Specifies a code for the transaction specification, for the purpose of reporting to INTRASTAT.';
                Visible = false;
            }
        }
    }
}
