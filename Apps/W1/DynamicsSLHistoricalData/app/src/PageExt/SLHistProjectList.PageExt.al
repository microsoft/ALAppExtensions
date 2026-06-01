// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Projects.Project.Job;

pageextension 42806 "SL Hist. Project List" extends "Job List"
{
    actions
    {
        addlast("&Job")
        {
            group(SLHistorical)
            {
                Caption = 'SL Historical';
                Image = History;
                action("SL Hist. Project Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SL Historical Project Transactions';
                    Image = Transactions;
                    ToolTip = 'View the historical project transactions for this project.';
                    RunObject = page "SL Hist. PJTran Entries";
                    RunPageLink = project = field("No.");
                    visible = SLHistPJTranDataAvailable;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SLHistPJTran: Record "SL Hist. PJTran";
    begin
        if SLHistPJTran.ReadPermission() then
            SLHistPJTranDataAvailable := not SLHistPJTran.IsEmpty();
    end;

    var
        SLHistPJTranDataAvailable: Boolean;
}