// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Transactions (ID 30194).
/// </summary>
codeunit 30194 "Shpfy Transactions"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    local procedure ConvertToTransactionStatus(Value: Text): Enum "Shpfy Transaction Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Transaction Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Transaction Status".FromInteger(Enum::"Shpfy Transaction Status".Ordinals().Get(Enum::"Shpfy Transaction Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Transaction Status"::" ");
    end;

    local procedure ConvertToTransactionType(Value: Text): Enum "Shpfy Transaction Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Transaction Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Transaction Type".FromInteger(Enum::"Shpfy Transaction Type".Ordinals().Get(Enum::"Shpfy Transaction Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Transaction Type"::" ");
    end;

    internal procedure UpdateTransactionInfos(OrderId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(OrderId) then
            UpdateTransactionInfos(OrderHeader);
    end;

    internal procedure UpdateTransactionInfos(OrderHeader: Record "Shpfy Order Header")
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        JOrderTransaction: JsonToken;
        JOrderTransactions: JsonArray;
        Parameters: Dictionary of [Text, Text];
    begin
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        GraphQLType := "Shpfy GraphQL Type"::GetOrderTransactions;
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JOrderTransactions, 'data.order.transactions') then
            foreach JOrderTransaction in JOrderTransactions do
                ExtractShopifyOrderTransaction(JOrderTransaction, OrderHeader);
    end;

    local procedure ExtractShopifyOrderTransaction(JOrderTransaction: JsonToken; OrderHeader: Record "Shpfy Order Header")
    var
        CreditCardCompany: Record "Shpfy Credit Card Company";
        DataCapture: Record "Shpfy Data Capture";
        OrderTransaction: Record "Shpfy Order Transaction";
        PaymentMethodMapping: Record "Shpfy Payment Method Mapping";
        TransactionGateway: Record "Shpfy Transaction Gateway";
        RecordRef: RecordRef;
        Id: BigInteger;
        IsNew: Boolean;
        JObject: JsonObject;
        ReceiptJson: Text;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrderTransaction, 'id'));
        IsNew := not OrderTransaction.Get(Id);
        if IsNew then begin
            Clear(OrderTransaction);
            OrderTransaction."Shopify Transaction Id" := Id;
        end;
        OrderTransaction.Status := ConvertToTransactionStatus(JsonHelper.GetValueAsText(JOrderTransaction, 'status'));
        OrderTransaction.Type := ConvertToTransactionType(JsonHelper.GetValueAsText(JOrderTransaction, 'kind'));
        OrderTransaction."Shopify Order Id" := OrderHeader."Shopify Order Id";
        RecordRef.GetTable(OrderTransaction);
        JsonHelper.GetValueIntoField(JOrderTransaction, 'gateway', RecordRef, OrderTransaction.FieldNo(Gateway));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'formattedGateway', RecordRef, OrderTransaction.FieldNo(Message));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'manualPaymentGateway', RecordRef, OrderTransaction.FieldNo("Manual Payment Gateway"));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'createdAt', RecordRef, OrderTransaction.FieldNo("Created At"));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'test', RecordRef, OrderTransaction.FieldNo(Test));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'authorizationCode', RecordRef, OrderTransaction.FieldNo(Authorization));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'errorCode', RecordRef, OrderTransaction.FieldNo("Error Code"));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentId', RecordRef, OrderTransaction.FieldNo("Payment Id"));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'amountSet.shopMoney.amount', RecordRef, OrderTransaction.FieldNo(Amount));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'amountSet.shopMoney.currencyCode', RecordRef, OrderTransaction.FieldNo(Currency));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'amountRoundingSet.shopMoney.amount', RecordRef, OrderTransaction.FieldNo("Rounding Amount"));
        JsonHelper.GetValueIntoField(JOrderTransaction, 'amountRoundingSet.shopMoney.currencyCode', RecordRef, OrderTransaction.FieldNo("Rounding Currency"));

        ReceiptJson := JsonHelper.GetValueAsText(JOrderTransaction, 'receiptJson');
        if JObject.ReadFrom(ReceiptJson) then
            JsonHelper.GetValueIntoField(JObject, 'gift_card_id', RecordRef, OrderTransaction.FieldNo("Gift Card Id"));

        if JsonHelper.GetJsonObject(JOrderTransaction, JObject, 'paymentDetails') then begin
            JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentDetails.bin', RecordRef, OrderTransaction.FieldNo("Credit Card Bin"));
            JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentDetails.avsResultCode', RecordRef, OrderTransaction.FieldNo("AVS Result Code"));
            JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentDetails.cvvResultCode', RecordRef, OrderTransaction.FieldNo("CVV Result Code"));
            JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentDetails.number', RecordRef, OrderTransaction.FieldNo("Credit Card Number"));
            JsonHelper.GetValueIntoField(JOrderTransaction, 'paymentDetails.company', RecordRef, OrderTransaction.FieldNo("Credit Card Company"));
        end;
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
            PaymentMethodMapping."Manual Payment Gateway" := OrderTransaction."Manual Payment Gateway";
            PaymentMethodMapping.Insert();
        end;

        DataCapture.Add(Database::"Shpfy Order Transaction", OrderTransaction.SystemId, JOrderTransaction);
    end;
}