codeunit 5526 "Create BOM Component"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateItem: Codeunit "Create Item";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreateResource: Codeunit "Create Resource";
    begin
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle16(), 10000, Enum::"BOM Component Type"::Item, CreateItem.AntwerpConferenceTable(), AntwerpConferenceTableLbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle16(), 20000, Enum::"BOM Component Type"::Item, CreateItem.MexicoSwivelChairBlack(), MexicoSwivelChairblackLbl, CreateUnitOfMeasure.Piece(), 6);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle16(), 30000, Enum::"BOM Component Type"::Resource, CreateResource.Katherine(), InstallationLbl, CreateUnitOfMeasure.Hour(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle18(), 10000, Enum::"BOM Component Type"::Item, CreateItem.AntwerpConferenceTable(), AntwerpConferenceTableLbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle18(), 20000, Enum::"BOM Component Type"::Item, CreateItem.MexicoSwivelChairBlack(), MexicoSwivelChairblackLbl, CreateUnitOfMeasure.Piece(), 8);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle18(), 30000, Enum::"BOM Component Type"::Resource, CreateResource.Katherine(), InstallationLbl, CreateUnitOfMeasure.Hour(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.GuestSection1(), 10000, Enum::"BOM Component Type"::Item, CreateItem.RomeGuestChairGreen(), RomeGuestChairgreenLbl, CreateUnitOfMeasure.Piece(), 4);
        ContosoInventory.InsertBOMComponent(CreateItem.GuestSection1(), 20000, Enum::"BOM Component Type"::Item, CreateItem.AthensMobilePedestal(), AthensMobilePedestalLbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle28(), 10000, Enum::"BOM Component Type"::Item, CreateItem.AntwerpConferenceTable(), AntwerpConferenceTableLbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle28(), 20000, Enum::"BOM Component Type"::Item, CreateItem.SydneySwivelChairGreen(), SydneySwivelChairgreenLbl, CreateUnitOfMeasure.Piece(), 8);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferenceBundle28(), 30000, Enum::"BOM Component Type"::Resource, CreateResource.Katherine(), InstallationLbl, CreateUnitOfMeasure.Hour(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferencePackage1(), 10000, Enum::"BOM Component Type"::Item, CreateItem.ConferenceBundle28(), ConferenceBundle28Lbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferencePackage1(), 20000, Enum::"BOM Component Type"::Item, CreateItem.GuestSection1(), GuestSectionLbl, CreateUnitOfMeasure.Piece(), 1);
        ContosoInventory.InsertBOMComponent(CreateItem.ConferencePackage1(), 30000, Enum::"BOM Component Type"::Resource, CreateResource.Katherine(), InstallationLbl, CreateUnitOfMeasure.Hour(), 1);
    end;

    var
        InstallationLbl: Label 'Installation', MaxLength = 100;
        AthensMobilePedestalLbl: Label 'ATHENS Mobile Pedestal', Maxlength = 100;
        AntwerpConferenceTableLbl: Label 'ANTWERP Conference Table', Maxlength = 100;
        GuestSectionLbl: Label 'Guest Section 1', Maxlength = 100;
        RomeGuestChairgreenLbl: Label 'ROME Guest Chair, green', Maxlength = 100;
        ConferenceBundle28Lbl: Label 'Conference Bundle 2-8', Maxlength = 100;
        MexicoSwivelChairblackLbl: Label 'MEXICO Swivel Chair, black', Maxlength = 100;
        SydneySwivelChairgreenLbl: Label 'SYDNEY Swivel Chair, green', Maxlength = 100;
}