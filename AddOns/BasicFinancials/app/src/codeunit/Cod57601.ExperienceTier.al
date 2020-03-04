codeunit 57601 "BF Experience Tier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', true, true)]
    local procedure SetApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; var ApplicationAreasSet: Boolean; var TempApplicationAreaSetup: Record "Application Area Setup")
    begin
        if not ExperienceTierSetup."BF Basic Financials" then
            exit;

        TempApplicationAreaSetup.Basic := true;
        TempApplicationAreaSetup.Suite := true;
        TempApplicationAreaSetup."Relationship Mgmt" := false;
        TempApplicationAreaSetup.Jobs := true;
        TempApplicationAreaSetup."Fixed Assets" := true;
        TempApplicationAreaSetup.Location := true;
        TempApplicationAreaSetup.BasicHR := true;
        TempApplicationAreaSetup.Assembly := false;
        TempApplicationAreaSetup."Item Charges" := false;
        TempApplicationAreaSetup.Advanced := false;
        TempApplicationAreaSetup.Warehouse := true;
        TempApplicationAreaSetup.Service := false;
        TempApplicationAreaSetup.Manufacturing := false;
        TempApplicationAreaSetup.Planning := true;
        TempApplicationAreaSetup.Dimensions := true;
        TempApplicationAreaSetup."Item Tracking" := false;
        TempApplicationAreaSetup.Intercompany := false;
        TempApplicationAreaSetup."Sales Return Order" := false;
        TempApplicationAreaSetup."Purch Return Order" := false;
        TempApplicationAreaSetup.Prepayments := true;
        TempApplicationAreaSetup."Cost Accounting" := false;
        TempApplicationAreaSetup."Sales Budget" := false;
        TempApplicationAreaSetup."Purchase Budget" := false;
        TempApplicationAreaSetup."Item Budget" := false;
        TempApplicationAreaSetup."Sales Analysis" := false;
        TempApplicationAreaSetup."Purchase Analysis" := false;
        TempApplicationAreaSetup."Inventory Analysis" := false;
        TempApplicationAreaSetup.XBRL := true;
        TempApplicationAreaSetup.Reservation := false;
        TempApplicationAreaSetup."Order Promising" := false;
        TempApplicationAreaSetup.ADCS := false;
        TempApplicationAreaSetup.Comments := true;
        TempApplicationAreaSetup."BF Basic Financials" := true;
        TempApplicationAreaSetup."BF Orders" := false;

        ApplicationAreasSet := true;
    end;
}
