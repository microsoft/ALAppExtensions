// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;
using Microsoft.DemoData.Foundation;

codeunit 17130 "Create AU Sales Recv Setup"
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
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("Invoice Nos.", CreateNoSeries.PostedSalesInvoice());
        SalesReceivablesSetup.Validate("Credit Memo Nos.", CreateNoSeries.PostedSalesCreditMemo());
        SalesReceivablesSetup.Validate("Copy Line Descr. to G/L Entry", true);
        SalesReceivablesSetup.Modify(true);
    end;
}
