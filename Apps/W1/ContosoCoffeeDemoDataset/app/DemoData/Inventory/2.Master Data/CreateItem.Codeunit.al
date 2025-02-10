codeunit 5537 "Create Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateItem();
        CreateItemUnitOfMeasure();
        CreateItemSubstitution();
    end;

    local procedure CreateItem()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreateItemCategory: Codeunit "Create Item Category";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        ContosoUtilities: Codeunit "Contoso Utilities";
        TempBlob: Codeunit "Temp Blob";
        ImageFolderPathLbl: Label 'Images/Item', Locked = true;
    begin
        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + AthensDesk() + '.jpg');
        ContosoItem.InsertInventoryItem(AthensDesk(), AthensDeskLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 649.4, 506.6, '', 25, 39.79, 34.6, 1.2, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Desk());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + ParisGuestChairBlack() + '.jpg');
        ContosoItem.InsertInventoryItem(ParisGuestChairBlack(), ParisGuestChairBlackLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 125.1, 97.5, '', 50, 9.55, 8.3, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + AthensMobilePedestal() + '.jpg');
        ContosoItem.InsertInventoryItem(AthensMobilePedestal(), AthensMobilePedestalLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 281.4, 219.5, '', 25, 19.67, 17.1, 0.26, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Table());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + LondonSwivelChairBlue() + '.jpg');
        ContosoItem.InsertInventoryItem(LondonSwivelChairBlue(), LondonSwivelChairBlueLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 123.3, 96.1, '', 50, 15.99, 13.9, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + AntwerpConferenceTable() + '.jpg');
        ContosoItem.InsertInventoryItem(AntwerpConferenceTable(), AntwerpConferenceTableLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 420.4, 328, '', 15, 28.06, 24.4, 0.9, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Table());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + ConferenceBundle16() + '.jpg');
        ContosoItem.InsertInventoryItem(ConferenceBundle16(), ConferenceBundle16Lbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 122.5, 0, '', 50, 0, 0, 0, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), '');

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + AmsterdamLamp() + '.jpg');
        ContosoItem.InsertInventoryItem(AmsterdamLamp(), AmsterdamLampLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 35.6, 27.8, '', 45, 4.03, 3.5, 0.03, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Misc());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + ConferenceBundle18() + '.jpg');
        ContosoItem.InsertInventoryItem(ConferenceBundle18(), ConferenceBundle18Lbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 151.7, 0, '', 50, 0, 0, 0, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), '');

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + BerlingGuestChairYellow() + '.jpg');
        ContosoItem.InsertInventoryItem(BerlingGuestChairYellow(), BerlinGuestChairYellowLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 125.1, 97.5, '', 50, 9.55, 8.3, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + GuestSection1() + '.jpg');
        ContosoItem.InsertInventoryItem(GuestSection1(), GuestSection1Lbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 81.6, 0, '', 50, 0, 0, 0, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), '');

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + RomeGuestChairGreen() + '.jpg');
        ContosoItem.InsertInventoryItem(RomeGuestChairGreen(), RomeGuestChairGreenLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 125.1, 97.5, '', 50, 9.55, 8.3, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + TokyoGuestChairBlue() + '.jpg');
        ContosoItem.InsertInventoryItem(TokyoGuestChairBlue(), TokyoGuestChairBlueLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 125.1, 97.5, '', 50, 9.55, 8.3, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + ConferenceBundle28() + '.jpg');
        ContosoItem.InsertInventoryItem(ConferenceBundle28(), ConferenceBundle28Lbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 151.7, 0, '', 50, 0, 0, 0, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), '');

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + MexicoSwivelChairBlack() + '.jpg');
        ContosoItem.InsertInventoryItem(MexicoSwivelChairBlack(), MexicoSwivelChairBlackLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 123.3, 96.1, '', 50, 15.99, 13.9, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + ConferencePackage1() + '.jpg');
        ContosoItem.InsertInventoryItem(ConferencePackage1(), ConferencePackage1Lbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 221.8, 0, '', 50, 0, 0, 0, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), '');

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + MunichSwivelChairYellow() + '.jpg');
        ContosoItem.InsertInventoryItem(MunichSwivelChairYellow(), MunichSwivelChairYellowLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 123.3, 96.1, '', 50, 15.99, 13.9, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + MoscowSwivelChairRed() + '.jpg');
        ContosoItem.InsertInventoryItem(MoscowSwivelChairRed(), MoscowSwivelChairRedLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 123.3, 96.1, '', 50, 15.99, 13.9, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + SeoulGuestChairRed() + '.jpg');
        ContosoItem.InsertInventoryItem(SeoulGuestChairRed(), SeoulGuestChairRedLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 125.1, 97.5, '', 50, 9.55, 8.3, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + AtlantaWhiteboardBase() + '.jpg');
        ContosoItem.InsertInventoryItem(AtlantaWhiteboardBase(), AtlantAWhiteboardBaseLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 906.7, 707.2, '', 100, 80.27, 69.8, 0.31, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Misc());

        TempBlob := ContosoUtilities.GetTempBlobFromFile(ImageFolderPathLbl + '/' + SydneySwivelChairGreen() + '.jpg');
        ContosoItem.InsertInventoryItem(SydneySwivelChairGreen(), SydneySwivelChairGreenLbl, CreateUnitOfMeasure.Piece(), CreateInvPostingGroup.Resale(), 123.3, 96.1, '', 50, 15.99, 13.9, 0.25, '', CreatePostingGroup.RetailPostingGroup(), TempBlob, '', CreateVATPostingGroups.Standard(), CreateUnitOfMeasure.Piece(), CreateUnitOfMeasure.Piece(), CreateItemCategory.Chair());
    end;

    local procedure CreateItemUnitOfMeasure()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoInventory.SetOverwriteData(true);
        ContosoInventory.InsertItemUOM(AthensDesk(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(ParisGuestChairBlack(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(ParisGuestChairBlack(), CreateUnitOfMeasure.Set(), 4, 0);
        ContosoInventory.InsertItemUOM(AthensMobilePedestal(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(LondonSwivelChairBlue(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(LondonSwivelChairBlue(), CreateUnitOfMeasure.Set(), 6, 0);
        ContosoInventory.InsertItemUOM(AntwerpConferenceTable(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(ConferenceBundle16(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(AmsterdamLamp(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(ConferenceBundle18(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(BerlingGuestChairYellow(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(BerlingGuestChairYellow(), CreateUnitOfMeasure.Set(), 6, 0);
        ContosoInventory.InsertItemUOM(GuestSection1(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(RomeGuestChairGreen(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(RomeGuestChairGreen(), CreateUnitOfMeasure.Set(), 4, 0);
        ContosoInventory.InsertItemUOM(TokyoGuestChairBlue(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(TokyoGuestChairBlue(), CreateUnitOfMeasure.Set(), 6, 0);
        ContosoInventory.InsertItemUOM(ConferenceBundle28(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(MexicoSwivelChairBlack(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(MexicoSwivelChairBlack(), CreateUnitOfMeasure.Set(), 4, 0);
        ContosoInventory.InsertItemUOM(ConferencePackage1(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(MunichSwivelChairYellow(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(MunichSwivelChairYellow(), CreateUnitOfMeasure.Set(), 4, 0);
        ContosoInventory.InsertItemUOM(MoscowSwivelChairRed(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(MoscowSwivelChairRed(), CreateUnitOfMeasure.Set(), 6, 0);
        ContosoInventory.InsertItemUOM(SeoulGuestChairRed(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(SeoulGuestChairRed(), CreateUnitOfMeasure.Set(), 4, 0);
        ContosoInventory.InsertItemUOM(AtlantaWhiteboardBase(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(SydneySwivelChairGreen(), CreateUnitOfMeasure.Piece(), 1, 1);
        ContosoInventory.InsertItemUOM(SydneySwivelChairGreen(), CreateUnitOfMeasure.Set(), 6, 0);
        ContosoInventory.SetOverwriteData(false);
    end;

    local procedure CreateItemSubstitution()
    var
        ContosoItem: Codeunit "Contoso Item";
        SubstitutionType: Enum "Item Substitution Type";
    begin
        ContosoItem.InsertItemSubstitution(SubstitutionType::Item, MexicoSwivelChairBlack(), '', SubstitutionType::Item, MoscowSwivelChairRed(), '', MoscowSwivelChairRedLbl, false);
        ContosoItem.InsertItemSubstitution(SubstitutionType::Item, MoscowSwivelChairRed(), '', SubstitutionType::Item, SeoulGuestChairRed(), '', SeoulGuestChairRedLbl, true);
        ContosoItem.InsertItemSubstitution(SubstitutionType::Item, SeoulGuestChairRed(), '', SubstitutionType::Item, MoscowSwivelChairRed(), '', MoscowSwivelChairRedLbl, true);
    end;

    procedure AthensDesk(): Code[20]
    begin
        exit(AthensDeskTok);
    end;

    procedure ParisGuestChairBlack(): Code[20]
    begin
        exit(ParisGuestChairBlackTok);
    end;

    procedure AthensMobilePedestal(): Code[20]
    begin
        exit(AthensMobilePedestalTok);
    end;

    procedure LondonSwivelChairBlue(): Code[20]
    begin
        exit(LondonSwivelChairBlueTok);
    end;

    procedure AntwerpConferenceTable(): Code[20]
    begin
        exit(AntwerpConferenceTableTok);
    end;

    procedure ConferenceBundle16(): Code[20]
    begin
        exit(ConferenceBundle16Tok);
    end;

    procedure AmsterdamLamp(): Code[20]
    begin
        exit(AmsterdamLampTok);
    end;

    procedure ConferenceBundle18(): Code[20]
    begin
        exit(ConferenceBundle18Tok);
    end;

    procedure BerlingGuestChairYellow(): Code[20]
    begin
        exit(BerlinGuestChairYellowTok);
    end;

    procedure GuestSection1(): Code[20]
    begin
        exit(GuestSection1Tok);
    end;

    procedure RomeGuestChairGreen(): Code[20]
    begin
        exit(RomeGuestChairGreenTok);
    end;

    procedure TokyoGuestChairBlue(): Code[20]
    begin
        exit(TokyoGuestChairBlueTok);
    end;

    procedure ConferenceBundle28(): Code[20]
    begin
        exit(ConferenceBundle28Tok);
    end;

    procedure MexicoSwivelChairBlack(): Code[20]
    begin
        exit(MexicoSwivelChairBlackTok);
    end;

    procedure ConferencePackage1(): Code[20]
    begin
        exit(ConferencePackage1Tok);
    end;

    procedure MunichSwivelChairYellow(): Code[20]
    begin
        exit(MunichSwivelChairYellowTok);
    end;

    procedure MoscowSwivelChairRed(): Code[20]
    begin
        exit(MoscowSwivelChairRedTok);
    end;

    procedure SeoulGuestChairRed(): Code[20]
    begin
        exit(SeoulGuestChairRedTok);
    end;

    procedure AtlantaWhiteboardBase(): Code[20]
    begin
        exit(AtlantAWhiteboardBaseTok);
    end;

    procedure SydneySwivelChairGreen(): Code[20]
    begin
        exit(SydneySwivelChairGreenTok);
    end;

    var
        AthensDeskLbl: Label 'ATHENS Desk', Maxlength = 100;
        ParisGuestChairBlackLbl: Label 'PARIS Guest Chair, black', Maxlength = 100;
        AthensMobilePedestalLbl: Label 'ATHENS Mobile Pedestal', Maxlength = 100;
        LondonSwivelChairBlueLbl: Label 'LONDON Swivel Chair, blue', Maxlength = 100;
        AntwerpConferenceTableLbl: Label 'ANTWERP Conference Table', Maxlength = 100;
        ConferenceBundle16Lbl: Label 'Conference Bundle 1-6', Maxlength = 100;
        AmsterdamLampLbl: Label 'AMSTERDAM Lamp', Maxlength = 100;
        ConferenceBundle18Lbl: Label 'Conference Bundle 1-8', Maxlength = 100;
        BerlinGuestChairYellowLbl: Label 'BERLIN Guest Chair, yellow', Maxlength = 100;
        GuestSection1Lbl: Label 'Guest Section 1', Maxlength = 100;
        RomeGuestChairGreenLbl: Label 'ROME Guest Chair, green', Maxlength = 100;
        TokyoGuestChairBlueLbl: Label 'TOKYO Guest Chair, blue', Maxlength = 100;
        ConferenceBundle28Lbl: Label 'Conference Bundle 2-8', Maxlength = 100;
        MexicoSwivelChairBlackLbl: Label 'MEXICO Swivel Chair, black', Maxlength = 100;
        ConferencePackage1Lbl: Label 'Conference Package 1', Maxlength = 100;
        MunichSwivelChairYellowLbl: Label 'MUNICH Swivel Chair, yellow', Maxlength = 100;
        MoscowSwivelChairRedLbl: Label 'MOSCOW Swivel Chair, red', Maxlength = 100;
        SeoulGuestChairRedLbl: Label 'SEOUL Guest Chair, red', Maxlength = 100;
        AtlantAWhiteboardBaseLbl: Label 'ATLANTA Whiteboard, base', Maxlength = 100;
        SydneySwivelChairGreenLbl: Label 'SYDNEY Swivel Chair, green', Maxlength = 100;
        AthensDeskTok: Label '1896-S', Locked = true;
        ParisGuestChairBlackTok: Label '1900-S', Locked = true;
        AthensMobilePedestalTok: Label '1906-S', Locked = true;
        LondonSwivelChairBlueTok: Label '1908-S', Locked = true;
        AntwerpConferenceTableTok: Label '1920-S', Locked = true;
        ConferenceBundle16Tok: Label '1925-W', Locked = true;
        AmsterdamLampTok: Label '1928-S', Locked = true;
        ConferenceBundle18Tok: Label '1929-W', Locked = true;
        BerlinGuestChairYellowTok: Label '1936-S', Locked = true;
        GuestSection1Tok: Label '1953-W', Locked = true;
        RomeGuestChairGreenTok: Label '1960-S', Locked = true;
        TokyoGuestChairBlueTok: Label '1964-S', Locked = true;
        ConferenceBundle28Tok: Label '1965-W', Locked = true;
        MexicoSwivelChairBlackTok: Label '1968-S', Locked = true;
        ConferencePackage1Tok: Label '1969-W', Locked = true;
        MunichSwivelChairYellowTok: Label '1972-S', Locked = true;
        MoscowSwivelChairRedTok: Label '1980-S', Locked = true;
        SeoulGuestChairRedTok: Label '1988-S', Locked = true;
        AtlantAWhiteboardBaseTok: Label '1996-S', Locked = true;
        SydneySwivelChairGreenTok: Label '2000-S', Locked = true;
}
