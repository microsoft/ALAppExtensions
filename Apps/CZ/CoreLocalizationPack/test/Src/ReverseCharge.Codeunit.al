codeunit 148057 "Reverse Charge CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
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
        isInitialized: Boolean;
        VATPostingSetupPostMismashErr: Label 'For commodity %1 and limit %2 not allowed VAT type %3 posting.\\Item List:\%4.', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = Item No.';

    local procedure Initialize();
    begin
        LibraryRandom.Init();
        if isInitialized then
            exit;

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Default VAT Date CZL" := SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date";
        SalesReceivablesSetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    procedure ReverseChargeLimitCheck()
    begin
        // [FEATURE] Change Posting Group
        Initialize();

        // [GIVEN] New VAT Posting Setup created
        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, TaxCalculationType::"Normal VAT", 21);
        VATPostingSetup."Reverse Charge Check CZL" := ReverseChargeCheckCZL::"Limit Check";
        VATPostingSetup.Modify();

        // [GIVEN] New Commodity and Commodity Setup
        CommodityCZL.Init();
        CommodityCZL.Code := CopyStr(LibraryRandom.RandText(2), 1, MaxStrLen(CommodityCZL.Code));
        CommodityCZL.Insert();

        CommoditySetupCZL.Init();
        CommoditySetupCZL."Commodity Code" := CommodityCZL.Code;
        CommoditySetupCZL."Valid From" := Today();
        CommoditySetupCZL."Commodity Limit Amount LCY" := 100000;
        CommoditySetupCZL.Insert();

        // [GIVEN] Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);

        // [GIVEN] New Tariff Number
        TariffNumber.Init();
        TariffNumber."No." := CopyStr(LibraryRandom.RandText(3), 1, MaxStrLen(CommodityCZL.Code));
        TariffNumber."Statement Code CZL" := CommodityCZL.Code;
        TariffNumber."Statement Limit Code CZL" := CommodityCZL.Code;
        TariffNumber."VAT Stat. UoM Code CZL" := UnitofMeasure.Code;
        TariffNumber."Allow Empty UoM Code CZL" := false;
        TariffNumber.Insert();

        // [GIVEN] New Customer
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify();

        // [GIVEN] New Item        
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Tariff No.", TariffNumber."No.");
        Item.Modify();
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, 1);

        // [GIVEN] New Sales Invoice
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", Today());

        // [WHEN] Create Sales Line with Item No. with filled Tariff No. value.
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);
        SalesLine.Validate("Unit Price", 200);
        SalesLine.Modify();

        // [THEN] Sales Line Tariff No. has Item Tariff No.
        Assert.AreEqual(SalesLine."Tariff No. CZL", Item."Tariff No.", SalesLine.FieldCaption(SalesLine."Tariff No. CZL"));

        // [WHEN] Sales Invoice Post   
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, false);

        // [THEN] Expected Error Message VatPostingSetupPostMismashErr
        Assert.ExpectedError(StrSubstNo(VATPostingSetupPostMismashErr, CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                          SalesLine."VAT Calculation Type"::"Normal VAT", Item."No."));
    end;
}
