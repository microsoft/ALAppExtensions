codeunit 5664 "Create Item Reference"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateItem: Codeunit "Create Item";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendor: Codeunit "Create Vendor";
    begin
        ContosoItem.InsertItemReference(CreateItem.LondonSwivelChairBlue(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Customer, CreateCustomer.DomesticRelecloud(), RefernceNoC100425Tok, ArmlessSwivelChairBlueLbl);
        ContosoItem.InsertItemReference(CreateItem.LondonSwivelChairBlue(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Vendor, CreateVendor.ExportFabrikam(), LondonSwivelChairBlueLbl, '');
        ContosoItem.InsertItemReference(CreateItem.LondonSwivelChairBlue(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Vendor, CreateVendor.DomesticFirstUp(), LondonSwivelChairBlueLbl, '');
        ContosoItem.InsertItemReference(CreateItem.LondonSwivelChairBlue(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Vendor, CreateVendor.EUGraphicDesign(), RefernceNoBlueSwivelTok, BlueArmlessSwivelChairLbl);
        ContosoItem.InsertItemReference(CreateItem.AmsterdamLamp(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Customer, CreateCustomer.ExportSchoolofArt(), RefernceNoSwivelLampTok, RedSwivelLampLbl);
        ContosoItem.InsertItemReference(CreateItem.AmsterdamLamp(), '', CreateUnitOfMeasure.Piece(), Enum::"Item Reference Type"::Vendor, CreateVendor.DomesticNodPublisher(), RefernceNoD200552Tok, DeskSwivelLampLbl);
    end;

    var
        RefernceNoC100425Tok: Label 'C100425', Locked = true;
        RefernceNoBlueSwivelTok: Label 'BLUESWIVEL', Locked = true;
        RefernceNoSwivelLampTok: Label 'SWIVELLAMP', Locked = true;
        RefernceNoD200552Tok: Label 'D200552', Locked = true;
        LondonSwivelChairBlueLbl: Label '1908-S', Locked = true;
        ArmlessSwivelChairBlueLbl: Label 'Armless swivel chair, blue', MaxLength = 100;
        BlueArmlessSwivelChairLbl: Label 'Blue armless swivel chair', MaxLength = 100;
        RedSwivelLampLbl: Label 'Red Swivel Lamp', MaxLength = 100;
        DeskSwivelLampLbl: Label 'Desk Swivel Lamp', MaxLength = 100;
}