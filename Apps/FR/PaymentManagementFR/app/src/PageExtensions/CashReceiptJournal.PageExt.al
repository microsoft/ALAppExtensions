// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Bank.Payment;

pageextension 10836 "Cash Receipt Journal" extends "Cash Receipt Journal"
{
    actions
    {
#if not CLEAN28
#pragma warning disable AL0432
        modify(PrintCheckRemittanceReport)
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Insert Conv. LCY Rndg. Lines")
        {
            separator(Action1120000FR)
            {
            }
            action(PrintCheckRemittanceReportFR)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print Check Remittance Report';
                Image = PrintCheck;
                ToolTip = 'View a list of checks remitted to the bank. The header shows the names and addresses of the company and bank. The body shows the list of checks. The footer shows the total of the remittance and the number of checks. Typically, you give this report to your bank with the checks at remittance.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
                trigger OnAction()
                var
                    RecapitulationForm: Report "Recapitulation Form FR";
                begin
                    RecapitulationForm.SetTableView(Rec);
                    RecapitulationForm.RunModal();
                    Clear(RecapitulationForm);
                end;
            }
        }
    }

#if not CLEAN28
    trigger OnOpenPage()
    var
        PaymentFeatureFR: Codeunit "Payment Management Feature FR";
    begin
        FeatureEnabled := PaymentFeatureFR.IsEnabled();
    end;

    var
        FeatureEnabled: Boolean;
#endif
}