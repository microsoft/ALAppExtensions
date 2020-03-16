codeunit 57601 "BF Experience Tier"
{
    // Workaround, Unfortunately it's pretty ugly solution.
    // EssentialTempApplicationAreaSetup

    SingleInstance = true; // Workaround

    var
        EssentialTempApplicationAreaSetup: Record "Application Area Setup" temporary; // Workaround

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', true, true)] // Workaround
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        Clear(EssentialTempApplicationAreaSetup); // Workaround
        EssentialTempApplicationAreaSetup := TempApplicationAreaSetup; // Workaround
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup")
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        Clear(EssentialTempApplicationAreaSetup); // Workaround
        ApplicationAreaMgmtFacade.IsEssentialExperienceEnabled(); // Workaround
        TempApplicationAreaSetup := EssentialTempApplicationAreaSetup; // Workaround

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