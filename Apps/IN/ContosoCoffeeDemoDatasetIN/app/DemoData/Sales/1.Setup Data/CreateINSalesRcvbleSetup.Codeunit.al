// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Setup;
using Microsoft.Finance.GST.Base;

codeunit 19033 "Create IN Sales Rcvble Setup"
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

        SalesReceivablesSetup.Validate("GST Dependency Type", Enum::"GST Dependency Type"::"Bill-to Address");
        SalesReceivablesSetup.Modify(true);
    end;
}
