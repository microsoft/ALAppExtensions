codeunit 134244 "Shpfy Company Mapping Subs."
{
    EventSubscriberInstance = Manual;

    var
        CompanyImportExecuted: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        MakeResponse(HttpRequestMessage, HttpResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMessage.Content.ReadAs(Response);
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQlQuery: Text;
        GetCompanyGQLStartTok: Label '{"query":"{company(id: \"gid://shopify/Company/', Locked = true;
        GetCompanyGQLEndTok: Label '\") {name id note createdAt updatedAt mainContact { id customer { id firstName lastName email phone}} metafields(first: 50) {edges {node {id namespace ownerType legacyResourceId key value type}}}}}"}', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            if GraphQlQuery.StartsWith(GetCompanyGQLStartTok) and GraphQlQuery.EndsWith(GetCompanyGQLEndTok) then begin
                                HttpResponseMessage := GetEmptyResponse();
                                CompanyImportExecuted := true;
                            end;
                end;
        end;
    end;

    local procedure GetEmptyResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure GetCompanyImportExecuted(): Boolean
    begin
        exit(CompanyImportExecuted);
    end;
}