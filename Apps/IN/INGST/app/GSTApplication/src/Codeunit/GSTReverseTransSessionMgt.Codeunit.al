// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Reversal;

codeunit 18437 "GST Reverse Trans. Session Mgt"
{
    SingleInstance = true;

    var
        TempReversalEntry: Record "Reversal Entry" temporary;
        ReversalNextTransactionNo: Integer;

    procedure SetReversalEntry(var ReversalEntry: Record "Reversal Entry")
    begin
        TempReversalEntry.Reset();
        if TempReversalEntry.FindSet() then
            TempReversalEntry.DeleteAll();

        if ReversalEntry.FindSet() then
            repeat
                TempReversalEntry.Reset();
                TempReversalEntry.SetRange("Transaction No.", ReversalEntry."Transaction No.");
                if not TempReversalEntry.FindFirst() then begin
                    TempReversalEntry.Init();
                    TempReversalEntry := ReversalEntry;
                    TempReversalEntry.Insert();
                end;
            until ReversalEntry.Next() = 0;
    end;

    procedure SetReversalNextTransactionNo(NextTransactionNo: Integer)
    begin
        ReversalNextTransactionNo := NextTransactionNo;
    end;

    procedure GetReversalEntry(
        var ReversalEntry: Record "Reversal Entry" temporary;
        var NextTransactionNo: Integer)
    begin
        TempReversalEntry.Reset();
        if TempReversalEntry.FindSet() then
            repeat
                ReversalEntry.Init();
                ReversalEntry := TempReversalEntry;
                ReversalEntry.Insert();
            until TempReversalEntry.Next() = 0;

        NextTransactionNo := ReversalNextTransactionNo;
        ReversalNextTransactionNo := 0;

        TempReversalEntry.Reset();
        TempReversalEntry.DeleteAll();
    end;
}
