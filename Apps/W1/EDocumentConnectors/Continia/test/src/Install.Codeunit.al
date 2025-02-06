namespace Microsoft.EServices.EDocumentConnector.Continia;
using System.Environment.Configuration;

codeunit 148205 "Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        EnableCoreHttpTraffic();
    end;

    procedure EnableCoreHttpTraffic()
    var
        NAVAppSetting: Record "NAV App Setting";
    begin
        if not NAVAppSetting.get(ContiniaEDocumentConnectorAppId()) then begin
            NAVAppSetting."App ID" := ContiniaEDocumentConnectorAppId();
            NAVAppSetting."Allow HttpClient Requests" := true;
            NAVAppSetting.Insert();
        end else begin
            NAVAppSetting."Allow HttpClient Requests" := true;
            NAVAppSetting.Modify();
        end;
    end;

    procedure ContiniaEDocumentConnectorAppId(): Text
    begin
        exit('31ef535a-1182-4354-98e8-e0e66a587055')
    end;
}