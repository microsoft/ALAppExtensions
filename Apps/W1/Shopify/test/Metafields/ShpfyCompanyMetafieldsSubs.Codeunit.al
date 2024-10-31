codeunit 139541 "Shpfy Company Metafields Subs"
{
    EventSubscriberInstance = Manual;

    var
        GQLQueryTxt: Text;

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
        ModifyCompanyLocationGQLStartTok: Label '{"query":"mutation {companyLocationAssignAddress(locationId: \"gid://shopify/CompanyLocation/', Locked = true;
        ModifyCompanyGQLStartTok: Label '{"query":"mutation {companyUpdate(companyId: \"gid://shopify/Company/', Locked = true;
        GetCompanyMetafieldsGQLStartTok: Label '{"query":"{company(id: \"gid://shopify/Company/', Locked = true;
        GetCompanyMetafieldsGQLEndTok: Label '\") {metafields(first: 50) {edges {node {id namespace ownerType legacyResourceId }}}}}"}', Locked = true;
        CreateMetafieldsGQLStartTok: Label '{"query": "mutation { metafieldsSet(metafields: ', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.StartsWith(ModifyCompanyGQLStartTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(ModifyCompanyLocationGQLStartTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(GetCompanyMetafieldsGQLStartTok) and GraphQlQuery.EndsWith(GetCompanyMetafieldsGQLEndTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(CreateMetafieldsGQLStartTok):
                                    begin
                                        HttpResponseMessage := GetEmptyResponse();
                                        GQLQueryTxt := GraphQlQuery;
                                    end;
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

    internal procedure GetGQLQuery(): Text
    begin
        exit(GQLQueryTxt);
    end;

}
