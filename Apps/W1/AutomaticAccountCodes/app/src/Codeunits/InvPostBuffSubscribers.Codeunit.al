#if not CLEAN23
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 4852 "Inv. Post. Buff. Subscribers"
{
    Access = Internal;
    ObsoleteReason = 'The Invoice Post. Buffer table will be replaced by table Invoice Posting Buffer in new Invoice Posting implementation.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareSales', '', false, false)]
    local procedure OnAfterInvPostBufferPrepareSales(var SalesLine: Record "Sales Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."Additional Grouping Identifier" += SalesLine."Automatic Account Group";
        InvoicePostBuffer."Automatic Account Group" := SalesLine."Automatic Account Group";

    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure OnAfterInvPostBufferPreparePurchase(var PurchaseLine: Record "Purchase Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."Automatic Account Group" := PurchaseLine."Automatic Account Group";
        InvoicePostBuffer."Additional Grouping Identifier" += PurchaseLine."Automatic Account Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");
    begin
        GenJnlLine."Automatic Account Group" := InvoicePostBuffer."Automatic Account Group";
    end;
}
#endif