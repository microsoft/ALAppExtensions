// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.CashFlow.Setup;
using System.Environment.Configuration;
using Microsoft.CashFlow.Forecast;
using System.Environment;

codeunit 5686 "Run CashFlow Forecast Wizard"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CashFlowSetup: Record "Cash Flow Setup";
        GuidedExperience: Codeunit "Guided Experience";
        CashFlowManagement: Codeunit "Cash Flow Management";
        LogInManagement: Codeunit LogInManagement;
        TaxPaymentWindow: DateFormula;
        TaxablePeriod: Option Monthly,Quarterly,"Accounting Period",Yearly;
    begin
        // Imitate that the user has run the Cash Flow Forecasting Setup wizard
        WorkDate := LogInManagement.GetDefaultWorkDate();

        CashFlowManagement.SetupCashFlow(CopyStr(CashFlowManagement.GetCashAccountFilter(), 1, 250));

        CashFlowSetup.UpdateTaxPaymentInfo(TaxablePeriod::Quarterly, TaxPaymentWindow, CashFlowSetup."Tax Bal. Account Type"::" ", '');

        CashFlowSetup.Get();
        CashFlowSetup.Validate("Automatic Update Frequency", CashFlowSetup."Automatic Update Frequency"::Weekly);
        CashFlowSetup.Modify();

        CashFlowManagement.UpdateCashFlowForecast(false);

        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Cash Flow Forecast Wizard");
    end;
}
