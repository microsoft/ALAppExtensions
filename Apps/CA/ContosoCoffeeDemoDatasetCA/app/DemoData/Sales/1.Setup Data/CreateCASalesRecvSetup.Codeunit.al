// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;

codeunit 27062 "Create CA Sales Recv. Setup"
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
    begin
        SalesReceivablesSetup.Get();

        SalesReceivablesSetup.Validate("Allow VAT Difference", true);
        SalesReceivablesSetup.Modify(true);
    end;
}
