codeunit 139854 "APIV2 - Item Ledg. Entries E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Item Ledger Entry]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'itemLedgerEntries';

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryApplicationArea.EnableFoundationSetup();
        if IsInitialized then
            exit;

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetItemLedgerEntries()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntryNo: Integer;
        TargetURL: Text;
        ResponseText: Text;
        ItemLedgerEntryEntryId: Text;
    begin
        // [SCENARIO] Create entries and use a GET method to retrieve them
        Initialize();

        // [WHEN] Create an Item Ledger Entry
        ItemLedgerEntryNo := CreateItemLedgerEntry(ItemLedgerEntry, WorkDate(), CreateItem(), LibraryRandom.RandInt(10), ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.Get(ItemLedgerEntryNo);
        ItemLedgerEntryEntryId := Format(ItemLedgerEntry.SystemId);


        // [WHEN] we GET all the entries from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemLedgerEntry.SystemId, Page::"APIV2 - Item Ledger Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', ItemLedgerEntryEntryId),
          'Could not find item ledger entry');
    end;

    local procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItemWithTariffNo(Item, LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"));
        exit(Item."No.");
    end;

    local procedure CreateItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; PostingDate: Date; ItemNo: Code[20]; Quantity: Decimal; ILEEntryType: Enum "Item Ledger Entry Type"): Integer
    var
        ItemLedgerEntryNo: Integer;
    begin
        ItemLedgerEntryNo := LibraryUtility.GetNewRecNo(ItemLedgerEntry, ItemLedgerEntry.FieldNo("Entry No."));
        Clear(ItemLedgerEntry);
        ItemLedgerEntry."Entry No." := ItemLedgerEntryNo;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Entry Type" := ILEEntryType;
        ItemLedgerEntry.Quantity := Quantity;
        ItemLedgerEntry."Country/Region Code" := GetCountryRegionCode();
        ItemLedgerEntry.Insert();
        exit(ItemLedgerEntryNo);
    end;

    local procedure GetCountryRegionCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CountryRegion.SetFilter(Code, '<>%1', CompanyInformation."Country/Region Code");
        CountryRegion.SetFilter("Intrastat Code", '<>''''');
        CountryRegion.FindFirst();
        exit(CountryRegion.Code);
    end;
}















