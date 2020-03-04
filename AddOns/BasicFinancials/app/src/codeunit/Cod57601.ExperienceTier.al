codeunit 57601 "BF Experience Tier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup")
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(ExperienceTierSetup.FieldCaption(Essential));
        ApplicationAreaMgmtFacade.GetApplicationAreaSetupRecFromCompany(TempApplicationAreaSetup, CompanyName());
        SetBasicFinancialsExperienceAppAreas(TempApplicationAreaSetup);
        ApplicationAreasSet := true;
    end;

    local procedure SetBasicFinancialsExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup")
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
        TempApplicationAreaSetup."BF Orders" := false;
        TempApplicationAreaSetup."BF Basic Financials" := true;
    end;
}