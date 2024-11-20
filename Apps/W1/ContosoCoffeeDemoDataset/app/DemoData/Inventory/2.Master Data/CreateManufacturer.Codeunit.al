codeunit 5437 "Create Manufacturer"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoInventory.InsertManufacturer(Fabrik(), FabrikamResidencesLbl);
        ContosoInventory.InsertManufacturer(First(), FirstUpConsultantsLbl);
        ContosoInventory.InsertManufacturer(Lamna(), LamnaHealthcareLbl);
        ContosoInventory.InsertManufacturer(Northwind(), NorthwindTraderLbl);
        ContosoInventory.InsertManufacturer(Proseware(), ProsewareIncLbl);
        ContosoInventory.InsertManufacturer(Wingtip(), WingtipToysLbl);
    end;

    procedure Fabrik(): Code[10]
    begin
        exit(FabrikLbl);
    end;

    procedure First(): Code[10]
    begin
        exit(FirstLbl);
    end;

    procedure Lamna(): Code[10]
    begin
        exit(LamnaLbl);
    end;

    procedure Northwind(): Code[10]
    begin
        exit(NorthwindLbl);
    end;

    procedure Proseware(): Code[10]
    begin
        exit(ProsewareLbl);
    end;

    procedure Wingtip(): Code[10]
    begin
        exit(WingtipLbl);
    end;

    var
        FabrikLbl: Label 'FABRIK', MaxLength = 10;
        FirstLbl: Label 'FIRST', MaxLength = 10;
        LamnaLbl: Label 'LAMNA', MaxLength = 10;
        NorthwindLbl: Label 'NORTHWIND', MaxLength = 10;
        ProsewareLbl: Label 'PROSEWARE', MaxLength = 10;
        WingtipLbl: Label 'WINGTIP', MaxLength = 10;
        FabrikamResidencesLbl: Label 'Fabrikam Residences', MaxLength = 50;
        FirstUpConsultantsLbl: Label 'First Up Consultants', MaxLength = 50;
        LamnaHealthcareLbl: Label 'Lamna Healthcare Company', MaxLength = 50;
        NorthwindTraderLbl: Label 'Northwind Traders', MaxLength = 50;
        ProsewareIncLbl: Label 'Proseware, Inc.', MaxLength = 50;
        WingtipToysLbl: Label 'Wingtip Toys', MaxLength = 50;
}