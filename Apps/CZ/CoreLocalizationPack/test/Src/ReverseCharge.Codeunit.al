codeunit 148057 "Reverse Charge CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Reverse Charge]
        isInitialized := false;
    end;

    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Item: Record Item;
        CommodityCZL: Record "Commodity CZL";
        CommoditySetupCZL: Record "Commodity Setup CZL";
        VATPostingSetup: Record "VAT Posting Setup";
        UnitofMeasure: Record "Unit of Measure";
        TariffNumber: Record "Tariff Number";
        SalesLine: Record "Sales Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        SalesDocumentType: Enum "Sales Document Type";
        SalesLineType: Enum "Sales Line Type";
        TaxCalculationType: Enum "Tax Calculation Type";
        ReverseChargeCheckCZL: Enum "Reverse Charge Check CZL";
        VATPostingSetupPostMismatchErr: Label 'For commodity %1 and limit %2 not allowed VAT type %3 posting.\\Item List:\%4.', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = Item No.';
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Reverse Charge CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Reverse Charge CZL");

        CommodityCZL.Init();
        CommodityCZL.Code := CopyStr(LibraryRandom.RandText(2), 1, MaxStrLen(CommodityCZL.Code));
        CommodityCZL.Insert();

        CommoditySetupCZL.Init();
        CommoditySetupCZL."Commodity Code" := CommodityCZL.Code;
        CommoditySetupCZL."Valid From" := WorkDate();
        CommoditySetupCZL."Commodity Limit Amount LCY" := 100000;
        CommoditySetupCZL.Insert();

        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, TaxCalculationType::"Normal VAT", 21);
        VATPostingSetup."Reverse Charge Check CZL" := ReverseChargeCheckCZL::"Limit Check";
        VATPostingSetup.Modify();

        LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);
        TariffNumber.Init();
        TariffNumber."No." := CopyStr(LibraryRandom.RandText(3), 1, MaxStrLen(CommodityCZL.Code));
        TariffNumber."Statement Code CZL" := CommodityCZL.Code;
        TariffNumber."Statement Limit Code CZL" := CommodityCZL.Code;
        TariffNumber."VAT Stat. UoM Code CZL" := UnitofMeasure.Code;
        TariffNumber."Allow Empty UoM Code CZL" := false;
        TariffNumber.Insert();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Reverse Charge CZL");
    end;

    [Test]
    procedure ValidateSalesLineWithTariffNo()
    begin
        // [SCENARIO] Validate Item with Tariff No. in Sales Line
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Tariff No.", TariffNumber."No.");
        Item.Modify();
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, 1);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());

        // [WHEN] Create Sales Line with Item No. with filled Tariff No. value
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);
        SalesLine.Modify();

        // [THEN] Sales Line Tariff No. will have Item Tariff No.
        Assert.AreEqual(SalesLine."Tariff No. CZL", Item."Tariff No.", SalesLine.FieldCaption(SalesLine."Tariff No. CZL"));
    end;

    [Test]
    procedure PostSalesWithCommodityUnderLimit()
    begin
        // [SCENARIO] Post Sales Invoice with Commodity under limit
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Tariff No.", TariffNumber."No.");
        Item.Modify();
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, 1);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());

        // [GIVEN] Sales Line with Item No. with Unit Price bas been created
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);
        SalesLine.Validate("Unit Price", 200);
        SalesLine.Modify();

        // [WHEN] Post Sales Invoice
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, false);

        // [THEN] Error VAT Posting Setup Post Mismatch will occurs
        Assert.ExpectedError(StrSubstNo(VATPostingSetupPostMismatchErr, CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                             SalesLine."VAT Calculation Type"::"Normal VAT", Item."No."));
    end;
}
