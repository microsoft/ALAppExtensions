// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Inventory.Transfer;

codeunit 18393 "Validate Transfer Price"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('OnAfterTransferPrirce', Database::"Transfer Line", 'After Update Transfer Price');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Transfer Price', false, false)]
    local procedure HandleServiceLineUseCase(var Rec: Record "Transfer Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterApplied(var TaxRecordID: RecordID; LineNoFilter: Integer; DocumentNoFilter: Text; TableIDFilter: Integer)
    var
        TransferLine: Record "Transfer Line";
    begin
        if TableIDFilter = Database::"Transfer Line" then begin
            TransferLine.Reset();
            TransferLine.SetRange("Document No.", DocumentNoFilter);
            TransferLine.SetRange("Line No.", LineNoFilter);
            if TransferLine.FindFirst() then
                TaxRecordID := TransferLine.RecordId();
        end;
    end;
}
