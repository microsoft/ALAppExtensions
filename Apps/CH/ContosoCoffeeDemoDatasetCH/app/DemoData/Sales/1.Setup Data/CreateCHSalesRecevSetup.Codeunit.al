// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;

codeunit 11614 "Create CH Sales Recev. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSalesReceivableSetup();
    end;

    local procedure UpdateSalesReceivableSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup.Validate("Shipment on Invoice", true);
            SalesReceivablesSetup.Modify(true);
        end;
    end;
}
