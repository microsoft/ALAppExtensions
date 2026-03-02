// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 42801 "SL Hist. Chart of Accounts" extends "Chart of Accounts"
{
    actions
    {
        addlast("A&ccount")
        {
            group(SLHistorical)
            {
                Caption = 'SL Historical';
                Image = History;
                action("SL Hist. GL Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SL Historical G/L Entries';
                    Image = Transactions;
                    ToolTip = 'View the historical G/L entries for this account.';
                    RunObject = page "SL Hist. GLTran Entries";
                    RunPageLink = Acct = field("No.");
                    RunPageView = sorting(Acct, Module, BatNbr, LineNbr);
                    Visible = SLHistGLDetailDataAvailable;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SLHistGLTran: Record "SL Hist. GLTran Archive";
    begin
        if SLHistGLTran.ReadPermission() then
            SLHistGLDetailDataAvailable := not SLHistGLTran.IsEmpty();
    end;

    var
        SLHistGLDetailDataAvailable: Boolean;
}