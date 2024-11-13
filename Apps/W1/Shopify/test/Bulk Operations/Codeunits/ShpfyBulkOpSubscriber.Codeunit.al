codeunit 139615 "Shpfy Bulk Op. Subscriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        UploadUrlLbl: Label 'https://shopify-staged-uploads.storage.googleapis.com', Locked = true;
        BulkOperationId: BigInteger;
        BulkOperationRunning: Boolean;
        BulkUploadFail: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Bulk Operation Mgt.", 'OnInvalidUser', '', true, false)]
    local procedure OnInvalidUser(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        MakeResponse(HttpRequestMessage, HttpResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientPost', '', true, false)]
    local procedure OnClientPost(var Url: Text; var Content: HttpContent; var Response: HttpResponseMessage)
    begin
        if Url = UploadUrlLbl then
            Response := GetJsonlUploadResult();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMessage.Content.ReadAs(Response);
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQLQuery: Text;
        StagedUploadGQLTxt: Label '{"query": "mutation { stagedUploadsCreate(input', Locked = true;
        BulkMutationGQLTxt: Label '{"query": "mutation { bulkOperationRunMutation(mutation', Locked = true;
        BulkOperationGQLTxt: Label '{"query": "query { currentBulkOperation(type', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQLQuery) then begin
                            if GraphQLQuery.StartsWith(StagedUploadGQLTxt) then
                                HttpResponseMessage := GetStagedUplodResult();
                            if GraphQLQuery.StartsWith(BulkMutationGQLTxt) then
                                HttpResponseMessage := GetBulkMutationResponse();
                            if GraphQLQuery.StartsWith(BulkOperationGQLTxt) then
                                if BulkOperationRunning then
                                    HttpResponseMessage := GetBulkOperationRunningResult()
                                else
                                    HttpResponseMessage := GetBulkOperationCompletedResult()
                        end;
                end;
        end;
    end;

    local procedure GetStagedUplodResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        if BulkUploadFail then
            Body := '{ "data": { "stagedUploadsCreate": { "userErrors": [], "stagedTargets": [ { "url": "", "resourceUrl": null, "parameters": [ { "name": "key", "value": "tmp/21759409/bulk/2d278b12-d153-4667-a05c-a5d8181623de/bulk_op_vars" }, { "name": "Content-Type", "value": "text/jsonl" }, { "name": "success_action_status", "value": "201" }, { "name": "acl", "value": "private" }, { "name": "policy", "value": "123456789" }, { "name": "x-goog-credential", "value": "merchant-assets@shopify-tiers.iam.gserviceaccount.com/20220830/auto/storage/goog4_request" }, { "name": "x-goog-algorithm", "value": "GOOG4-RSA-SHA256" }, { "name": "x-goog-date", "value": "20220830T025127Z" }, { "name": "x-goog-signature", "value": "123456789" } ] } ] } }, "extensions": { "cost": { "requestedQueryCost": 11, "actualQueryCost": 11 } } }'
        else
            Body := '{ "data": { "stagedUploadsCreate": { "userErrors": [], "stagedTargets": [ { "url": "' + UploadUrlLbl + '", "resourceUrl": null, "parameters": [ { "name": "key", "value": "tmp/21759409/bulk/2d278b12-d153-4667-a05c-a5d8181623de/bulk_op_vars" }, { "name": "Content-Type", "value": "text/jsonl" }, { "name": "success_action_status", "value": "201" }, { "name": "acl", "value": "private" }, { "name": "policy", "value": "123456789" }, { "name": "x-goog-credential", "value": "merchant-assets@shopify-tiers.iam.gserviceaccount.com/20220830/auto/storage/goog4_request" }, { "name": "x-goog-algorithm", "value": "GOOG4-RSA-SHA256" }, { "name": "x-goog-date", "value": "20220830T025127Z" }, { "name": "x-goog-signature", "value": "123456789" } ] } ] } }, "extensions": { "cost": { "requestedQueryCost": 11, "actualQueryCost": 11 } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkMutationResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "bulkOperationRunMutation": { "bulkOperation": { "id": "gid://shopify/BulkOperation/' + Format(BulkOperationId) + '", "url": null, "status": "CREATED" }, "userErrors": [] } }, "extensions": { "cost": { "requestedQueryCost": 10, "actualQueryCost": 10 } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkOperationCompletedResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "currentBulkOperation": { "id": "gid://shopify/BulkOperation/' + Format(BulkOperationId) + '", "status": "COMPLETED", "errorCode": null, "createdAt": "2021-01-28T19:10:59Z", "completedAt": "2021-01-28T19:11:09Z", "objectCount": "16", "fileSize": "0", "url": "", "partialDataUrl": null } }, "extensions": { "cost": { "requestedQueryCost": 1, "actualQueryCost": 1 } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkOperationRunningResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{ "data": { "currentBulkOperation": { "id": "gid://shopify/BulkOperation/' + Format(BulkOperationId) + '", "status": "RUNNING", "errorCode": null, "createdAt": "2021-01-28T19:10:59Z", "completedAt": "2021-01-28T19:11:09Z", "objectCount": "16", "fileSize": "0", "url": "", "partialDataUrl": null } }, "extensions": { "cost": { "requestedQueryCost": 1, "actualQueryCost": 1 } } }';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetJsonlUploadResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        exit(HttpResponseMessage);
    end;

    internal procedure SetBulkOperationId(Id: BigInteger)
    begin
        BulkOperationId := Id;
    end;

    internal procedure SetBulkOperationRunning(OperationRunning: Boolean)
    begin
        BulkOperationRunning := OperationRunning;
    end;

    internal procedure SetBulkUploadFail(Fail: Boolean)
    begin
        BulkUploadFail := Fail;
    end;
}