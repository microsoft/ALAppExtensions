/// <summary>
/// Codeunit Shpfy Transactions (ID 30194).
/// </summary>
codeunit 30194 "Shpfy Transactions"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    local procedure ConvertToTranscationStatus(Value: Text): Enum "Shpfy Transaction Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Transaction Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Transaction Status".FromInteger(Enum::"Shpfy Transaction Status".Ordinals().Get(Enum::"Shpfy Transaction Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Transaction Status"::" ");
    end;

    local procedure ConvertToTranscationType(Value: Text): Enum "Shpfy Transaction Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Transaction Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Transaction Type".FromInteger(Enum::"Shpfy Transaction Type".Ordinals().Get(Enum::"Shpfy Transaction Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Transaction Type"::" ");
    end;

    /// <summary> 
    /// Description for UpdateTransactionInfos.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    internal procedure UpdateTransactionInfos(OrderId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(OrderId) then
            UpdateTransactionInfos(OrderHeader);
    end;

    /// <summary> 
    /// Description for UpdateTransactionInfos.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure UpdateTransactionInfos(OrderHeader: Record "Shpfy Order Header")
    var
        CreditCardCompany: Record "Shpfy Credit Card Company";
        DataCapture: Record "Shpfy Data Capture";
        OrderTransaction: Record "Shpfy Order Transaction";
        PaymentMethodMapping: Record "Shpfy Payment Method Mapping";
        TransactionGateway: Record "Shpfy Transaction Gateway";
        RecordRef: RecordRef;
        Id: BigInteger;
        IsNew: Boolean;
        JTransactions: JsonArray;
        JResponse: JsonToken;
        JToken: JsonToken;
        Url: Text;
        OrderTransactionsUrlTxt: Label 'orders/%1/transactions.json', Comment = '%1 = Shopify order id', Locked = true;
    begin
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(OrderTransactionsUrlTxt, OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteWebRequest(Url, 'GET', JToken);
        if JsonHelper.GetJsonArray(JResponse, JTransactions, 'transactions') then
            foreach JToken in JTransactions do begin
                Id := JsonHelper.GetValueAsBigInteger(JToken, 'id');
                IsNew := not OrderTransaction.Get(Id);
                if IsNew then begin
                    Clear(OrderTransaction);
                    OrderTransaction."Shopify Transaction Id" := Id;
                end;
                OrderTransaction.Status := ConvertToTranscationStatus(JsonHelper.GetValueAsText(JToken, 'status'));
                OrderTransaction.Type := ConvertToTranscationType(JsonHelper.GetValueAsText(JToken, 'kind'));
                RecordRef.GetTable(OrderTransaction);
                JsonHelper.GetValueIntoField(JToken, 'order_id', RecordRef, OrderTransaction.FieldNo("Shopify Order Id"));
                JsonHelper.GetValueIntoField(JToken, 'gateway', RecordRef, OrderTransaction.FieldNo(Gateway));
                JsonHelper.GetValueIntoField(JToken, 'message', RecordRef, OrderTransaction.FieldNo(Message));
                JsonHelper.GetValueIntoField(JToken, 'created_at', RecordRef, OrderTransaction.FieldNo("Created At"));
                JsonHelper.GetValueIntoField(JToken, 'test', RecordRef, OrderTransaction.FieldNo(Test));
                JsonHelper.GetValueIntoField(JToken, 'authorization', RecordRef, OrderTransaction.FieldNo(Authorization));
                JsonHelper.GetValueIntoField(JToken, 'receipt.gift_card_id', RecordRef, OrderTransaction.FieldNo("Gift Card Id"));
                JsonHelper.GetValueIntoField(JToken, 'error_code', RecordRef, OrderTransaction.FieldNo("Error Code"));
                JsonHelper.GetValueIntoField(JToken, 'source_name', RecordRef, OrderTransaction.FieldNo("Source Name"));
                JsonHelper.GetValueIntoField(JToken, 'amount', RecordRef, OrderTransaction.FieldNo(Amount));
                JsonHelper.GetValueIntoField(JToken, 'currency', RecordRef, OrderTransaction.FieldNo(Currency));
                JsonHelper.GetValueIntoField(JToken, 'payment_details.credit_card_bin', RecordRef, OrderTransaction.FieldNo("Credit Card Bin"));
                JsonHelper.GetValueIntoField(JToken, 'payment_details.avs_result_code', RecordRef, OrderTransaction.FieldNo("AVS Result Code"));
                JsonHelper.GetValueIntoField(JToken, 'payment_details.cvv_result_code', RecordRef, OrderTransaction.FieldNo("CVV Result Code"));
                JsonHelper.GetValueIntoField(JToken, 'payment_details.credit_card_number', RecordRef, OrderTransaction.FieldNo("Credit Card Number"));
                JsonHelper.GetValueIntoField(JToken, 'payment_details.credit_card_company', RecordRef, OrderTransaction.FieldNo("Credit Card Company"));
                if IsNew then
                    RecordRef.Insert()
                else
                    RecordRef.Modify();
                RecordRef.SetTable(OrderTransaction);
                RecordRef.Close();
                if OrderTransaction.Gateway <> '' then begin
                    Clear(TransactionGateway);
                    TransactionGateway.SetRange(Name, OrderTransaction.Gateway);
                    if TransactionGateway.IsEmpty then begin
                        TransactionGateway.Name := OrderTransaction.Gateway;
                        TransactionGateway.Insert();
                    end;
                    Clear(CreditCardCompany);
                end;
                if OrderTransaction."Credit Card Company" <> '' then begin
                    CreditCardCompany.SetRange(Name, OrderTransaction."Credit Card Company");
                    if CreditCardCompany.IsEmpty then begin
                        CreditCardCompany.Name := OrderTransaction."Credit Card Company";
                        CreditCardCompany.Insert();
                    end;
                end;
                if not PaymentMethodMapping.Get(OrderHeader."Shop Code", OrderTransaction.Gateway, OrderTransaction."Credit Card Company") then begin
                    Clear(PaymentMethodMapping);
                    PaymentMethodMapping."Shop Code" := OrderHeader."Shop Code";
                    PaymentMethodMapping.Gateway := OrderTransaction.Gateway;
                    PaymentMethodMapping."Credit Card Company" := CopyStr(OrderTransaction."Credit Card Company", 1, MaxStrLen(PaymentMethodMapping."Credit Card Company"));
                    PaymentMethodMapping.Insert();
                end;

                DataCapture.Add(Database::"Shpfy Order Transaction", OrderTransaction.SystemId, JToken);
            end;
    end;
}