// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

pageextension 18156 "GST Sales Setup Ext" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast("general")
        {
            field("GST Dependency Type"; Rec."GST Dependency Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST calculation dependency mentioned in sales and receivable setup.';
            }
        }
    }
}
