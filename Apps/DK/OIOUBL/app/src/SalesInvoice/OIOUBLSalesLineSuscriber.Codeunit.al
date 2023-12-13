// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Document;

codeunit 13662 "OIOUBL-Sales Line Suscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignHeaderValues', '', false, false)]
    procedure OnAfterCheckSalesDocCheckOIOUBL(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header");
    begin
        SalesLine."OIOUBL-Account Code" := SalesHeader."OIOUBL-Account Code";
    end;
}
