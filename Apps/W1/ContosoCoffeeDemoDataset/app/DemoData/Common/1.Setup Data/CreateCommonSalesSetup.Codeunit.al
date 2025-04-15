// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.Sales.Setup;

codeunit 5141 "Create Common Sales Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Sales & Receivables Setup" = rm;

    trigger OnRun()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        CommonNoSeries: Codeunit "Create Common No Series";
    begin
        SalesReceivablesSetup.Get();

        if SalesReceivablesSetup."Customer Nos." = '' then
            SalesReceivablesSetup.Validate("Customer Nos.", CommonNoSeries.Customer());

        if SalesReceivablesSetup."Order Nos." = '' then
            SalesReceivablesSetup.Validate("Order Nos.", CommonNoSeries.SalesOrder());

        if SalesReceivablesSetup."Invoice Nos." = '' then
            SalesReceivablesSetup.Validate("Invoice Nos.", CommonNoSeries.SalesInvoice());

        if SalesReceivablesSetup."Posted Invoice Nos." = '' then
            SalesReceivablesSetup.Validate("Posted Invoice Nos.", CommonNoSeries.PostedSalesInvoice());

        SalesReceivablesSetup.Modify();
    end;
}
