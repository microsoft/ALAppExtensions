// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 31264 "VAT Return Period List CZL" extends "VAT Return Period List"
{
    actions
    {
        addafter("Create VAT Return")
        {
            action("Create Periods")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Create Periods';
                Ellipsis = true;
                Image = Period;
                RunObject = report "Create VAT Return Period CZL";
                ToolTip = 'This batch job automatically creates VAT periods.';
#if not CLEAN28
                Visible = IsReplaceVATPeriodEnabled;
#endif
            }
        }
    }
#if not CLEAN28
    trigger OnOpenPage()
    begin
        IsReplaceVATPeriodEnabled := ReplaceVATPeriodMgtCZL.IsEnabled();
    end;
#endif

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CheckVATReportDueDateCZL();
    end;
#if not CLEAN28
    var
        ReplaceVATPeriodMgtCZL: Codeunit "Replace VAT Period Mgt. CZL";
        IsReplaceVATPeriodEnabled: Boolean;
#endif
}