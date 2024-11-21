codeunit 5237 "Create Resource"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoProjects: Codeunit "Contoso Projects";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoProjects.InsertResource(Katherine(), Enum::"Resource Type"::Person, KatherineHullLbl, DeerfieldRoadLbl, LondonLbl, ManagerLbl, ContosoUtilities.AdjustDate(18840525D), CreateUnitofMeasure.Hour(), 50, 10, 55, 45, 0, 100, CreatePostingGroup.ServicesPostingGroup(), N125XYLbl, CreateVATPostingGroups.Reduced());
        ContosoProjects.InsertResource(Lina(), Enum::"Resource Type"::Person, LinaTownsendLbl, WaterWayLbl, LondonLbl, DesignerLbl, ContosoUtilities.AdjustDate(18780101D), CreateUnitofMeasure.Hour(), 60, 10, 66, 45, 0, 120, CreatePostingGroup.ServicesPostingGroup(), N1634ZLbl, CreateVATPostingGroups.Reduced());
        ContosoProjects.InsertResource(Marty(), Enum::"Resource Type"::Person, MartyHorstLbl, ALittleJohnStreetLbl, LondonLbl, InstallerLbl, ContosoUtilities.AdjustDate(18750301D), CreateUnitofMeasure.Hour(), 45, 10, 49.5, 45, 0, 90, CreatePostingGroup.ServicesPostingGroup(), N125XYLbl, CreateVATPostingGroups.Reduced());
        ContosoProjects.InsertResource(Terry(), Enum::"Resource Type"::Person, TerryDoddsLbl, BJamesRoadLbl, LondonLbl, DesignerLbl, ContosoUtilities.AdjustDate(18750301D), CreateUnitofMeasure.Hour(), 50, 10, 55, 45, 0, 100, CreatePostingGroup.ServicesPostingGroup(), N125XYLbl, CreateVATPostingGroups.Reduced());
    end;

    procedure Katherine(): Code[20]
    begin
        exit(KatherineTok);
    end;

    procedure Lina(): Code[20]
    begin
        exit(LinaTok);
    end;

    procedure Marty(): Code[20]
    begin
        exit(MartyTok);
    end;

    procedure Terry(): Code[20]
    begin
        exit(TerryTok);
    end;

    var
        KatherineTok: Label 'KATHERINE', MaxLength = 20;
        LinaTok: Label 'LINA', MaxLength = 20;
        MartyTok: Label 'MARTY', MaxLength = 20;
        TerryTok: Label 'TERRY', MaxLength = 20;
        KatherineHullLbl: Label 'KATHERINE HULL', MaxLength = 100;
        LinaTownsendLbl: Label 'Lina Townsend', MaxLength = 100;
        MartyHorstLbl: Label 'Marty Horst', MaxLength = 100;
        TerryDoddsLbl: Label 'Terry Dodds', MaxLength = 100;
        DeerfieldRoadLbl: Label '10 Deerfield Road', MaxLength = 100;
        WaterWayLbl: Label '25 Water Way', MaxLength = 100;
        ALittleJohnStreetLbl: Label '49 A Little John Street', MaxLength = 100;
        BJamesRoadLbl: Label '66 B James Road', MaxLength = 100;
        LondonLbl: Label 'London', MaxLength = 30;
        ManagerLbl: Label 'Manager', MaxLength = 30;
        DesignerLbl: Label 'Designer', MaxLength = 30;
        InstallerLbl: Label 'Installer', MaxLength = 30;
        N125XYLbl: Label 'N12 5XY', MaxLength = 20;
        N1634ZLbl: Label 'N16 34Z', MaxLength = 20;
}