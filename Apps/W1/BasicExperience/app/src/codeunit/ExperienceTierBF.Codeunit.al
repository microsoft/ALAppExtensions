codeunit 20602 "Experience Tier BF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnValidateApplicationAreas', '', true, true)]
    local procedure OnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        if not ExperienceTierSetup."BF Basic" then
            exit;

        // Due to lack of OnUninstall trigger in AL, the code wich verifies if the Application Area Setup is set to certain value when installing the extension is temporarily comment out. 
        // TempApplicationAreaSetup.TestField("BF Orders", false);
        // TempApplicationAreaSetup.TestField("BF Basic", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        AppAreaMgmt: Codeunit "App Area Mgmt BF";
    begin
        if not ExperienceTierSetup."BF Basic" then
            exit;

        AppAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        DisableNonBasicExperienceAppAreas(TempApplicationAreaSetup);
        SetExperienceAppAreas(TempApplicationAreaSetup);
        ApplicationAreasSet := true;
    end;

    local procedure SetExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        TempApplicationAreaSetup."BF Basic" := true; // Application Area belonging to this extension
        TempApplicationAreaSetup.Basic := true;
        TempApplicationAreaSetup.Suite := true;
        TempApplicationAreaSetup.Jobs := true;
        TempApplicationAreaSetup."Fixed Assets" := true;
        TempApplicationAreaSetup.Location := true;
        TempApplicationAreaSetup.BasicHR := true;
        TempApplicationAreaSetup.Warehouse := true;
        TempApplicationAreaSetup.Planning := true;
        TempApplicationAreaSetup.Dimensions := true;
        TempApplicationAreaSetup.Prepayments := true;
        TempApplicationAreaSetup.XBRL := true;
        TempApplicationAreaSetup.Comments := true;
        TempApplicationAreaSetup."Record Links" := true;
        TempApplicationAreaSetup.Notes := true;
        TempApplicationAreaSetup.VAT := true;
    end;

    local procedure DisableNonBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        TempApplicationAreaSetupBasic: Record "Application Area Setup" temporary;
    begin
        TempApplicationAreaSetupBasic := TempApplicationAreaSetup;

        Clear(TempApplicationAreaSetup);

        TempApplicationAreaSetup."Basic AT" := TempApplicationAreaSetupBasic."Basic AT";
        TempApplicationAreaSetup."Basic AU" := TempApplicationAreaSetupBasic."Basic AU";
        TempApplicationAreaSetup."Basic BE" := TempApplicationAreaSetupBasic."Basic BE";
        TempApplicationAreaSetup."Basic CA" := TempApplicationAreaSetupBasic."Basic CA";
        TempApplicationAreaSetup."Basic CH" := TempApplicationAreaSetupBasic."Basic CH";
        TempApplicationAreaSetup."Basic CZ" := TempApplicationAreaSetupBasic."Basic CZ";
        TempApplicationAreaSetup."Basic DE" := TempApplicationAreaSetupBasic."Basic DE";
        TempApplicationAreaSetup."Basic DK" := TempApplicationAreaSetupBasic."Basic DK";
        TempApplicationAreaSetup."Basic ES" := TempApplicationAreaSetupBasic."Basic ES";
        TempApplicationAreaSetup."Basic EU" := TempApplicationAreaSetupBasic."Basic EU";
        TempApplicationAreaSetup."Basic FI" := TempApplicationAreaSetupBasic."Basic FI";
        TempApplicationAreaSetup."Basic FR" := TempApplicationAreaSetupBasic."Basic FR";
        TempApplicationAreaSetup."Basic GB" := TempApplicationAreaSetupBasic."Basic GB";
        TempApplicationAreaSetup."Basic IS" := TempApplicationAreaSetupBasic."Basic IS";
        TempApplicationAreaSetup."Basic IT" := TempApplicationAreaSetupBasic."Basic IT";
        TempApplicationAreaSetup."Basic MX" := TempApplicationAreaSetupBasic."Basic MX";
        TempApplicationAreaSetup."Basic NL" := TempApplicationAreaSetupBasic."Basic NL";
        TempApplicationAreaSetup."Basic NO" := TempApplicationAreaSetupBasic."Basic NO";
        TempApplicationAreaSetup."Basic NZ" := TempApplicationAreaSetupBasic."Basic NZ";
        TempApplicationAreaSetup."Basic RU" := TempApplicationAreaSetupBasic."Basic RU";
        TempApplicationAreaSetup."Basic SE" := TempApplicationAreaSetupBasic."Basic SE";
        TempApplicationAreaSetup."Basic US" := TempApplicationAreaSetupBasic."Basic US";
    end;
}