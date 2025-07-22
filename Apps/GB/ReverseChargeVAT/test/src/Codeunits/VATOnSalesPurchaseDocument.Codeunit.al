namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using System.TestLibraries.Utilities;

codeunit 144013 "VAT On Sales/Purchase Document"
{

    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        isInitialized: Boolean;

    [Test]
    procedure AddReverseChargeItemToSalesLine()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin
        // [FEATURE] [Sales] [Reverse Charge]
        // [SCENARIO 281088] "Reverse Charge Item" is TRUE in Sales Line when set Item with "Reverse Charge Applies" = TRUE
        Initialize();

        // [GIVEN] "Item" with "Reverse Charge Applies"=TRUE
        CreateItemReverseChargeApplies(Item);
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [WHEN] "Item" is added to "Sales Line" by "No."
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 0);

        // [THEN] "Sales Line"."Reverse charge item"=TRUE
        SalesLine.TestField("Reverse Charge Item GB", true);
    end;

    [Test]
    procedure ClearReverseChargeItemFromSalesLine()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin
        // [FEATURE] [Sales] [Reverse Charge]
        // [SCENARIO 281088] "Reverse Charge Item" is FALSE in Sales Line when "No." set to <blank>
        Initialize();

        // [GIVEN] "Item" with "Reverse Charge Applies"=TRUE
        CreateItemReverseChargeApplies(Item);
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [WHEN] "Item" is added to "Sales Line" by "No." and then removed
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 0);
        SalesLine.Validate("No.", '');

        // [THEN] "Sales Line"."Reverse charge item"=FALSE
        SalesLine.TestField("Reverse Charge Item GB", false);
    end;

    [Test]
    procedure AddGLAccountToSalesLine()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        GLAccountNo: Code[20];
    begin
        // [FEATURE] [Sales] [Reverse Charge]
        // [SCENARIO 281088] "Reverse Charge Item" is FALSE in Sales Line "Type" <> Item
        Initialize();

        // [GIVEN] "G/L Account"
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        GLAccountNo := LibraryERM.CreateGLAccountWithSalesSetup();

        // [WHEN] "G/L Account" is added to "Sales Line" by "No."
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccountNo, 0);

        // [THEN] "Sales Line"."Reverse charge item"=FALSE
        SalesLine.TestField("Reverse Charge Item GB", false);
    end;

    [Test]
    procedure CheckInvoiceWithReverseChargeItems()
    var
        Item: Record Item;
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesHeader: Record "Sales Header";
        InvoiceNo: Code[20];
    begin
        // [FEATURE] [Sales] [Reverse Charge]
        // [SCENARIO 281088] Reverse Charge VAT Entry created when post Sales Invoice with Reverse Charge Item and amount above threshold amount
        Initialize();

        // [GIVEN] Item "X" with "Reverse Charge Item" option enabled
        CreateItemReverseChargeApplies(Item);
        // [GIVEN] "Threshold Amount" is "N" in General Ledger Setup
        ModifyGLSetupReverseCharge(GLSetup);
        // [GIVEN] VAT Posting Setup with "Reverse Charge VAT" VAT Calculation Type
        CreateVATPostingSetupReverseCharge(Item."VAT Prod. Posting Group", VATPostingSetup);
        // [GIVEN] Customer with "VAT Bus. Posting Group" from VAT Posting Setup
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        // [GIVEN] "Reverse Charge VAT Posting Gr." in Sales Setup from VAT Posting Setup
        ModifySalesSetupReverseCharge(VATPostingSetup."VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
        // [GIVEN] Sales Invoice with Item "X" and amount > "N"
        CreateInvoiceWithReverseChargeItem(Item."No.", Customer."No.", GLSetup."Threshold Amount GB", SalesHeader);

        // [WHEN] Sales Invoice posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] VAT Entry created with "Reverse Charge VAT" posting setup
        VerifyVATEntryVATPostingGroupsAndType(VATPostingSetup, InvoiceNo);
    end;

    [Test]
    procedure AddItemToSalesLine()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin
        // [FEATURE] [Sales] [Reverse Charge]
        // [SCENARIO 281088] "Reverse Charge Item" is FALSE in Sales Line when set Item with "Reverse Charge Applies" = FALSE
        Initialize();

        // [GIVEN] "Item" with "Reverse Charge Applies"=FALSE
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [WHEN] "Item" is added to "Sales Line" by "No."
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 0);

        // [THEN] "Sales Line"."Reverse charge item"=FALSE
        SalesLine.TestField("Reverse Charge Item GB", false);
    end;

    local procedure Initialize()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();

        if isInitialized then
            exit;
        isInitialized := true;

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Return Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Return Receipt on Credit Memo", true);
        SalesReceivablesSetup.Validate("Posted Return Receipt Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        SalesReceivablesSetup.Modify(true);

        LibrarySetupStorage.Save(DATABASE::"Purchases & Payables Setup");
        LibrarySetupStorage.Save(DATABASE::"General Ledger Setup");
        LibrarySetupStorage.Save(DATABASE::"Sales & Receivables Setup");
    end;

    local procedure CreateItemReverseChargeApplies(var Item: Record Item)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Reverse Charge Applies GB", true);
        Item.Modify(true);
    end;

    local procedure CreateInvoiceWithReverseChargeItem(ItemNo: Code[20]; CustomerNo: Code[20]; GLThresholdAmount: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, LibraryRandom.RandInt(100));

        SalesLine.Validate("Unit Price", GLThresholdAmount + LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
    end;

    local procedure CreateVATPostingSetupReverseCharge(ItemVATProdPostingGroup: Code[20]; var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);

        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, ItemVATProdPostingGroup);

        VATPostingSetup.Validate("VAT Identifier", LibraryUtility.GenerateGUID());
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        VATPostingSetup.Modify(true);
    end;

    local procedure ModifySalesSetupReverseCharge(RevChVATBusPostingGroupCode: Code[20]; DomesticVATBusPostingGroupCode: Code[20])
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup.Validate("Reverse Charge VAT Post. Gr.", RevChVATBusPostingGroupCode);
        SalesSetup.Validate("Domestic Customers GB", DomesticVATBusPostingGroupCode);
        SalesSetup.Modify(true);
    end;

    local procedure ModifyGLSetupReverseCharge(var GLSetup: Record "General Ledger Setup")
    begin
        GLSetup.Get();
        GLSetup.Validate("Threshold applies GB", true);
        GLSetup.Validate("Threshold Amount GB", LibraryRandom.RandDec(100, 2));
        GLSetup.Modify(true);
    end;

    local procedure VerifyVATEntryVATPostingGroupsAndType(VATPostingSetup: Record "VAT Posting Setup"; InvoiceNo: Code[20])
    var
        VATEntry: Record "VAT Entry";
    begin
#pragma warning disable AA0210
        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
#pragma warning restore  AA0210
        VATEntry.SetRange("Document No.", InvoiceNo);
        VATEntry.FindFirst();
        VATEntry.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type");
        VATEntry.TestField("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATEntry.TestField("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
    end;
}

