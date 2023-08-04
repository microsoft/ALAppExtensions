/// <summary>
/// Codeunit Shpfy Install Mgt. (ID 30105).
/// </summary>
codeunit 30105 "Shpfy Install Mgt."
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
    begin

    end;

    trigger OnInstallAppPerCompany()
    var
        ShpfyUpgradeMgt: Codeunit "Shpfy Upgrade Mgt.";
    begin
        ShpfyUpgradeMgt.AddRetentionPolicyAllowedTables();
    end;
}