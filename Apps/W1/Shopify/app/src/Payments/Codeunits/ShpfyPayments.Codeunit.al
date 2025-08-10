// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Payments (ID 30169).
/// </summary>
codeunit 30169 "Shpfy Payments"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        PaymentsAPI: Codeunit "Shpfy Payments API";

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        PaymentsAPI.SetShop(Shop);
    end;

    internal procedure SyncPaymentTransactions()
    var
        SinceId: BigInteger;
    begin
        SinceId := GetLastTransactionPayoutId(Shop.Code);
        PaymentsAPI.ImportPaymentTransactions(SinceId);
        if SinceId > 0 then
            ImportPayouts(SinceId - 1);
    end;

    internal procedure SyncDisputes()
    begin
        UpdateUnfinishedDisputes();
        ImportNewDisputes();
    end;

    local procedure UpdateUnfinishedDisputes()
    var
        Dispute: Record "Shpfy Dispute";
    begin
        Dispute.SetFilter("Status", '<>%1&<>%2', Dispute."Status"::Won, Dispute."Status"::Lost);
        if Dispute.FindSet() then
            repeat
                PaymentsAPI.UpdateDispute(Dispute.Id);
            until Dispute.Next() = 0;
    end;

    local procedure ImportNewDisputes()
    var
        Dispute: Record "Shpfy Dispute";
        SinceId: BigInteger;
    begin
        if Dispute.FindLast() then
            SinceId := Dispute.Id;
        PaymentsAPI.ImportDisputes(SinceId);
    end;

    local procedure ImportPayouts(SinceId: BigInteger)
    var
        Payout: Record "Shpfy Payout";
        Math: Codeunit "Shpfy Math";
    begin
        Payout.SetFilter(Status, '<>%1&<>%2', "Shpfy Payout Status"::Paid, "Shpfy Payout Status"::Canceled);
        Payout.SetLoadFields(Id);
        if Payout.FindFirst() then
            SinceId := Math.Min(SinceId, Payout.Id);

        PaymentsAPI.ImportPayouts(SinceId);
    end;

    local procedure GetLastTransactionPayoutId(ShopCode: Code[20]): BigInteger
    var
        PaymentTransaction: Record "Shpfy Payment Transaction";
    begin
        PaymentTransaction.SetRange("Shop Code", ShopCode);
        if PaymentTransaction.FindLast() then
            exit(PaymentTransaction."Payout Id");
    end;
}