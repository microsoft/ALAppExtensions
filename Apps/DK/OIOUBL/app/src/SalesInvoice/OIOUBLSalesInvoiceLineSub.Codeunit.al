// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 13661 "OIOUBL-Sales Invoice Line Sub."
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnAfterInitFromSalesLine', '', false, false)]
    procedure OnAfterCheckSalesDocCheckOIOUBL(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line");
    begin
        SalesInvLine."OIOUBL-Account Code" := SalesLine."OIOUBL-Account Code";
    end;
}
