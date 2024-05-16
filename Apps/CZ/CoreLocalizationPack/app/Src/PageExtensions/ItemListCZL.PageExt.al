// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Inventory.Intrastat;
using Microsoft.Purchases.Reports;
using Microsoft.Sales.Reports;

pageextension 11769 "Item List CZL" extends "Item List"
{
    actions
    {
        addafter("Inventory - Sales Back Orders")
        {
            action("Quantity Shipped Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Shipped Check';
                Image = Report;
                RunObject = report "Quantity Shipped Check CZL";
                ToolTip = 'Verify that all sales shipments are fully invoiced. Report shows a list of sales shipment lines which are not fully invoiced.';
            }
            action("Quantity Received Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Received Check';
                Image = Report;
                RunObject = report "Quantity Received Check CZL";
                ToolTip = 'Verify that all purchase receipts are fully invoiced. Report shows a list of purchase receipt lines which are not fully invoiced.';
            }
        }
        addlast(Inventory)
        {
            action("Test Tariff Numbers CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Tariff Numbers';
                Image = TestReport;
                ToolTip = 'Run a test of item tariff numbers.';
                RunObject = report "Test Tariff Numbers CZL";
            }
        }
    }
}
