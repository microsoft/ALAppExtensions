// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Sales.Customer;

pageextension 42802 "SL Hist. Customer List" extends "Customer List"
{
    actions
    {
        addlast("&Customer")
        {
            group(SLHistorical)
            {
                Caption = 'SL Historical';
                Image = History;
                action("SL Hist. AR Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SL Historical Accounts Receivable Transactions';
                    Image = Transactions;
                    ToolTip = 'View the historical AR transactions for this customer.';
                    RunObject = page "SL Hist. ARTran Entries";
                    RunPageLink = CustId = field("No.");
                    RunPageView = sorting(CustId, TranType, RefNbr);
                    Visible = SLHistARTranDataAvailable;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SLHistARTran: Record "SL Hist. ARTran Archive";
    begin
        if SLHistARTran.ReadPermission() then
            SLHistARTranDataAvailable := not SLHistARTran.IsEmpty();
    end;

    var
        SLHistARTranDataAvailable: Boolean;
}