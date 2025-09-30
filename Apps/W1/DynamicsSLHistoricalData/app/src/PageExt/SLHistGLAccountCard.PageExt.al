// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 42800 "SL Hist. G/L Account Card" extends "G/L Account Card"
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
                    Image = History;
                    ToolTip = 'View the historical G/L entries for this account.';
                    RunObject = page "SL Hist. GLTran Entries";
                    RunPageLink = Acct = field("No.");
                    RunPageView = sorting(Module, BatNbr, LineNbr);
                    Visible = SLHistGLDetatilDataAvailable;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SLHistGLTran: Record "SL Hist. GLTran Archive";
    begin
        if SLHistGLTran.ReadPermission() then
            SLHistGLDetatilDataAvailable := not SLHistGLTran.IsEmpty();
    end;

    var
        SLHistGLDetatilDataAvailable: Boolean;
}