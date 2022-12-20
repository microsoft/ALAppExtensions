/// <summary>
/// Codeunit Shpfy Location Subcriber (ID 139587).
/// </summary>
codeunit 139587 "Shpfy Location Subcriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        JLocations: JsonObject;

    internal procedure InitShopiyLocations(Locations: JsonObject)
    begin
        JLocations := Locations;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMsg: HttpRequestMessage; var HttpResponseMsg: HttpResponseMessage)
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        MakeReponse(CommunicationMgt.GetShopRecord(), CommunicationMgt.GetVersion(), HttpRequestMsg, HttpResponseMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMsg: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMsg.Content.ReadAs(Response);
    end;

    local procedure MakeReponse(ShpfyShop: Record "Shpfy Shop"; Version: Text; HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        GetLocationUrlTxt: Label '%1/admin/api/%2/locations.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'GET':
                case HttpRequestMessage.GetRequestUri() of
                    StrSubstNo(GetLocationUrlTxt, ShpfyShop."Shopify URL".TrimEnd('/'), Version):
                        HttpResponseMessage := GetLocationResult();
                end;
        end;
    end;

    local procedure GetLocationResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom(Format(JLocations));
        exit(HttpResponseMessage);
    end;

}
