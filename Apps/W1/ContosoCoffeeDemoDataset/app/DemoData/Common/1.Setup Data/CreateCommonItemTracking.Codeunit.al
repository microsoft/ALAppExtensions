codeunit 5144 "Create Common Item Tracking"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemTrackingCode(LotSpecificTrackingCode(), LOTWMSpecifictrackingLbl, false, true, false, false, false, false);
        ContosoItem.InsertItemTrackingCode(SNSpecificTrackingCode(), SNProdSpecificTrackingLbl, true, false, false, false, false, false);
    end;

    var
        SNProdTok: Label 'SN-PROD', MaxLength = 10;
        SNProdSpecificTrackingLbl: Label 'SN specific tracking for manufacturing', MaxLength = 50;
        LOTWMSTok: Label 'LOTALLEXP', MaxLength = 10;
        LOTWMSpecifictrackingLbl: Label 'Lot specific tracking for warehouse', MaxLength = 50;

    procedure LotSpecificTrackingCode(): Code[10]
    begin
        exit(LOTWMSTok);
    end;

    procedure SNSpecificTrackingCode(): Code[10]
    begin
        exit(SNProdTok);
    end;
}