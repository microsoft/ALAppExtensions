namespace Microsoft.Integration.Shopify;

codeunit 30278 "Shpfy Bulk Operation API"
{
    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationMutationResourceLbl: Label 'BULK_MUTATION_VARIABLES', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        SendBulkRequestFailedLbl: Label 'Failed to send the bulk operation', Locked = true;
        JsonlUploadFailedLbl: Label 'Uploading JSONL file failed. Status code: %1 Error: %2', Comment = '%1 = Http status code, %2 = Error message', Locked = true;
        BulkOperationFailedErr: Label 'Bulk operation failed';

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    internal procedure GetCurrentBulkRequest(var BulkOperationId: BigInteger; var Status: Enum "Shpfy Bulk Operation Status"; var ErrorCode: Text; var CompletedAt: DateTime; var Url: Text; var PartialDataUrl: Text)
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JBulkOperation: JsonObject;
    begin
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetCurrentBulkOperation, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JBulkOperation, 'data.currentBulkOperation') then begin
            BulkOperationId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JBulkOperation, 'id'));
            Status := ConvertToBulkOperationStatus(JsonHelper.GetValueAsText(JBulkOperation, 'status'));
            ErrorCode := JsonHelper.GetValueAsText(JBulkOperation, 'errorCode');
            CompletedAt := JsonHelper.GetValueAsDateTime(JBulkOperation, 'completedAt');
            Url := JsonHelper.GetValueAsText(JBulkOperation, 'url');
            PartialDataUrl := JsonHelper.GetValueAsText(JBulkOperation, 'partialDataUrl');
        end;
    end;

    internal procedure GetBulkRequest(BulkOperationId: BigInteger; var Status: Enum "Shpfy Bulk Operation Status"; var ErrorCode: Text; var CompletedAt: DateTime; var Url: Text; var PartialDataUrl: Text)
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JBulkOperation: JsonObject;
    begin
        Parameters.Add('BulkOperationId', Format(BulkOperationId));
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::GetBulkOperation, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JBulkOperation, 'data.node') then begin
            Status := ConvertToBulkOperationStatus(JsonHelper.GetValueAsText(JBulkOperation, 'status'));
            ErrorCode := JsonHelper.GetValueAsText(JBulkOperation, 'errorCode');
            CompletedAt := JsonHelper.GetValueAsDateTime(JBulkOperation, 'completedAt');
            Url := JsonHelper.GetValueAsText(JBulkOperation, 'url');
            PartialDataUrl := JsonHelper.GetValueAsText(JBulkOperation, 'partialDataUrl');
        end;
    end;

    internal procedure SendBulkRequest(Mutation: Text; ResourceUrl: Text): BigInteger
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        Parameters.Add('BulkMutation', Mutation);
        Parameters.Add('ResourceUrl', ResourceUrl);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::RunBulkOperationMutation, Parameters);
        if JsonHelper.GetValueAsText(JResponse, 'data.bulkOperationRunMutation.bulkOperation.status') = 'CREATED' then
            exit(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'data.bulkOperationRunMutation.bulkOperation.id')))
        else begin
            Session.LogMessage('0000KZA', SendBulkRequestFailedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(0);
        end;
    end;

    internal procedure CreateBulkOperationMutation(Mutation: Text; Request: Text): BigInteger
    var
        Url: Text;
        ResourceUrl: Text;
        JParameters: JsonArray;
    begin
        if CreateBulkMutationUploadUrl(Url, JParameters) then
            if UploadJsonl(Request, Url, JParameters, ResourceUrl) then
                exit(SendBulkRequest(Mutation, ResourceUrl));
    end;

    internal procedure ConvertToBulkOperationStatus(Value: Text): Enum "Shpfy Bulk Operation Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Bulk Operation Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Bulk Operation Status".FromInteger(Enum::"Shpfy Bulk Operation Status".Ordinals().Get(Enum::"Shpfy Bulk Operation Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Bulk Operation Status"::" ");
    end;

    local procedure CreateBulkMutationUploadUrl(var Url: Text; var JParameters: JsonArray): Boolean
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        Filename: Text;
        JResponse: JsonToken;
        JArray: JsonArray;
        Parameters: Dictionary of [Text, Text];
    begin
        Clear(Url);
        Filename := 'BC_Upload.jsonl';
        Parameters.Add('Filename', Filename);
        Parameters.Add('MimeType', 'text/jsonl');
        Parameters.Add('Resource', BulkOperationMutationResourceLbl);
        Parameters.Add('HttpMethod', 'POST');
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::CreateUploadUrl, Parameters);
        JArray := JsonHelper.GetJsonArray(JResponse, 'data.stagedUploadsCreate.stagedTargets');
        if JArray.Count = 1 then
            if JArray.Get(0, JResponse) then begin
                Url := JsonHelper.GetValueAsText(JResponse, 'url');
                JParameters := JsonHelper.GetJsonArray(JResponse, 'parameters');
                exit((Url <> '') and (Parameters.Count() <> 0));
            end;
    end;

    [TryFunction]
    local procedure UploadJsonl(Request: Text; Url: Text; JParameters: JsonArray; var ResourceUrl: Text)
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        MultiPartBody: TextBuilder;
        JParameter: JsonToken;
        Boundary: Text;
        ResponseMessage: Text;
    begin
        Boundary := CreateGuid();
        foreach JParameter in JParameters do begin
            MultiPartBody.AppendLine('--' + Format(Boundary));
            MultiPartBody.AppendLine('Content-Disposition: form-data; name="' + JsonHelper.GetValueAsText(JParameter, 'name') + '"');
            MultiPartBody.AppendLine();
            MultiPartBody.AppendLine(JsonHelper.GetValueAsText(JParameter, 'value'));

            if JsonHelper.GetValueAsText(JParameter, 'name') = 'key' then
                ResourceUrl := JsonHelper.GetValueAsText(JParameter, 'value');
        end;
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="file"; filename="BC_Upload.jsonl"');
        MultiPartBody.AppendLine('Content-Type: application/octet-stream');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(Request);
        MultiPartBody.AppendLine('--' + Format(Boundary) + '--');

        Content.WriteFrom(MultiPartBody.ToText());

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'multipart/form-data; boundary="' + Format(Boundary) + '"');

        CommunicationMgt.Post(Client, Url, Content, Response);
        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseMessage);
            Session.LogMessage('0000KZB', StrSubstNo(JsonlUploadFailedLbl, Response.HttpStatusCode, Response), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(BulkOperationFailedErr);
        end;
    end;

    internal procedure GetData(Url: Text): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseMessage: Text;
    begin
        CommunicationMgt.Get(Client, Url, Response);
        if Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseMessage);
            exit(ResponseMessage);
        end;
    end;
}