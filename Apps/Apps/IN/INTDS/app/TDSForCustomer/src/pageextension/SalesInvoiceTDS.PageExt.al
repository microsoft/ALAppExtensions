// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 18666 "Sales Invoice TDS" extends "Sales Invoice"
{
    layout
    {
        addlast("Tax Info")
        {
            field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Selected to allow calculating TDS for the customer.';
            }
        }
    }
}
