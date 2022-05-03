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
        JHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for ImportPaymentTransactions.
    /// </summary>
    local procedure ImportPaymentTransactions()
    var
        DataCapture: Record "Shpfy Data Capture";
        Transaction: Record "Shpfy Payment Transaction";
        Math: Codeunit "Shpfy Math";
        RecRef: RecordRef;
        Id: BigInteger;
        SinceId: BigInteger;
        JTransactions: JsonArray;
        JItem: JsonToken;
        JResponse: JsonToken;
        Url: Text;
        UrlTxt: Label 'shopify_payments/balance/transactions.json?since_id=%1', Comment = '%1 = Last sync Date and Time.', Locked = true;
    begin
        Transaction.SetRange("Shop Code", Shop.Code);
        if Transaction.FindLast() then
            SinceId := Transaction.Id;
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(UrlTxt, SinceId));
        Clear(SinceId);
        repeat
            JResponse := CommunicationMgt.ExecuteWebRequest(Url, 'GET', JResponse, Url);
            if JHelper.GetJsonArray(JResponse, JTransactions, 'transactions') then
                foreach JItem in JTransactions do begin
                    Id := JHelper.GetValueAsBigInteger(JItem, 'id');
                    Clear(Transaction);
                    Transaction.SetRange(Id, Id);
                    if Transaction.IsEmpty then begin
                        RecRef.Open(Database::"Shpfy Payment Transaction");
                        RecRef.Init();
                        JHelper.GetValueIntoField(JItem, 'test', RecRef, Transaction.FieldNo(Test));
                        JHelper.GetValueIntoField(JItem, 'payout_id', RecRef, Transaction.FieldNo("Payout Id"));
                        JHelper.GetValueIntoField(JItem, 'currency', RecRef, Transaction.FieldNo(Currency));
                        JHelper.GetValueIntoField(JItem, 'amount', RecRef, Transaction.FieldNo(Amount));
                        JHelper.GetValueIntoField(JItem, 'fee', RecRef, Transaction.FieldNo(Fee));
                        JHelper.GetValueIntoField(JItem, 'net', RecRef, Transaction.FieldNo("Net Amount"));
                        JHelper.GetValueIntoField(JItem, 'source_id', RecRef, Transaction.FieldNo("Source Id"));
                        JHelper.GetValueIntoField(JItem, 'source_order_id', RecRef, Transaction.FieldNo("Source Order Id"));
                        JHelper.GetValueIntoField(JItem, 'source_order_transaction_id', RecRef, Transaction.FieldNo("Source Order Transaction Id"));
                        JHelper.GetValueIntoField(JItem, 'processed_at', RecRef, Transaction.FieldNo("Processed At"));
                        RecRef.SetTable(Transaction);
                        RecRef.Close();
                        Transaction.Id := Id;
                        Transaction."Shop Code" := Shop.Code;
                        Transaction.Type := ConvertToPaymentTranscationType(JHelper.GetValueAsText(JItem, 'type'));
                        Transaction."Source Type" := ConvertToPaymentTranscationType(JHelper.GetValueAsText(JItem, 'type'));
                        Transaction.Insert();
                        DataCapture.Add(Database::"Shpfy Payment Transaction", Transaction.SystemId, JItem);
                        if SinceId = 0 then
                            SinceId := Transaction."Payout Id"
                        else
                            if Transaction."Payout Id" > 0 then
                                SinceId := Math.Min(SinceId, Transaction."Payout Id");
                    end;
                end;
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
        RecRef: RecordRef;
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
            if JHelper.GetJsonArray(JResponse, JPayouts, 'payouts') then
                foreach JItem in JPayouts do begin
                    Id := JHelper.GetValueAsBigInteger(JItem, 'id');
                    if Payout.Get(Id) then begin
                        Payout.Status := ConvertToPayoutStatus(JHelper.GetValueAsText(JItem, 'status'));
                        Payout.Modify();
                    end else begin
                        RecRef.Open(Database::"Shpfy Payout");
                        RecRef.Init();
                        JHelper.GetValueIntoField(JItem, 'date', RecRef, Payout.FieldNo(Date));
                        JHelper.GetValueIntoField(JItem, 'currency', RecRef, Payout.FieldNo(Currency));
                        JHelper.GetValueIntoField(JItem, 'amount', RecRef, Payout.FieldNo(Amount));
                        JHelper.GetValueIntoField(JItem, 'summary.adjustments_fee_amount', RecRef, Payout.FieldNo("Adjustments Fee Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.adjustments_gross_amount', RecRef, Payout.FieldNo("Adjustments Gross Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.charges_fee_amount', RecRef, Payout.FieldNo("Charges Fee Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.charges_gross_amount', RecRef, Payout.FieldNo("Charges Gross Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.refunds_fee_amount', RecRef, Payout.FieldNo("Refunds Fee Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.refunds_gross_amount', RecRef, Payout.FieldNo("Refunds gross Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.reserved_funds_fee_amount', RecRef, Payout.FieldNo("Reserved Funds Fee Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.reserved_funds_gross_amount', RecRef, Payout.FieldNo("Reserved Funds Gross Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.retried_payouts_fee_amount', RecRef, Payout.FieldNo("Retried Payouts Fee Amount"));
                        JHelper.GetValueIntoField(JItem, 'summary.retried_payouts_gross_amount', RecRef, Payout.FieldNo("Retried Payouts Gross Amount"));
                        RecRef.SetTable(Payout);
                        RecRef.Close();
                        Payout.Id := Id;
                        Payout.Status := ConvertToPayoutStatus(JHelper.GetValueAsText(JItem, 'status'));
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
}