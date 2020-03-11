codeunit 57601 "BF Experience Tier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup")
    var
    //ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        //>> TEST
        //ApplicationAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        //<< TEST
        DisableExperienceAppAreas(TempApplicationAreaSetup);
        GetBasicFinancialsExperienceAppAreas(TempApplicationAreaSetup);
        ApplicationAreasSet := true;
    end;

    local procedure DisableExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
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

    local procedure GetBasicFinancialsExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."BF Orders" := false;
        TempApplicationAreaSetup."BF Basic Financials" := true;
    end;

    local procedure GetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.Basic := true;
        TempApplicationAreaSetup.VAT := true;
        TempApplicationAreaSetup."Basic EU" := true;
        TempApplicationAreaSetup."Basic DK" := true;
        TempApplicationAreaSetup."Relationship Mgmt" := true;
        TempApplicationAreaSetup."Record Links" := true;
        TempApplicationAreaSetup.Notes := true;
    end;

    local procedure GetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        GetBasicExperienceAppAreas(TempApplicationAreaSetup);
        TempApplicationAreaSetup.Suite := true;
        TempApplicationAreaSetup.Jobs := true;
        TempApplicationAreaSetup."Fixed Assets" := true;
        TempApplicationAreaSetup.Location := true;
        TempApplicationAreaSetup.BasicHR := true;
        TempApplicationAreaSetup.Assembly := true;
        TempApplicationAreaSetup."Item Charges" := true;
        TempApplicationAreaSetup.Intercompany := true;
        TempApplicationAreaSetup."Sales Return Order" := true;
        TempApplicationAreaSetup."Purch Return Order" := true;
        TempApplicationAreaSetup.Prepayments := true;
        TempApplicationAreaSetup."Cost Accounting" := true;
        TempApplicationAreaSetup."Sales Budget" := true;
        TempApplicationAreaSetup."Purchase Budget" := true;
        TempApplicationAreaSetup."Item Budget" := true;
        TempApplicationAreaSetup."Sales Analysis" := true;
        TempApplicationAreaSetup."Purchase Analysis" := true;
        TempApplicationAreaSetup."Inventory Analysis" := true;
        TempApplicationAreaSetup."Item Tracking" := true;
        TempApplicationAreaSetup.Warehouse := true;
        TempApplicationAreaSetup.XBRL := true;
        TempApplicationAreaSetup."Order Promising" := true;
        TempApplicationAreaSetup.Reservation := true;
        TempApplicationAreaSetup.Dimensions := true;
        TempApplicationAreaSetup.ADCS := true;
        TempApplicationAreaSetup.Planning := true;
        TempApplicationAreaSetup.Comments := true;
    end;
}