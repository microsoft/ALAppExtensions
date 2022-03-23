/// <summary>
/// Codeunit Shpfy Upgrade Mgt. (ID 30106).
/// </summary>
codeunit 30106 "Shpfy Upgrade Mgt."
{
    Subtype = Upgrade;

    var
        ModuleInfo: ModuleInfo;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
    end;
}