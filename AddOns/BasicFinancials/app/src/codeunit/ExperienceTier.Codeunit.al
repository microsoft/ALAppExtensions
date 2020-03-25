codeunit 20602 "Experience Tier BF"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnValidateApplicationAreas', '', true, true)]
    local procedure OnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; TempApplicationAreaSetup: Record "Application Area Setup")
    var
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        TempApplicationAreaSetup.TestField("BF Orders", false);
        TempApplicationAreaSetup.TestField("BF Basic Financials", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup")
    var
        AppAreaMgmt: Codeunit "App Area Mgmt BF";
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        AppAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        DisableExperienceAppAreas(TempApplicationAreaSetup);
        GetBasicFinancialsExperienceAppAreas(TempApplicationAreaSetup);
        ApplicationAreasSet := true;
    end;

    local procedure GetBasicFinancialsExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        TempApplicationAreaSetup."BF Orders" := false;
        TempApplicationAreaSetup."BF Basic Financials" := true;
    end;

    local procedure DisableExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        TempApplicationAreaSetup."Relationship Mgmt" := false;
        TempApplicationAreaSetup.Assembly := false;
        TempApplicationAreaSetup."Item Charges" := false;
        TempApplicationAreaSetup.Intercompany := false;
        TempApplicationAreaSetup."Sales Return Order" := false;
        TempApplicationAreaSetup."Purch Return Order" := false;
        TempApplicationAreaSetup."Cost Accounting" := false;
        TempApplicationAreaSetup."Sales Budget" := false;
        TempApplicationAreaSetup."Purchase Budget" := false;
        TempApplicationAreaSetup."Item Budget" := false;
        TempApplicationAreaSetup."Sales Analysis" := false;
        TempApplicationAreaSetup."Purchase Analysis" := false;
        TempApplicationAreaSetup."Inventory Analysis" := false;
        TempApplicationAreaSetup."Item Tracking" := false;
        TempApplicationAreaSetup."Order Promising" := false;
        TempApplicationAreaSetup.Reservation := false;
        TempApplicationAreaSetup.ADCS := false;
    end;
}