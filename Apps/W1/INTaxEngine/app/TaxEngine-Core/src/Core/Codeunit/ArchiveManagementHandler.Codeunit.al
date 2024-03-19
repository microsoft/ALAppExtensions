// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.Core;

using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Utilities;

codeunit 20136 "Archive Management Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnAfterStorePurchLineArchive', '', false, false)]
    local procedure OnAfterStorePurchLineArchive(var PurchLine: Record "Purchase Line";
            var PurchHeaderArchive: Record "Purchase Header Archive";
            var PurchLineArchive: Record "Purchase Line Archive")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        // Prepares Transaction value based on Purchase Line Quantity
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            PurchLine.RecordId(),
            PurchLine.Quantity,
            PurchLineArchive.Quantity,
            PurchHeaderArchive."Currency Code",
            PurchHeaderArchive."Currency Factor",
            TempTaxTransactionValue);

        //Copies transaction value from unposted document to archive record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            PurchLine.RecordId(),
            PurchLineArchive.RecordId(),
            TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnAfterStoreSalesLineArchive', '', false, false)]
    local procedure OnAfterStoreSalesLineArchive(var SalesLine: Record "Sales Line"; var SalesHeaderArchive: Record "Sales Header Archive"; var SalesLineArchive: Record "Sales Line Archive")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        // Prepares Transaction value based on Sales Line Quantity
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            SalesLine.RecordId(),
            SalesLine.Quantity,
            SalesLineArchive.Quantity,
            SalesHeaderArchive."Currency Code",
            SalesHeaderArchive."Currency Factor",
            TempTaxTransactionValue);

        //Copies transaction value from unposted document to archive record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            SalesLine.RecordId(),
            SalesLineArchive.RecordId(),
            TempTaxTransactionValue);
    end;
}