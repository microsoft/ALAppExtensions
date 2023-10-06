// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;


Codeunit 18015 "GST Posting Management"
{
    SingleInstance = true;

    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        RecordIDNotAvailableErr: Label 'Table %1 not handled', comment = '%1 = Table Caption';
        PurchasePaytoVendorNo: Code[20];
        GSTRegNo: code[20];
        State: Code[10];
        GSTAmountFCY: Decimal;
        GSTBaseAmountFCY: Decimal;
        UseCaseID: Guid;
        GSTTrackingEntryNo: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnPrepareTransValueToPost', '', false, false)]
    local procedure SetUseCaseID(var TempTransValue: Record "Tax Transaction Value")
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if GSTSetup."GST Tax Type" = TempTransValue."Tax Type" then
            UseCaseID := TempTransValue."Case ID";
    end;

    procedure GetUseCaseID(): Guid
    begin
        exit(UseCaseID);
    end;

    procedure SetRecord(Record: Variant)
    var
        RecRef: RecordRef;
    begin
        if not Record.IsRecord then
            exit;
        Clear(DetailedGSTLedgerEntry);
        RecRef.GetTable(Record);
        case RecRef.Number of
            database::"Detailed GST Ledger Entry":
                DetailedGSTLedgerEntry := Record;
            else
                Error(RecordIDNotAvailableErr, RecRef.Caption);
        end;
    end;

    procedure GetRecord(var Record: Variant; TableID: Integer)
    begin
        case TableID of
            Database::"Detailed GST Ledger Entry":
                Record := DetailedGSTLedgerEntry
            else
                Error(RecordIDNotAvailableErr, TableID);
        end;
    end;

    procedure SetGSTAmountFCY(FCYAmount: Decimal)
    begin
        GSTAmountFCY := FCYAmount;
    end;

    procedure GetGSTAmountFCY(): Decimal
    begin
        exit(GSTAmountFCY);
    end;

    procedure SetGSTBaseAmountFCY(FCYBaseAmount: Decimal)
    begin
        GSTBaseAmountFCY := FCYBaseAmount;
    end;

    procedure GetGSTBaseAmountFCY(): Decimal
    begin
        exit(GSTBaseAmountFCY);
    end;

    procedure SetGSTTrackingEntryNo(EntryNo: Integer)
    begin
        GSTTrackingEntryNo := EntryNo;
    end;

    procedure GetGSTTrackingEntryNo(): Integer
    begin
        exit(GSTTrackingEntryNo);
    end;

    procedure SetPaytoVendorNo(PaytoVendorNo: Code[20])
    begin
        PurchasePaytoVendorNo := PaytoVendorNo;
    end;

    procedure GetPaytoVendorNo(): Code[20]
    begin
        exit(PurchasePaytoVendorNo);
    end;

    procedure SetBuyerSellerRegNo(PayGSTRegNo: code[20])
    begin
        GSTRegNo := PayGSTRegNo;
    end;

    procedure GetBuyerSellerRegNo(): Code[20]
    begin
        exit(GSTRegNo);
    end;

    procedure SetBuyerSellerStateCode(PayStateCode: Code[10])
    begin
        State := PayStateCode;
    end;

    procedure GetBuyerSellerStateCode(): Code[10]
    begin
        exit(state);
    end;
}

