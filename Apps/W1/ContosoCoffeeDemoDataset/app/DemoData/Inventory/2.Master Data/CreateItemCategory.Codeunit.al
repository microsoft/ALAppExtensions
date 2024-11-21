codeunit 5380 "Create Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(Furniture(), OfficeFurnitureLbl, '');
        ContosoItem.InsertItemCategory(Chair(), OfficeChairLbl, Furniture());
        ContosoItem.InsertItemCategory(Desk(), OfficeDeskLbl, Furniture());
        ContosoItem.InsertItemCategory(Table(), AssortedTablesLbl, Furniture());

        ContosoItem.InsertItemCategory(Misc(), MiscellaneousLbl, '');
        ContosoItem.InsertItemCategory(Supplier(), OfficeSuppliesLbl, Misc());
    end;

    procedure Desk(): Code[20]
    begin
        exit(DeskTok);
    end;

    procedure Chair(): Code[20]
    begin
        exit(ChairTok);
    end;

    procedure Table(): Code[20]
    begin
        exit(TableTok);
    end;

    procedure Misc(): Code[20]
    begin
        exit(MiscTok);
    end;

    procedure Furniture(): Code[20]
    begin
        exit(FurnitureTok);
    end;

    procedure Supplier(): Code[20]
    begin
        exit(SuppliersTok);
    end;

    var
        DeskTok: Label 'DESK', MaxLength = 20;
        ChairTok: Label 'CHAIR', MaxLength = 20;
        TableTok: Label 'TABLE', MaxLength = 20;
        MiscTok: Label 'MISC', MaxLength = 20;
        FurnitureTok: Label 'FURNITURE', MaxLength = 20;
        SuppliersTok: Label 'SUPPLIERS', MaxLength = 20;
        OfficeFurnitureLbl: Label 'Office Furniture', MaxLength = 100;
        MiscellaneousLbl: Label 'Miscellaneous', MaxLength = 100;
        OfficeChairLbl: Label 'Office Chair', MaxLength = 100;
        OfficeDeskLbl: Label 'Office Desk', MaxLength = 100;
        OfficeSuppliesLbl: Label 'Office Supplies', MaxLength = 100;
        AssortedTablesLbl: Label 'Assorted Tables', MaxLength = 100;
}