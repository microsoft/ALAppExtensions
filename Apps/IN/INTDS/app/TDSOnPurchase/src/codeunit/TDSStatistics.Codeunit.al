// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPurchase;

using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Document;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Purchases.History;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18719 "TDS Statistics"
{
    Access = Internal;
    procedure GetStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var TDSAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        TDSEntityManagement: Codeunit "TDS Entity Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TDSAmount);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                RecordIDList.Add(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TDSAmount += GetTDSAmount(RecordIDList.Get(i));

        TDSAmount := TDSEntityManagement.RoundTDSAmount(TDSAmount);
    end;

    procedure GetStatisticsPostedAmount(
        PurchInvHeader: Record "Purch. Inv. Header";
        var TDSAmount: Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        TDSEntityManagement: Codeunit "TDS Entity Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TDSAmount);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                RecordIDList.Add(PurchInvLine.RecordId());
            until PurchInvLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TDSAmount += GetTDSAmount(RecordIDList.Get(i));

        TDSAmount := TDSEntityManagement.RoundTDSAmount(TDSAmount);
    end;

    procedure GetStatisticsPostedPurchCrMemoAmount(
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        var TDSAmount: Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        TDSEntityManagement: Codeunit "TDS Entity Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TDSAmount);

        PurchInvLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                RecordIDList.Add(PurchInvLine.RecordId());
            until PurchInvLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TDSAmount += GetTDSAmount(RecordIDList.Get(i));

        TDSAmount := TDSEntityManagement.RoundTDSAmount(TDSAmount);
    end;

    local procedure GetTDSAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TDSSetup: Record "TDS Setup";
    begin
        if not TDSSetup.Get() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchaseHeaderTDSAmount', '', false, false)]
    local procedure OnGetPurchaseHeaderTDSAmount(PurchaseHeader: Record "Purchase Header"; var TDSAmount: Decimal)
    begin
        GetStatisticsAmount(PurchaseHeader, TDSAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchInvHeaderTDSAmount', '', false, false)]
    local procedure OnGetPurchInvHeaderTDSAmount(PurchInvHeader: Record "Purch. Inv. Header"; var TDSAmount: Decimal)
    begin
        GetStatisticsPostedAmount(PurchInvHeader, TDSAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchCrMemoHeaderTDSAmount', '', false, false)]
    local procedure OnGetPurchCrMemoHeaderTDSAmount(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var TDSAmount: Decimal)
    begin
        GetStatisticsPostedPurchCrMemoAmount(PurchCrMemoHeader, TDSAmount);
    end;
}
