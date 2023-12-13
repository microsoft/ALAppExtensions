// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Sales.History;
using Microsoft.Service.History;

codeunit 148120 "VAT Amount Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnAfterCopyFromSalesInvLine', '', false, false)]
    local procedure VATClauseCodeOnAfterCopyFromSalesInvLine(var VATAmountLine: Record "VAT Amount Line"; SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        VATAmountLine."VAT Clause Code" := SalesInvoiceLine."VAT Clause Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnAfterCopyFromSalesCrMemoLine', '', false, false)]
    local procedure VATClauseCodeOnAfterCopyFromSalesCrMemoLine(var VATAmountLine: Record "VAT Amount Line"; SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        VATAmountLine."VAT Clause Code" := SalesCrMemoLine."VAT Clause Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnAfterCopyFromServInvLine', '', false, false)]
    local procedure VATClauseCodeOnAfterCopyFromServInvLine(var VATAmountLine: Record "VAT Amount Line"; ServiceInvoiceLine: Record "Service Invoice Line")
    begin
        VATAmountLine."VAT Clause Code" := ServiceInvoiceLine."VAT Clause Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnAfterCopyFromServCrMemoLine', '', false, false)]
    local procedure VATClauseCodeOnAfterCopyFromServCrMemoLine(var VATAmountLine: Record "VAT Amount Line"; ServiceCrMemoLine: Record "Service Cr.Memo Line")
    begin
        VATAmountLine."VAT Clause Code" := ServiceCrMemoLine."VAT Clause Code";
    end;
}
