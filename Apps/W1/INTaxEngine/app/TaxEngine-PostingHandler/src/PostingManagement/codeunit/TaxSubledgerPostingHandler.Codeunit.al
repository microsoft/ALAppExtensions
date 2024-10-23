// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxEngine.Core;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

codeunit 20347 "Tax Subledger Posting Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnPostCustOnBeforeInitCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.SetSalesPurchLcy(GenJournalLine."Sales/Purch. (LCY)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLineSales(var TotalSalesLineLCY: Record "Sales Line")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.SetSalesPurchLcy(-TotalSalesLineLCY.Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLinePurchase(var TotalPurchLineLCY: Record "Purchase Line")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.SetSalesPurchLcy(-TotalPurchLineLCY.Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnAfterPrepareTaxTransaction', '', false, false)]
    local procedure OnAfterPrepareTaxTransaction(
        var TaxPostingBuffer: Record "Transaction Posting Buffer";
        var TempSymbols: Record "Script Symbol Value" Temporary)
    var
        UseCase: Record "Tax Use Case";
        RecID: RecordId;
        NewCaseID: Guid;
        GroupingType: Option "Component","Line / Component";
        Record: Variant;
    begin
        if TaxPostingBuffer.FindSet() then
            repeat
                RecID := TaxPostingBuffer."Tax Record ID";
                if GetPostingUseCaseID(
                    TaxPostingBuffer."Case ID",
                    TaxPostingBuffer."Component ID",
                    GroupingType::"Line / Component", NewCaseID)
                then begin
                    UseCase.Get(NewCaseID);
                    Record := RecID;
                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"Gen. Bus. Posting Group".AsInteger(),
                        TaxPostingBuffer."Gen. Bus. Posting Group",
                        "Symbol Data Type"::STRING);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"Gen. Prod. Posting Group".AsInteger(),
                        TaxPostingBuffer."Gen. Prod. Posting Group",
                        "Symbol Data Type"::STRING);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"Dimension Set ID".AsInteger(),
                        TaxPostingBuffer."Dimension Set ID",
                        "Symbol Data Type"::NUMBER);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"Posted Document No.".AsInteger(),
                        TaxPostingBuffer."Posted Document No.",
                        "Symbol Data Type"::STRING);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"Posted Document Line No.".AsInteger(),
                        TaxPostingBuffer."Posted Document Line No.",
                        "Symbol Data Type"::NUMBER);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"G/L Entry No.".AsInteger(),
                        TaxPostingBuffer."G/L Entry No",
                        "Symbol Data Type"::NUMBER);

                    SymbolStore.SetDefaultSymbolValue(
                        TempSymbols,
                        TempSymbols.Type::"Posting Field",
                        "Posting Field Symbol"::"G/L Entry Transaction No.".AsInteger(),
                        TaxPostingBuffer."G/L Entry Transaction No.",
                        "Symbol Data Type"::NUMBER);

                    TaxPostingExecution.ExecutePosting(
                        UseCase,
                        Record,
                        TempSymbols,
                        TaxPostingBuffer."Component ID",
                        GroupingType::"Line / Component");
                end;
            until TaxPostingBuffer.Next() = 0;
    end;

    local procedure GetPostingUseCaseID(
        CaseID: Guid;
        ComponentID: Integer;
        ExpectedType: Option;
        var NewCaseId: Guid): Boolean
    var
        UseCase: Record "Tax Use Case";
        TaxPostingSetup: Record "Tax Posting Setup";
        SwitchCase: Record "Switch Case";
        InsertRecord: Record "Tax Insert Record";
    begin
        UseCase.Get(CaseID);
        if UseCase."Posting Table ID" <> 0 then begin
            TaxPostingSetup.Reset();
            TaxPostingSetup.SetRange("Case ID", UseCase.ID);
            TaxPostingSetup.SetRange("Component ID", ComponentID);
            if TaxPostingSetup.FindFirst() then begin
                SwitchCase.SetCurrentKey(Sequence);
                SwitchCase.SetRange("Switch Statement ID", TaxPostingSetup."Switch Statement ID");
                if SwitchCase.FindSet() then
                    repeat
                        if InsertRecord.Get(
                            SwitchCase."Case ID",
                            UseCase."Posting Script ID",
                            SwitchCase."Action ID")
                        then
                            if InsertRecord."Sub Ledger Group By" = ExpectedType then begin
                                NewCaseId := UseCase.ID;
                                exit(true);
                            end;
                    until SwitchCase.Next() = 0;
            end;

            exit(false);
        end else
            if not IsNullGuid(UseCase."Parent Use Case ID") then
                exit(GetPostingUseCaseID(
                    UseCase."Parent Use Case ID",
                    ComponentID,
                    ExpectedType,
                    NewCaseId))
            else
                exit(false);
    end;

    var
        TaxPostingExecution: Codeunit "Tax Posting Execution";
        SymbolStore: Codeunit "Script Symbol Store";
}
