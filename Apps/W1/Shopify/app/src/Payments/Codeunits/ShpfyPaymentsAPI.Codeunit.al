namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Payments API (ID 30385).
/// </summary>
codeunit 30385 "Shpfy Payments API"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    internal procedure ImportPaymentTransactions(var SinceId: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JTransactions: JsonArray;
        JPaymentsAccount: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := GraphQLType::GetPaymentTransactions;
        Parameters.Add('SinceId', Format(SinceId));
        Clear(SinceId);
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonObject(JResponse, JPaymentsAccount, 'data.shopifyPaymentsAccount') then
                if JsonHelper.GetJsonArray(JResponse, JTransactions, 'data.shopifyPaymentsAccount.balanceTransactions.edges') then begin
                    foreach JItem in JTransactions do begin
                        Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                        if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then
                            ImportPaymentTransaction(JNode, SinceId);
                    end;
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := GraphQLType::GetNextPaymentTransactions;
                end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.shopifyPaymentsAccount.balanceTransactions.pageInfo.hasNextPage');
    end;

    internal procedure ImportPaymentTransaction(JTransaction: JsonObject; var SinceId: BigInteger)
    var
        DataCapture: Record "Shpfy Data Capture";
        PaymentTransaction: Record "Shpfy Payment Transaction";
        Math: Codeunit "Shpfy Math";
        RecordRef: RecordRef;
        Id: BigInteger;
        PayoutId: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTransaction, 'id'));
        Clear(PaymentTransaction);
        PaymentTransaction.SetRange(Id, Id);
        if PaymentTransaction.IsEmpty then begin
            RecordRef.Open(Database::"Shpfy Payment Transaction");
            RecordRef.Init();
            JsonHelper.GetValueIntoField(JTransaction, 'test', RecordRef, PaymentTransaction.FieldNo(Test));
            JsonHelper.GetValueIntoField(JTransaction, 'amount.currencyCode', RecordRef, PaymentTransaction.FieldNo(Currency));
            JsonHelper.GetValueIntoField(JsonHelper.GetJsonObject(JTransaction, 'amount'), 'amount', RecordRef, PaymentTransaction.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JTransaction, 'fee.amount', RecordRef, PaymentTransaction.FieldNo(Fee));
            JsonHelper.GetValueIntoField(JTransaction, 'net.amount', RecordRef, PaymentTransaction.FieldNo("Net Amount"));
            JsonHelper.GetValueIntoField(JTransaction, 'sourceId', RecordRef, PaymentTransaction.FieldNo("Source Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'sourceOrderTransactionId', RecordRef, PaymentTransaction.FieldNo("Source Order Transaction Id"));
            JsonHelper.GetValueIntoField(JTransaction, 'transactionDate', RecordRef, PaymentTransaction.FieldNo("Processed At"));
            RecordRef.SetTable(PaymentTransaction);
            RecordRef.Close();
            PaymentTransaction.Id := Id;
            PaymentTransaction."Shop Code" := Shop.Code;
            PaymentTransaction.Type := ConvertToPaymentTranscationType(JsonHelper.GetValueAsText(JTransaction, 'type'));
            PaymentTransaction."Source Type" := ConvertToPaymentTranscationType(JsonHelper.GetValueAsText(JTransaction, 'type'));
            PaymentTransaction."Source Order Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTransaction, 'associatedOrder.id'));
            PaymentTransaction."Payout Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTransaction, 'associatedPayout.id'));
            PaymentTransaction.Insert();
            DataCapture.Add(Database::"Shpfy Payment Transaction", PaymentTransaction.SystemId, JTransaction);
            if SinceId = 0 then
                SinceId := PaymentTransaction."Payout Id"
            else
                if PaymentTransaction."Payout Id" > 0 then
                    SinceId := Math.Min(SinceId, PaymentTransaction."Payout Id");
        end else begin
            PaymentTransaction.Get(Id);
            if PaymentTransaction."Payout Id" = 0 then begin
                PayoutId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTransaction, 'associatedPayout.id'));
                if PayoutId <> 0 then begin
                    PaymentTransaction."Payout Id" := PayoutId;
                    PaymentTransaction.Modify();
                end;
            end;
        end;
    end;

    internal procedure ImportPayouts(SinceId: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JPayouts: JsonArray;
        JPaymentsAccount: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := GraphQLType::GetPayouts;
        Parameters.Add('SinceId', Format(SinceId));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonObject(JResponse, JPaymentsAccount, 'data.shopifyPaymentsAccount') then
                if JsonHelper.GetJsonArray(JResponse, JPayouts, 'data.shopifyPaymentsAccount.payouts.edges') then begin
                    foreach JItem in JPayouts do begin
                        Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                        if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then
                            ImportPayout(JNode);
                    end;
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := GraphQLType::GetNextPayouts;
                end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.shopifyPaymentsAccount.payouts.pageInfo.hasNextPage');
    end;

    local procedure ImportPayout(JPayout: JsonObject)
    var
        DataCapture: Record "Shpfy Data Capture";
        Payout: Record "Shpfy Payout";
        RecordRef: RecordRef;
        Id: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JPayout, 'id'));
        if Payout.Get(Id) then begin
            Payout.Status := ConvertToPayoutStatus(JsonHelper.GetValueAsText(JPayout, 'status'));
            Payout.Modify();
        end else begin
            RecordRef.Open(Database::"Shpfy Payout");
            RecordRef.Init();
            JsonHelper.GetValueIntoField(JPayout, 'issuedAt', RecordRef, Payout.FieldNo(Date));
            JsonHelper.GetValueIntoField(JPayout, 'net.currencyCode', RecordRef, Payout.FieldNo(Currency));
            JsonHelper.GetValueIntoField(JPayout, 'net.amount', RecordRef, Payout.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JPayout, 'summary.adjustmentsFee.amount', RecordRef, Payout.FieldNo("Adjustments Fee Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.adjustmentsGross.amount', RecordRef, Payout.FieldNo("Adjustments Gross Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.chargesFee.amount', RecordRef, Payout.FieldNo("Charges Fee Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.chargesGross.amount', RecordRef, Payout.FieldNo("Charges Gross Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.refundsFee.amount', RecordRef, Payout.FieldNo("Refunds Fee Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.refundsFeeGross.amount', RecordRef, Payout.FieldNo("Refunds gross Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.reservedFundsFee.amount', RecordRef, Payout.FieldNo("Reserved Funds Fee Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.reservedFundsGross.amount', RecordRef, Payout.FieldNo("Reserved Funds Gross Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.retriedPayoutsFee.amount', RecordRef, Payout.FieldNo("Retried Payouts Fee Amount"));
            JsonHelper.GetValueIntoField(JPayout, 'summary.retriedPayoutsGross.amount', RecordRef, Payout.FieldNo("Retried Payouts Gross Amount"));
            RecordRef.SetTable(Payout);
            RecordRef.Close();
            Payout.Id := Id;
            Payout.Status := ConvertToPayoutStatus(JsonHelper.GetValueAsText(JPayout, 'status'));
            Payout.Insert();
        end;
        DataCapture.Add(Database::"Shpfy Payout", Payout.SystemId, JPayout);
    end;

    internal procedure ImportDisputes(SinceId: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JDisputes: JsonArray;
        JPaymentsAccount: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := GraphQLType::GetDisputes;
        Parameters.Add('SinceId', Format(SinceId));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonObject(JResponse, JPaymentsAccount, 'data.shopifyPaymentsAccount') then
                if JsonHelper.GetJsonArray(JResponse, JDisputes, 'data.shopifyPaymentsAccount.disputes.edges') then begin
                    foreach JItem in JDisputes do begin
                        Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                        if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then
                            ImportDispute(JNode);
                    end;
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := GraphQLType::GetNextDisputes;
                end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.shopifyPaymentsAccount.disputes.pageInfo.hasNextPage');
    end;

    internal procedure UpdateDispute(Id: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JDisputes: JsonArray;
        JPaymentsAccount: JsonObject;
        JNode: JsonObject;
        JDispute: JsonToken;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := GraphQLType::GetDisputeById;
        Parameters.Add('Id', Format(Id));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JPaymentsAccount, 'data.shopifyPaymentsAccount') then
            if JsonHelper.GetJsonArray(JResponse, JDisputes, 'data.shopifyPaymentsAccount.disputes.nodes') then
                if JDisputes.Count = 1 then begin
                    JDisputes.Get(0, JDispute);
                    if JsonHelper.GetJsonObject(JDispute.AsObject(), JNode, 'node') then
                        ImportDispute(JNode);
                end;
    end;

    internal procedure ImportDispute(JDispute: JsonObject)
    var
        Dispute: Record "Shpfy Dispute";
        RecordRef: RecordRef;
        Id: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JDispute, 'id'));
        if Dispute.Get(Id) then begin
            Dispute.Status := ConvertToDisputeStatus(JsonHelper.GetValueAsText(JDispute, 'status'));
            Dispute."Evidence Sent On" := JsonHelper.GetValueAsDateTime(JDispute, 'evidenceDueBy');
            Dispute."Finalized On" := JsonHelper.GetValueAsDateTime(JDispute, 'finalizedOn');
            Dispute.Modify();
        end else begin
            RecordRef.Open(Database::"Shpfy Dispute");
            RecordRef.Init();
            JsonHelper.GetValueIntoField(JDispute, 'amount.currencyCode', RecordRef, Dispute.FieldNo(Currency));
            JsonHelper.GetValueIntoField(JsonHelper.GetJsonObject(JDispute, 'amount'), 'amount', RecordRef, Dispute.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JDispute, 'reasonDetails.networkReasonCode', RecordRef, Dispute.FieldNo("Network Reason Code"));
            JsonHelper.GetValueIntoField(JDispute, 'evidenceDueBy', RecordRef, Dispute.FieldNo("Evidence Due By"));
            JsonHelper.GetValueIntoField(JDispute, 'evidenceSentOn', RecordRef, Dispute.FieldNo("Evidence Sent On"));
            JsonHelper.GetValueIntoField(JDispute, 'finalizedOn', RecordRef, Dispute.FieldNo("Finalized On"));
            RecordRef.SetTable(Dispute);
            RecordRef.Close();
            Dispute.Id := Id;
            Dispute.Status := ConvertToDisputeStatus(JsonHelper.GetValueAsText(JDispute, 'status'));
            Dispute.Type := ConvertToDisputeType(JsonHelper.GetValueAsText(JDispute, 'type'));
            Dispute.Reason := ConvertToDisputeReason(JsonHelper.GetValueAsText(JDispute, 'reasonDetails.reason'));
            Dispute."Source Order Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JDispute, 'order.id'));
            Dispute.Insert();
        end;
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
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

    local procedure ConvertToDisputeStatus(Value: Text): Enum "Shpfy Dispute Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Dispute Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Dispute Status".FromInteger(Enum::"Shpfy Dispute Status".Ordinals().Get(Enum::"Shpfy Dispute Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Dispute Status"::Unknown);
    end;

    local procedure ConvertToDisputeType(Value: Text): Enum "Shpfy Dispute Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Dispute Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Dispute Type".FromInteger(Enum::"Shpfy Dispute Type".Ordinals().Get(Enum::"Shpfy Dispute Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Dispute Type"::Unknown);
    end;

    local procedure ConvertToDisputeReason(Value: Text): Enum "Shpfy Dispute Reason"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Dispute Reason".Names().Contains(Value) then
            exit(Enum::"Shpfy Dispute Reason".FromInteger(Enum::"Shpfy Dispute Reason".Ordinals().Get(Enum::"Shpfy Dispute Reason".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Dispute Reason"::Unknown);
    end;
}