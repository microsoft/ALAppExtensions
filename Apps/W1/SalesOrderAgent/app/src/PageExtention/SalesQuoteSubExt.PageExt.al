// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;

pageextension 4409 "Sales Quote Sub. Ext" extends "Sales Quote Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Shipment Date"; Rec."Shipment Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date when the item should be shipped from the warehouse.';
                Visible = false;
            }
        }
    }
}