// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;

codeunit 11037 "E-Document Header Handler DE"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', false, false)]
    local procedure UpdateBuyerReferenceOnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader."Buyer Reference" := Customer."E-Invoice Routing No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', false, false)]
    local procedure UpdateBuyerReferenceOnAfterCopyBillToCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        ServiceHeader."Buyer Reference" := Customer."E-Invoice Routing No.";
    end;
}
