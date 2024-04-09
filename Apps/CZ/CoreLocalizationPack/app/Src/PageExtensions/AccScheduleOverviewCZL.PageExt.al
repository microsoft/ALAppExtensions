// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

pageextension 11798 "Acc. Schedule Overview CZL" extends "Acc. Schedule Overview"
{
    actions
    {
        addlast(processing)
        {
            group("Results Group CZL")
            {
                Caption = 'Results';
                action("Save Results CZL")
                {
                    ApplicationArea = Suite;
                    Caption = 'Save Results';
                    Ellipsis = true;
                    Image = Save;
                    ToolTip = 'Opens window for saving results of account schedule';

                    trigger OnAction()
                    var
                        AccSchedExtensionMgtCZL: Codeunit "Acc. Sched. Extension Mgt. CZL";
                    begin
                        AccSchedExtensionMgtCZL.CreateResults(Rec, CurrentColumnName, false);
                    end;
                }
                action("Results CZL")
                {
                    ApplicationArea = Suite;
                    Caption = 'Results';
                    Image = ViewDetails;
                    RunObject = page "Acc. Sched. Res. Hdr. List CZL";
                    RunPageLink = "Acc. Schedule Name" = field("Schedule Name");
                    ToolTip = 'Opens account schedule result header list';
                }
            }
        }
    }
}
