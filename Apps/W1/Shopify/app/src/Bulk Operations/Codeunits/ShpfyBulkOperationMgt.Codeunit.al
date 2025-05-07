namespace Microsoft.Integration.Shopify;

using System.Integration;

codeunit 30270 "Shpfy Bulk Operation Mgt."
{
    var
        InvalidUserErr: Label 'You must sign in with a Business Central licensed user to enable the feature.';
        CategoryTok: Label 'Shopify Integration', Locked = true;
        BulkOperationsDontMatchLbl: Label 'Searched bulk operation (%1, %2, %3) does not match with current one (%4)', Comment = '%1 = Bulk Operation Id, %2 = Shop Code, %3 = Type, %4 = Bulk Operation Id', Locked = true;
        BulkOperationCreatedLbl: Label 'A bulk request was sent to Shopify. You can check the status of the synchronization in the Shopify Bulk Operations page.';

    internal procedure EnableBulkOperations(var Shop: Record "Shpfy Shop")
    var
        WebhooksMgt: Codeunit "Shpfy Webhooks Mgt.";
        WebhookManagement: Codeunit "Webhook Management";
        IsHandled: Boolean;
    begin
        if not WebhookManagement.IsValidNotificationRunAsUser(UserSecurityID()) then begin
            OnInvalidUser(IsHandled);
            if not IsHandled then
                Error(InvalidUserErr);
        end;

        Shop."Bulk Operation Webhook User Id" := UserSecurityID();
        WebhooksMgt.EnableBulkOperationWebhook(Shop);
    end;

    internal procedure SendBulkMutation(var Shop: Record "Shpfy Shop"; BulkOperationType: Enum "Shpfy Bulk Operation Type"; Jsonl: Text; RequestData: JsonArray): Boolean
    var
        BulkOperation: Record "Shpfy Bulk Operation";
        BulkOperationAPI: Codeunit "Shpfy Bulk Operation API";
        BulkOperationStatus: Enum "Shpfy Bulk Operation Status";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        Type: Option mutation,query;
        BulkOperationId: BigInteger;
    begin
        IBulkOperation := BulkOperationType;
        Evaluate(Type, IBulkOperation.GetType());
        BulkOperation.SetRange("Shop Code", Shop.Code);
        BulkOperation.SetRange(Type, Type);
        BulkOperation.SetFilter(Status, '%1|%2', BulkOperation.Status::Created, BulkOperation.Status::Running);
        if BulkOperation.FindFirst() then begin
            UpdateBulkOperationStatus(Shop, BulkOperation."Bulk Operation Id", Type, BulkOperationStatus);
            if BulkOperationStatus in [BulkOperationStatus::Created, BulkOperationStatus::Running] then
                exit(false);
        end;

        BulkOperationAPI.SetShop(Shop);
        BulkOperationId := BulkOperationAPI.CreateBulkOperationMutation(IBulkOperation.GetGraphQL(), Jsonl);
        if BulkOperationId = 0 then
            exit(false);
        CreateBulkOperation(Shop, BulkOperationId, Type, IBulkOperation.GetName(), RequestData, BulkOperationType);
        if GuiAllowed then
            Message(BulkOperationCreatedLbl);
        exit(true);
    end;

    internal procedure ProcessBulkOperationNotification(var Shop: Record "Shpfy Shop"; JNotification: JsonObject)
    var
        BulkOperation: Record "Shpfy Bulk Operation";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        BulkOperationAPI: Codeunit "Shpfy Bulk Operation API";
        BulkOperationId: BigInteger;
        BulkOperationStatus: Enum "Shpfy Bulk Operation Status";
        ErrorCode: Text;
        Url: Text;
        PartialDataUrl: Text;
        CompletedAt: DateTime;
        BulkOperationType: Option mutation,query;
    begin
        BulkOperationId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNotification, 'admin_graphql_api_id'));
        Evaluate(BulkOperationType, JsonHelper.GetValueAsText(JNotification, 'type'));

        if BulkOperation.Get(BulkOperationId, Shop.Code, BulkOperationType) then begin
            BulkOperationAPI.SetShop(Shop);
            BulkOperationAPI.GetBulkRequest(BulkOperationId, BulkOperationStatus, ErrorCode, CompletedAt, Url, PartialDataUrl);
            BulkOperation.Status := BulkOperationStatus;
            if ErrorCode <> '' then
                BulkOperation."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(BulkOperation."Error Code"));
            if CompletedAt <> 0DT then
                BulkOperation."Completed At" := CompletedAt;
            if Url <> '' then
                BulkOperation.Url := CopyStr(Url, 1, MaxStrLen(BulkOperation.Url));
            if PartialDataUrl <> '' then
                BulkOperation."Partial Data Url" := CopyStr(PartialDataUrl, 1, MaxStrLen(BulkOperation."Partial Data Url"));
            BulkOperation.Modify(true);
        end;
    end;

    local procedure CreateBulkOperation(Shop: Record "Shpfy Shop"; BulkOperationId: BigInteger; Type: Option; Name: Text[250]; RequestData: JsonArray; BulkOperationType: Enum "Shpfy Bulk Operation Type")
    var
        BulkOperation: Record "Shpfy Bulk Operation";
    begin
        BulkOperation."Bulk Operation Id" := BulkOperationId;
        BulkOperation."Shop Code" := Shop.Code;
        BulkOperation.Type := Type;
        BulkOperation.Name := Name;
        BulkOperation.Status := BulkOperation.Status::Created;
        BulkOperation."Bulk Operation Type" := BulkOperationType;
        BulkOperation.Insert();
        BulkOperation.SetRequestData(RequestData);
    end;

    internal procedure UpdateBulkOperationStatus(Shop: Record "Shpfy Shop"; SearchBulkOperationId: BigInteger; Type: Option; var BulkOperationStatus: Enum "Shpfy Bulk Operation Status")
    var
        BulkOperation: Record "Shpfy Bulk Operation";
        BulkOperationAPI: Codeunit "Shpfy Bulk Operation API";
        BulkOperationId: BigInteger;
        ErrorCode: Text;
        CompletedAt: DateTime;
        Url: Text;
        PartialDataUrl: Text;
    begin
        BulkOperationAPI.SetShop(Shop);
        BulkOperationAPI.GetCurrentBulkRequest(BulkOperationId, BulkOperationStatus, ErrorCode, CompletedAt, Url, PartialDataUrl);
        if BulkOperation.Get(BulkOperationId, Shop.Code, Type) then begin
            BulkOperation.Status := BulkOperationStatus;
            if ErrorCode <> '' then
                BulkOperation."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(BulkOperation."Error Code"));
            if CompletedAt <> 0DT then
                BulkOperation."Completed At" := CompletedAt;
            if Url <> '' then
                BulkOperation.Url := CopyStr(Url, 1, MaxStrLen(BulkOperation.Url));
            if PartialDataUrl <> '' then
                BulkOperation."Partial Data Url" := CopyStr(PartialDataUrl, 1, MaxStrLen(BulkOperation."Partial Data Url"));
            BulkOperation.Modify(true);

            if BulkOperationId <> SearchBulkOperationId then begin
                Session.LogMessage('0000KZC', StrSubstNo(BulkOperationsDontMatchLbl, SearchBulkOperationId, Shop.Code, Type, BulkOperationId), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                BulkOperationAPI.GetBulkRequest(SearchBulkOperationId, BulkOperationStatus, ErrorCode, CompletedAt, Url, PartialDataUrl);
                BulkOperation.Get(SearchBulkOperationId, Shop.Code, Type);
                BulkOperation.Status := BulkOperationStatus;
                if ErrorCode <> '' then
                    BulkOperation."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(BulkOperation."Error Code"));
                if CompletedAt <> 0DT then
                    BulkOperation."Completed At" := CompletedAt;
                if Url <> '' then
                    BulkOperation.Url := CopyStr(Url, 1, MaxStrLen(BulkOperation.Url));
                if PartialDataUrl <> '' then
                    BulkOperation."Partial Data Url" := CopyStr(PartialDataUrl, 1, MaxStrLen(BulkOperation."Partial Data Url"));
                BulkOperation.Modify(true);
            end;
        end;
    end;

    internal procedure DeleteEntries(var BulkOperation: Record "Shpfy Bulk Operation"; DaysOld: Integer);
    begin
        if DaysOld > 0 then begin
            BulkOperation.SetFilter(SystemCreatedAt, '<=%1', CreateDateTime(Today - DaysOld, Time));
            if not BulkOperation.IsEmpty then
                BulkOperation.DeleteAll(false);
            BulkOperation.SetRange(SystemCreatedAt);
        end else
            if not BulkOperation.IsEmpty then
                BulkOperation.DeleteAll(false);
    end;

    internal procedure GetBulkOperationResult(Shop: Record "Shpfy Shop"; BulkOperation: Record "Shpfy Bulk Operation"): Text
    var
        BulkOperationAPI: Codeunit "Shpfy Bulk Operation API";
    begin
        BulkOperationAPI.SetShop(Shop);
        if BulkOperation.Url <> '' then
            exit(BulkOperationAPI.GetData(BulkOperation.Url));
        if BulkOperation."Partial Data Url" <> '' then
            exit(BulkOperationAPI.GetData(BulkOperation."Partial Data Url"));
    end;

    internal procedure GetBulkOperationThreshold(): Integer
    begin
        exit(100);
    end;

    [InternalEvent(false, false)]
    local procedure OnInvalidUser(var IsHandled: Boolean)
    begin
    end;
}