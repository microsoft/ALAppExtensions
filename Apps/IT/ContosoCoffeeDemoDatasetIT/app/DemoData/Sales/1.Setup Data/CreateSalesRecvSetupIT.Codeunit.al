// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;
using Microsoft.DemoData.Foundation;

codeunit 12211 "Create Sales Recv. Setup IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSalesReceivablesSetup();
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
    begin
        SalesReceivablesSetup.Get();

        Evaluate(SalesReceivablesSetup."Bank Receipts Risk Period", '<20D>');
        SalesReceivablesSetup.Validate("Bank Receipts Risk Period");
        SalesReceivablesSetup.Validate("Temporary Bill List No.", CreateNoSeriesIT.TemporaryCustBillListNo());
        SalesReceivablesSetup.Validate("Recall Bill Description", RecallBillLbl);
        SalesReceivablesSetup.Validate("Fattura PA Nos.", CreateNoSeriesIT.FatturaPA());
        SalesReceivablesSetup.Validate("Prevent Posted Doc. Deletion", true);
        SalesReceivablesSetup.Validate("Fattura PA Electronic Format", FatturapaLbl);

        SalesReceivablesSetup.Modify(true);
    end;

    var
        RecallBillLbl: Label 'Recall Bill', MaxLength = 50, Locked = true;
        FatturapaLbl: Label 'FATTURAPA', MaxLength = 20, Locked = true;
}
