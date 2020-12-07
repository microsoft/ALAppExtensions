codeunit 4033 "Install GP SmartLists"
{
    trigger OnRun();
    begin
        InstallGPSmartListsExtension();
    end;

    procedure InstallGPSmartListsExtension()
    var
        ExtensionManagement: Codeunit 2504;
        HelperFunctions: Codeunit "Helper Functions";
        AppId: Guid;
        PackageId: Guid;
        GPSmartListFailedMsg: Label 'Dynamics GP Smartlists failed to install because PackageId is %1', Locked = true;
        InstallExtenFailedMsg: Label 'Dynamics GP Smartlists Extension failed to install, PackageId is %1', Locked = true;

    begin
        AppId := '6c2902a8-23e5-4289-9c7c-d345e2a328f5';
        if not ExtensionManagement.IsInstalledByAppId(AppId) then begin
            PackageId := ExtensionManagement.GetLatestVersionPackageIdByAppId(AppId);
            if IsNullGuid(PackageId) then
                SendTraceTag('00007YJ', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Normal, StrSubstNo(GPSmartListFailedMsg, PackageId), DataClassification::SystemMetadata)
            else
                If Not TryToInstallSL(PackageId) then
                    SendTraceTag('00007ZY', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Normal, StrSubstNo(InstallExtenFailedMsg, PackageId), DataClassification::SystemMetadata)
        end;
    end;

    [TryFunction]
    local procedure TryToInstallSL(PackageId: Guid)
    var
        ExtensionManagement: Codeunit 2504;
    begin
        ExtensionManagement.InstallExtension(PackageID, GlobalLanguage(), FALSE)
    end;
}