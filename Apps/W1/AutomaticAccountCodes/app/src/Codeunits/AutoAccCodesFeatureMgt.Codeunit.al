#if not CLEAN22
codeunit 4853 "Auto. Acc. Codes Feature Mgt."
{
    Permissions = TableData "Feature Key" = rm;
    ObsoleteState = Pending;
    ObsoleteReason = 'The codeunit contains functions to help upgrade in countries where the feature existed in Base Application.';
    ObsoleteTag = '22.0';
    Access = Internal;

    procedure OnBeforeUpgradeToAutomaticAccountCodes(var AutomaticAccHeaderTableId: Integer; var AutomaticAccLineTableId: Integer)
    begin
        AutomaticAccHeaderTableId := 11203; // Database::"Automatic Acc. Header";
        AutomaticAccLineTableId := 11204; // Database::"Automatic Acc. Line";
    end;

    procedure IsEnabled(): Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsEnabled(Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit(FeatureManagementFacade.IsEnabled(FeatureKeyIdTok));
    end;

    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;

    procedure DisableAutoAccCodesActions()
    var
        AutoAccCodesPageMgt: Codeunit "Auto. Acc. Codes Page Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        Country: Text;
    begin
        Country := EnvironmentInformation.GetApplicationFamily();
        if (Country = 'SE') or (Country = 'FI') then begin
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups Card", 11206); // page 11206 "Automatic Acc. Header"
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups List", 11208); // page 11208 "Automatic Acc. List"
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsEnabled(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnInitializeFeatureDataUpdateStatus', '', false, false)]
    local procedure HandleOnInitializeFeatureDataUpdateStatus(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; var InitializeHandled: Boolean)
    var
        FeatureKey: Record "Feature Key";
    begin
        if InitializeHandled then
            exit;

        if FeatureDataUpdateStatus."Feature Key" <> GetFeatureKeyId() then
            exit;

        if FeatureDataUpdateStatus."Company Name" <> CopyStr(CompanyName(), 1, MaxStrLen(FeatureDataUpdateStatus."Company Name")) then
            exit;

        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Disabled;
        if FeatureKey.WritePermission() then begin
            FeatureKey.Get(FeatureDataUpdateStatus."Feature Key");
            FeatureKey.Enabled := FeatureKey.Enabled::None;
            FeatureKey.Modify();
        end;
        InitializeHandled := true;
    end;

    var
        FeatureKeyIdTok: Label 'AutomaticAccountCodes', Locked = true;
}
#endif