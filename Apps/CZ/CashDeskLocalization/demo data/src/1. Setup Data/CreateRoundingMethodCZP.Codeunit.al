#pragma warning disable AA0247
codeunit 31341 "Create Rounding Method CZP"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCashDeskCZP: Codeunit "Contoso Cash Desk CZP";
    begin
        ContosoCashDeskCZP.InsertRoundingMethod(Crowns(), 0, 1, RoundingType::Up);
    end;

    procedure Crowns(): Code[10]
    begin
        exit(CrownsLbl);
    end;

    var
        CrownsLbl: Label 'Crowns', MaxLength = 10;
        RoundingType: Option Nearest,Up,Down;
}
