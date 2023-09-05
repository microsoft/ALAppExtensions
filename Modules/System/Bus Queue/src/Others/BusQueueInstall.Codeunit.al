codeunit 51761 "Bus Queue Install"
{
    Access = Internal;
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "NAV App Setting" = RIM;

    trigger OnInstallAppPerDatabase()
    begin
        EnableAllowHTTPClientRequests();
    end;

    local procedure EnableAllowHTTPClientRequests()
    var
        NAVAppSetting: Record "NAV App Setting";
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);

        NAVAppSetting."App ID" := ModuleInfo.Id();
        NAVAppSetting."Allow HttpClient Requests" := true;
        if not NAVAppSetting.Insert() then
            if NAVAppSetting.Modify() then;
    end;
}