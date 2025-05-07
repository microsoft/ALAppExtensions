// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;
using Microsoft.DemoData.Foundation;

codeunit 17137 "Create NZ Sales Recv Setup"
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
        CreateNZNoSeries: Codeunit "Create NZ No. Series";
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("Posted Tax Invoice Nos.", CreateNZNoSeries.PostedSalesTaxInvoice());
        SalesReceivablesSetup.Validate("Posted Tax Credit Memo Nos", CreateNZNoSeries.PostedSalesTaxCreditMemo());
        SalesReceivablesSetup.Validate("Copy Line Descr. to G/L Entry", true);
        SalesReceivablesSetup.Modify(true);
    end;
}
