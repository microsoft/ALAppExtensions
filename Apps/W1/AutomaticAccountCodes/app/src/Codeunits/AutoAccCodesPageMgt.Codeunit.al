#if not CLEAN22
/// <summary>
/// Automatic Acc.functionality will be moved to a new app.
/// </summary>
codeunit 4858 "Auto. Acc. Codes Page Mgt."
{

    local procedure OpenPage(AutoAccCodesPageSetupKey: Enum "AAC Page Setup Key")
    var
        AutoAccPageSetup: Record "Auto. Acc. Page Setup";
    begin
        if not GetAutoAccPageSetup(AutoAccCodesPageSetupKey, AutoAccPageSetup) then
            exit;
        Page.Run(AutoAccPageSetup.ObjectId);
    end;

    procedure OpenAutoAccGroupListPage()
    begin
        OpenPage(AutoAccCodesPageSetupKey::"Automatic Acc. Groups List");
    end;

    procedure OpenAutoAccGroupCardPage()
    begin
        OpenPage(AutoAccCodesPageSetupKey::"Automatic Acc. Groups Card");
    end;

    procedure SetSetupKey(AutoAccCodesPageSetupKey: Enum "AAC Page Setup Key"; KeyValue: Integer)
    var
        AutoAccPageSetup: Record "Auto. Acc. Page Setup";
    begin
        if not AutoAccPageSetup.Get(AutoAccCodesPageSetupKey) then begin
            AutoAccPageSetup.Id := AutoAccCodesPageSetupKey;
            AutoAccPageSetup.Insert();
        end;
        AutoAccPageSetup.ObjectId := KeyValue;
        AutoAccPageSetup.Modify();
    end;

    internal procedure GetAutoAccPageSetup(AutoAccCodesPageSetupKey: Enum "AAC Page Setup Key"; var AutoAccPageSetup: Record "Auto. Acc. Page Setup"): Boolean
    var
        FeatureKey: Record "Feature Key";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
    begin
        if AutoAccPageSetup.Get(AutoAccCodesPageSetupKey) then
            exit(true);

        if AutoAccCodesFeatureMgt.IsEnabled() then begin
            FeatureKey.Get(FeatureKeyIdTok);
            FeatureManagementFacade.AfterValidateEnabled(FeatureKey);
            if AutoAccPageSetup.Get(AutoAccCodesPageSetupKey) then
                exit(true);
        end;

        AutoAccCodesFeatureMgt.DisableAutoAccCodesActions();
        if AutoAccPageSetup.Get(AutoAccCodesPageSetupKey) then
            exit(true);
        exit(false);
    end;

    var
        AutoAccCodesPageSetupKey: Enum "AAC Page Setup Key";
        FeatureKeyIdTok: Label 'AutomaticAccountCodes', Locked = true;
}
#endif