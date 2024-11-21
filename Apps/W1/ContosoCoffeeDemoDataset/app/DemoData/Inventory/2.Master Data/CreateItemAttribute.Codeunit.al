codeunit 5393 "Create Item Attribute"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ContosoItem: Codeunit "Contoso Item";
        CreateItem: Codeunit "Create Item";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
    begin
        ItemAttribute := ContosoItem.InsertItemAttribute(ColorLbl, false, 0, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, RedLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AmsterdamLamp(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MoscowSwivelChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SeoulGuestChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, OrangeLbl, 0);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, YellowLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MunichSwivelChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, GreenLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SydneySwivelChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, BlueLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.LondonSwivelChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.TokyoGuestChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, VioletLbl, 0);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, PurpleLbl, 0);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, BlackLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensMobilePedestal(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MexicoSwivelChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, WhiteLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AntwerpConferenceTable(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AtlantaWhiteboardBase(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(DepthLbl, false, 3, CreateUnitOfMeasure.CM());
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV100Lbl, 100);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV75Lbl, 75);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MexicoSwivelChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensMobilePedestal(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV70Lbl, 70);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MunichSwivelChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SeoulGuestChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV80Lbl, 80);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SydneySwivelChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.LondonSwivelChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.TokyoGuestChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV300Lbl, 300);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AntwerpConferenceTable(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV30Lbl, 30);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AmsterdamLamp(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV40Lbl, 40);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV85Lbl, 85);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MoscowSwivelChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(WidthLbl, false, 3, CreateUnitOfMeasure.CM());
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV200Lbl, 200);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AtlantaWhiteboardBase(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV75Lbl, 75);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV80Lbl, 80);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.LondonSwivelChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV150Lbl, 150);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AntwerpConferenceTable(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV120Lbl, 120);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV90Lbl, 90);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.TokyoGuestChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SydneySwivelChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SeoulGuestChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MoscowSwivelChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MunichSwivelChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV95Lbl, 95);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MexicoSwivelChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(HeightLbl, false, 3, CreateUnitOfMeasure.CM());
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV95Lbl, 95);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV100Lbl, 100);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV90Lbl, 90);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensMobilePedestal(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV140Lbl, 140);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MoscowSwivelChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.LondonSwivelChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV130Lbl, 130);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AntwerpConferenceTable(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV60Lbl, 60);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AmsterdamLamp(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV115Lbl, 115);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV110Lbl, 110);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MunichSwivelChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SydneySwivelChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV125Lbl, 125);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.TokyoGuestChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV135Lbl, 135);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MexicoSwivelChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV120Lbl, 120);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SeoulGuestChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV250Lbl, 250);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AtlantaWhiteboardBase(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(MaterialDescriptionLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, WoodLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensMobilePedestal(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, LeatherSatinPolishedAluminumbaseLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, PlasticCottonLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.LondonSwivelChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, CottonWoodLegsLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AntwerpConferenceTable(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.TokyoGuestChairBlue(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, SteelLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AmsterdamLamp(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MexicoSwivelChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, CottonAluminiumLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, PlasticSteelLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AtlantaWhiteboardBase(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MunichSwivelChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, CottonPlasticSteelLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.MoscowSwivelChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, CottonSteellegsLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SydneySwivelChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.SeoulGuestChairRed(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(ModelYearLbl, false, 2, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV1952Lbl, 1952);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.ParisGuestChairBlack(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV1942Lbl, 1942);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensMobilePedestal(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV1940Lbl, 1940);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.BerlingGuestChairYellow(), ItemAttribute.ID, ItemAttributeValue.ID);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, AV1980Lbl, 1980);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.RomeGuestChairGreen(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(MaterialSurfaceLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, SolidoakLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(MaterialLegsLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, PolishedstainlesssteelLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(AdjustableheightLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, NoLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(AssemblyrequiredLbl, false, 0, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, YesLbl, 0);
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, NoLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(CablemanagementLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, MountablecabletrunkincludedLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);

        ItemAttribute := ContosoItem.InsertItemAttribute(CertificationsLbl, false, 1, '');
        ItemAttributeValue := ContosoItem.InsertItemAttributeValue(ItemAttribute, FSCLbl, 0);
        ContosoItem.InsertItemAttributeValueMapping(Database::Item, CreateItem.AthensDesk(), ItemAttribute.ID, ItemAttributeValue.ID);
    end;

    var
        ColorLbl: Label 'Color', MaxLength = 250;
        DepthLbl: Label 'Depth', MaxLength = 250;
        WidthLbl: Label 'Width', MaxLength = 250;
        HeightLbl: Label 'Height', MaxLength = 250;
        MaterialDescriptionLbl: Label 'Material Description', MaxLength = 250;
        ModelYearLbl: Label 'Model Year', MaxLength = 250;
        MaterialSurfaceLbl: Label 'Material (Surface)', MaxLength = 250;
        MaterialLegsLbl: Label 'Material (Legs)', MaxLength = 250;
        AdjustableheightLbl: Label 'Adjustable height', MaxLength = 250;
        AssemblyrequiredLbl: Label 'Assembly required', MaxLength = 250;
        CablemanagementLbl: Label 'Cable management', MaxLength = 250;
        CertificationsLbl: Label 'Certifications', MaxLength = 250;
        RedLbl: Label 'Red', MaxLength = 250;
        OrangeLbl: Label 'Orange', MaxLength = 250;
        YellowLbl: Label 'Yellow', MaxLength = 250;
        GreenLbl: Label 'Green', MaxLength = 250;
        BlueLbl: Label 'Blue', MaxLength = 250;
        VioletLbl: Label 'Violet', MaxLength = 250;
        PurpleLbl: Label 'Purple', MaxLength = 250;
        BlackLbl: Label 'Black', MaxLength = 250;
        WhiteLbl: Label 'White', MaxLength = 250;
        AV100Lbl: Label '100', MaxLength = 250, Locked = true;
        AV70Lbl: Label '70', MaxLength = 250, Locked = true;
        AV75Lbl: Label '75', MaxLength = 250, Locked = true;
        AV80Lbl: Label '80', MaxLength = 250, Locked = true;
        AV300Lbl: Label '300', MaxLength = 250, Locked = true;
        AV30Lbl: Label '30', MaxLength = 250, Locked = true;
        AV40Lbl: Label '40', MaxLength = 250, Locked = true;
        AV85Lbl: Label '85', MaxLength = 250, Locked = true;
        AV200Lbl: Label '200', MaxLength = 250, Locked = true;
        AV150Lbl: Label '150', MaxLength = 250, Locked = true;
        AV120Lbl: Label '120', MaxLength = 250, Locked = true;
        AV90Lbl: Label '90', MaxLength = 250, Locked = true;
        AV95Lbl: Label '95', MaxLength = 250, Locked = true;
        AV140Lbl: Label '140', MaxLength = 250, Locked = true;
        AV130Lbl: Label '130', MaxLength = 250, Locked = true;
        AV60Lbl: Label '60', MaxLength = 250, Locked = true;
        AV115Lbl: Label '115', MaxLength = 250, Locked = true;
        AV110Lbl: Label '110', MaxLength = 250, Locked = true;
        AV125Lbl: Label '125', MaxLength = 250, Locked = true;
        AV135Lbl: Label '135', MaxLength = 250, Locked = true;
        AV250Lbl: Label '250', MaxLength = 250, Locked = true;
        WoodLbl: Label 'Wood', MaxLength = 250;
        LeatherSatinPolishedAluminumbaseLbl: Label 'Leather, Satin Polished Aluminum base', MaxLength = 250;
        PlasticCottonLbl: Label 'Plastic, Cotton', MaxLength = 250;
        CottonWoodLegsLbl: Label 'Cotton, Wood Legs', MaxLength = 250;
        SteelLbl: Label 'Steel', MaxLength = 250;
        CottonAluminiumLbl: Label 'Cotton, Aluminium', MaxLength = 250;
        PlasticSteelLbl: Label 'Plastic, Steel', MaxLength = 250;
        CottonPlasticSteelLbl: Label 'Cotton, Plastic, Steel', MaxLength = 250;
        CottonSteellegsLbl: Label 'Cotton, Steel legs', MaxLength = 250;
        AV1952Lbl: Label '1952', MaxLength = 250, Locked = true;
        AV1942Lbl: Label '1942', MaxLength = 250, Locked = true;
        AV1940Lbl: Label '1940', MaxLength = 250, Locked = true;
        AV1980Lbl: Label '1980', MaxLength = 250, Locked = true;
        SolidoakLbl: Label 'Solid oak', MaxLength = 250, Locked = true;
        PolishedstainlesssteelLbl: Label 'Polished stainless steel', MaxLength = 250;
        NoLbl: Label 'No', MaxLength = 250;
        YesLbl: Label 'Yes', MaxLength = 250;
        MountablecabletrunkincludedLbl: Label 'Mountable cable trunk included', MaxLength = 250;
        FSCLbl: Label 'FSC', MaxLength = 250;
}