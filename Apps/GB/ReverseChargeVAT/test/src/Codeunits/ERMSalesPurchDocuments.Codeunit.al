namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using System.TestLibraries.Utilities;
using Microsoft.Purchases.History;

codeunit 144012 "ERM Sales Purch Documents"
{

    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        isInitialized: Boolean;
        ReverseChargeErr: Label '%1 must be %2 in %3.', comment = '%1 = Field caption, %2 = Decimal, %3 = Table caption';
        ReverseErr: Label 'VAT Bus. Posting Group cannot be %1. Item %2 is not subjected to Reverse Charge in Sales Line Document Type=''%3'',Document No.=''%4'',Line No.=''%5''.',
            Comment = '%1=VAT Bus. Posting Group ,%2=Item No. ,%3=Document Type ,%4=Document No. , %5=Line No.';

    [Test]
    procedure ReverseChargeOnPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // Purpose of this test is to hit Reverse Charge OnRun Trigger of Codeunit - 90 Purch.-Post.

        // Setup: Create and Post Purchase Invoice with Reverse Charge VAT.
        Initialize();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        UpdatePurchasesPayablesSetup(VATPostingSetup."VAT Bus. Posting Group");
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CreateVendor(VATPostingSetup."VAT Bus. Posting Group"),
          CreateItem(VATPostingSetup."VAT Prod. Posting Group"));
        FindPurchaseLine(PurchaseLine, PurchaseHeader."Document Type", PurchaseHeader."No.");

        // Exercise.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // Verify: Verify Reverse Charge on Purchase Invoice.
        VerifyReverseChargeOnPostedPurchaseInvoice(PurchaseLine);
    end;

    [Test]
    procedure ReverseChargeOnPostedSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Purpose of this test is to verify Reverse Charge Amount on Posted Sales Invoice Line.

        // Setup: Create and Post Sales Invoice with Reverse Charge VAT.
        Initialize();
        SetupForSalesDocumentWithRevCharge(SalesHeader, SalesHeader."Document Type"::Invoice);
        FindSalesLine(SalesLine, SalesHeader."Document Type", SalesHeader."No.");

        // Exercise.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Reverse Charge on Sales Invoice.
        VerifyReverseChargeOnPostedSalesInvoice(SalesLine, SalesLine."Reverse Charge Item GB");
    end;

    [Test]
    procedure ReverseChargeOnPostedSalesInvoiceWithPrepayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Purpose of this test is to verify Reverse Charge Amount on Posted Sales Invoice Line with partial Prepayment.

        // Setup: Create and Post Sales Order with Reverse Charge VAT.
        Initialize();
        SetupForSalesDocumentWithRevCharge(SalesHeader, SalesHeader."Document Type"::Order);
        UpdateSalesHeaderPrepaymentPct(SalesHeader);
        FindSalesLine(SalesLine, SalesHeader."Document Type", SalesHeader."No.");

        // Exercise.
        LibrarySales.PostSalesPrepaymentInvoice(SalesHeader);

        // Verify: Verify Reverse Charge on Sales Invoice.
        VerifyReverseChargeOnPostedSalesInvoice(SalesLine, false);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTRUE')]
    procedure ChangeDocumentVatBusPostingGroupForDocumentWithReverseChargeItem()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
    begin
        // [SCENARIO 381636] Change "VAT Bus. Posting Group" in Purchase Header to Posting Group with "Reverse Charge VAT"
        Initialize();

        // [GIVEN] Found VAT Posting Setup with "Reverse Charge VAT"
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify(true);

        // [GIVEN] Edited "Purchases & Payables Setup"
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Reverse Charge VAT Post. Gr.", VATPostingSetup."VAT Bus. Posting Group");
        PurchasesPayablesSetup.Validate("Domestic Vendors GB", VATPostingSetup."VAT Bus. Posting Group");
        PurchasesPayablesSetup.Modify(true);

        // [GIVEN] Created Purchase Order using VAT Posting Setup
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [GIVEN] Set "Reverse Charge Applies" to true for created Item
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        Item.Get(PurchaseLine."No.");
        Item.Validate("Reverse Charge Applies GB", true);
        Item.Modify(true);

        // [WHEN] Change "VAT Bus. Posting Group" in Purchase Header to value from VAT Posting Setup
        PurchaseHeader.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        PurchaseHeader.Modify(true);

        // [THEN] "VAT Bus. Posting Group" is changed without error
        PurchaseHeader.TestField("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTRUE')]
    procedure RunPostingPreviewForDocumentWithReverseChargeItem()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GLPostingPreview: TestPage "G/L Posting Preview";
    begin
        // [FEATURE] [Reverse Charge]
        // [SCENARIO 380707] Run Posting Preview for document with "Reverse Charge Item" and validated "Reverse Charge VAT Posting Gr." in Purchase Setup
        Initialize();

        // [GIVEN] Created VAT Posting Setup with "Reverse Charge VAT"
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT", 20);
        VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify(true);

        // [GIVEN] Edited "Purchases & Payables Setup". Set "Reverse Charge VAT Posting Gr." and "Domestic Vendors" to value from VAT Posting Setup.
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Reverse Charge VAT Post. Gr.", VATPostingSetup."VAT Bus. Posting Group");
        PurchasesPayablesSetup.Validate("Domestic Vendors GB", VATPostingSetup."VAT Bus. Posting Group");
        PurchasesPayablesSetup.Modify(true);

        // [GIVEN] Created Purchase Order using VAT Posting Setup
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [GIVEN] Edited "Reverse Charge Applies" to True in Item
        FindPurchaseLine(PurchaseLine, PurchaseHeader."Document Type", PurchaseHeader."No.");
        Item.Get(PurchaseLine."No.");
        Item.Validate("Reverse Charge Applies GB", true);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);

        PurchaseHeader.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        PurchaseHeader.Modify(true);
        Commit();

        // [WHEN] Run "Preview Posing" for created order
        GLPostingPreview.Trap();
        asserterror LibraryPurchase.PreviewPostPurchaseDocument(PurchaseHeader);

        // [THEN] No errors occured - preview mode error only
        // [THEN] Status is equal to "Open" in Purchase Header
        Assert.ExpectedError('');
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
        GLPostingPreview.Close();
    end;

    [Test]
    procedure ErrorMessageOnSalesLineReverseChargeVAT()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO 548073] Error Message appear if line with Reverse Charge VAT in Sales Order.
        Initialize();

        // [GIVEN] Create VAT Posting Setup.
        CreateVATPostingSetupWithBlankVATBusPostingGroup(VATPostingSetup);

        // [GIVEN] Validate Reverse Charge Vat Posting Group in Sales and Receivables Setup.
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Reverse Charge VAT Post. Gr.", VATPostingSetup."VAT Bus. Posting Group");
        SalesReceivablesSetup.Modify(true);

        // [GIVEN] Create a Sales Header of type Order.
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CreateCustomer(VATPostingSetup));

        // [GIVEN] Create an Item.
        Item.Get(LibraryInventory.CreateItemNo());

        // [GIVEN] Create a Sales Line and Validate Type.
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::Item);

        // [WHEN] Validate Item No. in Sales Line.
        asserterror SalesLine.Validate("No.", Item."No.");

        // [THEN] Error is thrown when line is Reverse Charge VAT.
        Assert.ExpectedError(
            StrSubstNo(
                ReverseErr,
                SalesLine."VAT Bus. Posting Group",
                Item."No.",
                SalesLine."Document Type",
                SalesLine."Document No.",
                SalesLine."Line No."));
    end;

    local procedure Initialize()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"ERM Sales Purch Documents");
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;

        PurchaseHeader.DontNotifyCurrentUserAgain(PurchaseHeader.GetModifyVendorAddressNotificationId());
        PurchaseHeader.DontNotifyCurrentUserAgain(PurchaseHeader.GetModifyPayToVendorAddressNotificationId());

        isInitialized := true;
        Commit();
        LibrarySetupStorage.Save(DATABASE::"Purchases & Payables Setup");
    end;

    local procedure CreateCustomer(VATBusPostingGroup: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Validate("Reverse Charge Applies GB", true);
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyFromVendorNo: Code[20]; No: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, BuyFromVendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, No, LibraryRandom.RandDec(10, 2));  // Use Random value for Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(10, 2));  // Use Random value for Direct Unit Cost.
        PurchaseLine.Modify(true);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; SellToCustomerNo: Code[20]; No: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, SellToCustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, No, LibraryRandom.RandDec(10, 2));  // Use Random value for Quantity.
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10, 2));  // Use Random value for Unit Price.
        SalesLine.Modify(true);
    end;

    local procedure CreateVendor(VATBusPostingGroup: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure FindPurchaseLine(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    begin
        PurchaseLine.SetRange("Document Type", DocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.FindFirst();
    end;

    local procedure FindSalesLine(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    begin
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.FindFirst();
    end;

    local procedure SetupForSalesDocumentWithRevCharge(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        UpdateSalesReceivableSetup(VATPostingSetup."VAT Bus. Posting Group");
        CreateSalesDocument(
          SalesHeader, DocumentType, CreateCustomer(VATPostingSetup."VAT Bus. Posting Group"),
          CreateItem(VATPostingSetup."VAT Prod. Posting Group"));
    end;

    local procedure UpdateSalesHeaderPrepaymentPct(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("Prepayment %", LibraryRandom.RandDec(10, 2));  // Taken random for Prepayment Pct.
        SalesHeader.Modify(true);
    end;

    local procedure UpdatePurchasesPayablesSetup(DomesticVendors: Code[20])
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Domestic Vendors GB", DomesticVendors);
        PurchasesPayablesSetup.Validate("Reverse Charge VAT Post. Gr.", PurchasesPayablesSetup."Domestic Vendors GB");
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure UpdateSalesReceivableSetup(DomesticCustomers: Code[20])
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Domestic Customers GB", DomesticCustomers);
        SalesReceivablesSetup.Validate("Reverse Charge VAT Post. Gr.", SalesReceivablesSetup."Domestic Customers GB");
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure VerifyReverseChargeOnPostedPurchaseInvoice(PurchaseLine: Record "Purchase Line")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        ReverseCharge: Decimal;
    begin
        ReverseCharge := PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;
        PurchInvLine.SetRange("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchInvLine.FindFirst();
        PurchInvLine.TestField("No.", PurchaseLine."No.");
        PurchInvLine.TestField("Reverse Charge Item GB", PurchaseLine."Reverse Charge Item GB");
        Assert.AreNearlyEqual(
          ReverseCharge, PurchInvLine."Reverse Charge GB", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(ReverseChargeErr, PurchInvLine.FieldCaption("Reverse Charge GB"), ReverseCharge, PurchInvLine.TableCaption()));
    end;

    local procedure VerifyReverseChargeOnPostedSalesInvoice(SalesLine: Record "Sales Line"; ReverseChargeItem: Boolean)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        ReverseCharge: Decimal;
    begin
        ReverseCharge := SalesLine."Amount Including VAT" - SalesLine.Amount;
        SalesInvoiceLine.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");
        SalesInvoiceLine.FindFirst();
        SalesInvoiceLine.TestField("Reverse Charge Item GB", ReverseChargeItem);
        Assert.AreNearlyEqual(
          ReverseCharge, SalesInvoiceLine."Reverse Charge GB", LibraryERM.GetAmountRoundingPrecision(),
          StrSubstNo(ReverseChargeErr, SalesInvoiceLine.FieldCaption("Reverse Charge GB"), ReverseCharge, SalesInvoiceLine.TableCaption()));
    end;

    local procedure CreateVATPostingSetupWithBlankVATBusPostingGroup(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, '', VATProductPostingGroup.Code); // Set VAT Bus. Posting Group to blank.
        VATPostingSetup.Validate("VAT Identifier", VATPostingSetup."VAT Prod. Posting Group");
        VATPostingSetup.Validate("VAT %", LibraryRandom.RandInt(10));
        VATPostingSetup.Validate("Purchase VAT Account", GLAccount."No.");
        VATPostingSetup.Validate("Sales VAT Account", GLAccount."No.");
        VATPostingSetup.Modify(true);
    end;

    local procedure CreateCustomer(var VATPostingSetup: Record "VAT Posting Setup"): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerTRUE(Question: Text[1024]; var Confirm: Boolean)
    begin
        Confirm := true;
    end;
}

