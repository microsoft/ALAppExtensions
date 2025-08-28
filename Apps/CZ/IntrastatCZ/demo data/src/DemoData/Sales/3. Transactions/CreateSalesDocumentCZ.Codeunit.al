// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoTool.Helpers;
using Microsoft.Sales.Document;
using Microsoft.DemoData.Inventory;

codeunit 11709 "Create Sales Document CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateOpenSalesDocuments();
    end;

    local procedure CreateOpenSalesDocuments()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateCustomer: Codeunit "Create Customer";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateItem: Codeunit "Create Item";
        CreateSalesDocument: Codeunit "Create Sales Document";
        CreateLocation: Codeunit "Create Location";
    begin
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19030704D), ContosoUtilities.AdjustDate(19030704D), '', CreateLocation.MainLocation(), ContosoUtilities.AdjustDate(19030704D), '', '', ContosoUtilities.AdjustDate(19030704D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 5);
    end;
}