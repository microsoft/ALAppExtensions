// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Document;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 11493 "Create GB Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, SI102201Lbl);
        ContosoSales.InsertSalesLineWithGLAccount(SalesHeader, CreateGBGLAccounts.SaleOfResources(), 1, 970);
    end;

    var
        SI102201Lbl: Label '102201', MaxLength = 20;
}
