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
                Session.LogMessage('00007YJ', StrSubstNo(GPSmartListFailedMsg, PackageId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory())
            else
                if not TryToInstallSL(PackageId) then
                    Session.LogMessage('00007ZY', StrSubstNo(InstallExtenFailedMsg, PackageId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory())
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