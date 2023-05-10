/// <summary>
/// Codeunit Shpfy Payments (ID 30169).
/// </summary>
codeunit 30169 "Shpfy Payments"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        if Rec.FindSet(false, false) then
            repeat
                SetShop(Rec);
                ImportPaymentTransactions();
            until Rec.Next() = 0;
    end;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for ImportPaymentTransactions.
    /// </summary>
    local procedure ImportPaymentTransactions()
    var
        SinceId: BigInteger;
        JTransactions: JsonArray;
        JItem: JsonToken;
        JResponse: JsonToken;
        Url: Text;
        UrlTxt: Label 'shopify_payments/balance/transactions.json?since_id=%1', Comment = '%1 = Last sync Date and Time.', Locked = true;
    begin
        SinceId := GetLastTransactionPayoutId(Shop.Code);

        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(UrlTxt, SinceId));
        Clear(SinceId);
        repeat
            JResponse := CommunicationMgt.ExecuteWebRequest(Url, 'GET', JResponse, Url);
            if JsonHelper.GetJsonArray(JResponse, JTransactions, 'transactions') then
                foreach JItem in JTransactions do
                    ImportPaymentTransaction(JItem, SinceId);
        until Url = '';

        if SinceId > 0 then
            ImportPayouts(SinceId - 1);
    end;

    /// <summary> 
    /// Description for ImportPayouts.
    /// </summary>
    /// <param name="SinceId">Parameter of type BigInteger.</param>
    local procedure ImportPayouts(SinceId: BigInteger)
    var
        DataCapture: Record "Shpfy Data Capture";
        Payout: Record "Shpfy Payout";
        Math: Codeunit "Shpfy Math";
        RecordRef: RecordRef;
        Id: BigInteger;
        JPayouts: JsonArray;
        JItem: JsonToken;
        JResponse: JsonToken;
        Url: Text;
        UrlTxt: LAbel 'shopify_payments/payouts.json?since_id=%1', Comment = '%1 = Last sync Date and Time.', Locked = true;
    begin
        Payout.SetFilter(Status, '<>%1&<>%2', "Shpfy Payout Status"::Paid, "Shpfy Payout Status"::Canceled);
        Payout.SetLoadFields(Id);
        if Payout.FindFirst() then
            SinceId := Math.Min(SinceId, Payout.Id);
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(UrlTxt, SinceId));
        repeat
            JResponse := CommunicationMgt.ExecuteWebRequest(Url, 'GET', JResponse, Url);
            if JsonHelper.GetJsonArray(JResponse, JPayouts, 'payouts') then
                foreach JItem in JPayouts do begin
                    Id := JsonHelper.GetValueAsBigInteger(JItem, 'id');
                    if Payout.Get(Id) then begin
                        Payout.Status := ConvertToPayoutStatus(JsonHelper.GetValueAsText(JItem, 'status'));
                        Payout.Modify();
                    end else begin
                        RecordRef.Open(Database::"Shpfy Payout");
                        RecordRef.Init();
                        JsonHelper.GetValueIntoField(JItem, 'date', RecordRef, Payout.FieldNo(Date));
                        JsonHelper.GetValueIntoField(JItem, 'currency', RecordRef, Payout.FieldNo(Currency));
                        JsonHelper.GetValueIntoField(JItem, 'amount', RecordRef, Payout.FieldNo(Amount));
                        JsonHelper.GetValueIntoField(JItem, 'summary.adjustments_fee_amount', RecordRef, Payout.FieldNo("Adjustments Fee Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.adjustments_gross_amount', RecordRef, Payout.FieldNo("Adjustments Gross Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.charges_fee_amount', RecordRef, Payout.FieldNo("Charges Fee Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.charges_gross_amount', RecordRef, Payout.FieldNo("Charges Gross Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.refunds_fee_amount', RecordRef, Payout.FieldNo("Refunds Fee Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.refunds_gross_amount', RecordRef, Payout.FieldNo("Refunds gross Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.reserved_funds_fee_amount', RecordRef, Payout.FieldNo("Reserved Funds Fee Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.reserved_funds_gross_amount', RecordRef, Payout.FieldNo("Reserved Funds Gross Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.retried_payouts_fee_amount', RecordRef, Payout.FieldNo("Retried Payouts Fee Amount"));
                        JsonHelper.GetValueIntoField(JItem, 'summary.retried_payouts_gross_amount', RecordRef, Payout.FieldNo("Retried Payouts Gross Amount"));
                        RecordRef.SetTable(Payout);
                        RecordRef.Close();
                        Payout.Id := Id;
                        Payout.Status := ConvertToPayoutStatus(JsonHelper.GetValueAsText(JItem, 'status'));
                        Payout.Insert();
                    end;
                    DataCapture.Add(Database::"Shpfy Payout", Payout.SystemId, JItem);
                end;
        until Url = '';
    end;

    local procedure ConvertToPayoutStatus(Value: Text): Enum "Shpfy Payout Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Payout Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Payout Status".FromInteger(Enum::"Shpfy Payout Status".Ordinals().Get(Enum::"Shpfy Payout Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Payout Status"::Unknown);
    end;

    local procedure ConvertToPaymentTranscationType(Value: Text): Enum "Shpfy Payment Trans. Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Payment Trans. Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Payment Trans. Type".FromInteger(Enum::"Shpfy Payment Trans. Type".Ordinals().Get(Enum::"Shpfy Payment Trans. Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Payment Trans. Type"::Unknown);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    local procedure GetLastTransactionPayoutId(ShopCode: Code[20]): BigInteger
    var
        PaymentTransaction: Record "Shpfy Payment Transaction";
    begin
        PaymentTransaction.SetRange("Shop Code", ShopCode);
        if PaymentTransaction.FindLast() then
            exit(PaymentTransaction."Payout Id");
    end;

    internal procedure ImportPaymentTransaction(JTransaction: JsonToken; var SinceId: BigInteger)
    var
        DataCapture: Record "Shpfy Data Capture";
        PaymentTransaction: Record "Shpfy Payment Transaction";
        Math: Codeunit "Shpfy Math";
        RecordRef: RecordRef;
        Id: BigInteger;
    begin
        Id := JsonHelper.GetValueAsBigInteger(JTransaction, 'id');
        Clear(PaymentTransaction);
        PaymentTransaction.SetRange(Id, Id);
        if PaymentTransaction.IsEmpty then begin
            RecordRef.Open(Database::"Shpfy Payment Transaction");
            RecordRef.Init();
            JsonHelper.GetValueIntoField(JTransaction, 'test', RecordRef, PaymentTransaction.FieldNo(Test));
            JsonHelper.GetValueIntoField(JTransaction, 'payout_id', RecordRef, PaymentTransaction.FieldNo("Payout Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'currency', RecordRef, PaymentTransaction.FieldNo(Currency));
            JsonHelper.GetValueIntoField(JTransaction, 'amount', RecordRef, PaymentTransaction.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JTransaction, 'fee', RecordRef, PaymentTransaction.FieldNo(Fee));
            JsonHelper.GetValueIntoField(JTransaction, 'net', RecordRef, PaymentTransaction.FieldNo("Net Amount"));
            JsonHelper.GetValueIntoField(JTransaction, 'source_id', RecordRef, PaymentTransaction.FieldNo("Source Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'source_order_id', RecordRef, PaymentTransaction.FieldNo("Source Order Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'source_order_transaction_id', RecordRef, PaymentTransaction.FieldNo("Source Order Transaction Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'processed_at', RecordRef, PaymentTransaction.FieldNo("Processed At"));
            RecordRef.SetTable(PaymentTransaction);
            RecordRef.Close();
            PaymentTransaction.Id := Id;
            PaymentTransaction."Shop Code" := Shop.Code;
            PaymentTransaction.Type := ConvertToPaymentTranscationType(JsonHelper.GetValueAsText(JTransaction, 'type'));
            PaymentTransaction."Source Type" := ConvertToPaymentTranscationType(JsonHelper.GetValueAsText(JTransaction, 'type'));
            PaymentTransaction.Insert();
            DataCapture.Add(Database::"Shpfy Payment Transaction", PaymentTransaction.SystemId, JTransaction);
            if SinceId = 0 then
                SinceId := PaymentTransaction."Payout Id"
            else
                if PaymentTransaction."Payout Id" > 0 then
                    SinceId := Math.Min(SinceId, PaymentTransaction."Payout Id");
        end;
    end;
}