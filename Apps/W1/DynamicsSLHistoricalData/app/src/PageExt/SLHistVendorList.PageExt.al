// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;
using Microsoft.Purchases.Vendor;


pageextension 42804 "SL Hist. Vendor List" extends "Vendor List"
{
    actions
    {
        addlast("Ven&dor")
        {
            group(SLHistorical)
            {
                Caption = 'SL Historical';
                Image = History;
                action("SL Hist. AP Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SL Historical Accounts Payable Transactions';
                    Image = Transactions;
                    ToolTip = 'View the historical AP transactions for this vendor.';
                    RunObject = page "SL Hist. APTran Entries";
                    RunPageLink = VendId = field("No.");
                    RunPageView = sorting(VendId, BatNbr, Acct, Sub, RefNbr);
                    Visible = SLHistAPTranDataAvailable;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SLHistAPTran: Record "SL Hist. APTran Archive";
    begin
        if SLHistAPTran.ReadPermission() then
            SLHistAPTranDataAvailable := not SLHistAPTran.IsEmpty();
    end;

    var
        SLHistAPTranDataAvailable: Boolean;

}