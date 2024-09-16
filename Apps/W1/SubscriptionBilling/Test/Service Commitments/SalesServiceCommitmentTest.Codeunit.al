namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.BOM;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.Setup;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Request;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Archive;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Ledger;
#if not CLEAN25
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.VAT.Calculation;
#endif

codeunit 139915 "Sales Service Commitment Test"
{
    Subtype = Test;
    Access = Internal;

    var
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommitmentPackage1: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommPackageLine1: Record "Service Comm. Package Line";
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesServiceCommitment2: Record "Sales Service Commitment";
        Item: Record Item;
        Item2: Record Item;
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        Customer: Record Customer;
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        SalesLine: Record "Sales Line";
        SalesOrder: Record "Sales Header";
        Currency: Record Currency;
        CustomerPriceGroup1: Record "Customer Price Group";
        CustomerPriceGroup2: Record "Customer Price Group";
        CurrExchRate: Record "Currency Exchange Rate";
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        GLEntry: Record "G/L Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        Purchasing: Record Purchasing;
        Vendor: Record Vendor;
        RequisitionLine: Record "Requisition Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        BOMComponent: Record "BOM Component";
        WarehouseEmployee: Record "Warehouse Employee";
        Location: Record Location;
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryPurchase: Codeunit "Library - Purchase";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryUtility: Codeunit "Library - Utility";

        ArchiveManagement: Codeunit ArchiveManagement;
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        AssertThat: Codeunit Assert;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SalesQuotetoOrder: Codeunit "Sales-Quote to Order";
        SalesServiceCommMgmt: Codeunit "Sales Service Commitment Mgmt.";
        PostedDocumentNo: Code[20];
        ErrorTxt: Label 'Service commitments are not created properly.';
        i: Integer;
        CustomerReference: Text;
        SerialNo: array[10] of Code[50];
        NoOfServiceObjects: Integer;
        CurrentQty: Decimal;
#if not CLEAN25
        XmlParameters: Text;
#endif

    local procedure Setup()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
    end;

    local procedure SetupAdditionalServiceCommPackageLine(ServicePartner: Enum "Service Partner")
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := ServicePartner;
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
    end;

    local procedure SetupAdditionalServiceCommPackageLine(ServicePartner: Enum "Service Partner"; CalculationBaseType: Enum "Calculation Base Type")
    begin
        SetupAdditionalServiceCommPackageLine(ServicePartner);
        ServiceCommPackageLine."Calculation Base Type" := CalculationBaseType;
        ServiceCommPackageLine.Modify(false);
    end;

    local procedure SetupAdditionalServiceCommPackageAndAssignToItem()
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, false);
    end;

    local procedure SetupServiceCommitmentItem(var NewItem: Record Item)
    begin
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(NewItem, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        ContractTestLibrary.UpdateItemUnitCostAndPrice(NewItem, LibraryRandom.RandDec(10000, 2), LibraryRandom.RandDec(10000, 2), false);
    end;

    local procedure SetupSalesLineWithSalesServiceCommitments(NewCurrentQty: Decimal)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", NewCurrentQty);
    end;

    local procedure SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(var NewItem: Record Item)
    begin
        SetupServiceCommitmentItem(NewItem);
        CurrentQty := Random(100);
        SetupSalesLineWithSalesServiceCommitments(CurrentQty);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentAssignmentPerItemServiceCommitmentOption()
    var
        Item3: Record Item;
        Item4: Record Item;
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        // no sales service commitments for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales without Service Commitment", ServiceCommitmentPackage.Code);
        // sales service commitments created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        // sales service commitments created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item3, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        // no sales line for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item4, Enum::"Item Service Commitment Type"::"Invoicing Item", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandDec(100, 2));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        Commit(); // retain data after asserterror
        asserterror SalesServiceCommitment.FindSet();

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        CheckAssignedSalesServiceCommitmentValues(SalesServiceCommitment, SalesLine);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item3."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        CheckAssignedSalesServiceCommitmentValues(SalesServiceCommitment, SalesLine);
        Commit(); // retain data after asserterror
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item4."No.", LibraryRandom.RandIntInRange(1, 100));

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item4."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    local procedure CheckAssignedSalesServiceCommitmentValues(var SalesServiceCommitmentToTest: Record "Sales Service Commitment"; SourceSalesLine: Record "Sales Line")
    begin
        ServiceCommPackageLine.SetRange("Package Code", ServiceCommitmentPackage.Code);
        ServiceCommPackageLine.FindSet();
        repeat
            SalesServiceCommitmentToTest.SetRange("Package Code", ServiceCommPackageLine."Package Code");
            SalesServiceCommitmentToTest.SetRange(Partner, ServiceCommPackageLine.Partner);
            SalesServiceCommitmentToTest.FindFirst();
            SalesServiceCommitmentToTest.TestField("Item No.", SalesServiceCommMgmt.GetItemNoForSalesServiceCommitment(SourceSalesLine, ServiceCommPackageLine));
            SalesServiceCommitmentToTest.TestField("Package Code", ServiceCommPackageLine."Package Code");
            SalesServiceCommitmentToTest.TestField(Template, ServiceCommPackageLine.Template);
            SalesServiceCommitmentToTest.TestField(Description, ServiceCommPackageLine.Description);
            SalesServiceCommitmentToTest.TestField("Invoicing via", ServiceCommPackageLine."Invoicing via");
            SalesServiceCommitmentToTest.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
            SalesServiceCommitmentToTest.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
            SalesServiceCommitmentToTest.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
            SalesServiceCommitmentToTest.TestField(Partner, ServiceCommPackageLine.Partner);
            SalesServiceCommitmentToTest.TestField("Calculation Base Type", ServiceCommPackageLine."Calculation Base Type");
            SalesServiceCommitmentToTest.TestField("Billing Base Period", ServiceCommPackageLine."Billing Base Period");
            SalesServiceCommitmentToTest.TestField("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
            SalesServiceCommitmentToTest.TestField("Service Comm. Start Formula", ServiceCommPackageLine."Service Comm. Start Formula");
            SalesServiceCommitmentToTest.TestField("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
            SalesServiceCommitmentToTest.TestField("Customer Price Group", SourceSalesLine."Customer Price Group");
        until ServiceCommPackageLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentAssignmentPerSalesDocumentType()
    begin
        Setup();

        for i := 0 to 5 do begin
            ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
            LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type".FromInteger(i), '');
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            case SalesHeader."Document Type" of
                Enum::"Sales Document Type"::Quote,
                Enum::"Sales Document Type"::Order,
                Enum::"Sales Document Type"::"Blanket Order":
                    SalesServiceCommitment.FindSet();
                Enum::"Sales Document Type"::Invoice, Enum::"Sales Document Type"::"Credit Memo":
                    begin
                        Commit(); // retain data after asserterror
                        asserterror SalesServiceCommitment.FindSet();
                    end;
            end;
        end;
    end;

    [Test]
    procedure CheckDeleteSalesServiceCommitmentWhenValidateTypeOrNo()
    begin
        Setup();
        // sales service commitments created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        // no sales service commitments for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item2, Enum::"Item Service Commitment Type"::"Sales without Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        // change Sales Line Type
        SalesLine.Validate(Type, Enum::"Sales Line Type"::" ");
        SalesLine.Modify(false);
        // Commit before asserterror to keep data
        Commit();
        asserterror SalesServiceCommitment.FindSet();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        // change Sales Line Item No. to one without service commitments
        SalesLine.Validate("No.", Item2."No.");
        SalesLine.Modify(false);
        asserterror SalesServiceCommitment.FindSet();
    end;

    [Test]
    procedure CheckSalesServiceCommitmentArchive()
    var
        SalesServiceCommArchive: Record "Sales Service Comm. Archive";
        FirstArchiveLineFound: Boolean;
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                if not FirstArchiveLineFound then begin
                    SalesServiceCommArchive.SetRange("Document Type", SalesLine."Document Type");
                    SalesServiceCommArchive.SetRange("Document No.", SalesLine."Document No.");
                    SalesServiceCommArchive.SetRange("Document Line No.", SalesLine."Line No.");
                    SalesServiceCommArchive.SetRange("Doc. No. Occurrence", 1);
                    SalesServiceCommArchive.SetRange("Version No.", 1);
                    SalesServiceCommArchive.FindSet();
                    FirstArchiveLineFound := true;
                end else
                    SalesServiceCommArchive.Next();
                SalesServiceCommArchive.TestField("Item No.", SalesServiceCommitment."Item No.");
                SalesServiceCommArchive.TestField("Package Code", SalesServiceCommitment."Package Code");
                SalesServiceCommArchive.TestField(Template, SalesServiceCommitment.Template);
                SalesServiceCommArchive.TestField(Description, SalesServiceCommitment.Description);
                SalesServiceCommArchive.TestField("Invoicing via", SalesServiceCommitment."Invoicing via");
                SalesServiceCommArchive.TestField("Extension Term", SalesServiceCommitment."Extension Term");
                SalesServiceCommArchive.TestField("Notice Period", SalesServiceCommitment."Notice Period");
                SalesServiceCommArchive.TestField("Initial Term", SalesServiceCommitment."Initial Term");
                SalesServiceCommArchive.TestField(Partner, SalesServiceCommitment.Partner);
                SalesServiceCommArchive.TestField("Calculation Base Type", SalesServiceCommitment."Calculation Base Type");
                SalesServiceCommArchive.TestField("Billing Base Period", SalesServiceCommitment."Billing Base Period");
                SalesServiceCommArchive.TestField("Calculation Base %", SalesServiceCommitment."Calculation Base %");
                SalesServiceCommArchive.TestField("Service Comm. Start Formula", SalesServiceCommitment."Service Comm. Start Formula");
                SalesServiceCommArchive.TestField("Billing Rhythm", SalesServiceCommitment."Billing Rhythm");
                SalesServiceCommArchive.TestField("Customer Price Group", SalesServiceCommitment."Customer Price Group");
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentMakeOrderFromQuote()
    var
        TempSalesServiceCommitment: Record "Sales Service Commitment" temporary;
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        repeat
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;

        SalesQuotetoOrder.SetHideValidationDialog(true);
        SalesQuotetoOrder.Run(SalesHeader);
        SalesQuotetoOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            TempSalesServiceCommitment.FindSet();
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment, TempSalesServiceCommitment);
                TempSalesServiceCommitment.Next();
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentMakeOrderBlanketOrder()
    var
        TempSalesServiceCommitment: Record "Sales Service Commitment" temporary;
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        repeat
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            TempSalesServiceCommitment.FindSet();
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment, TempSalesServiceCommitment);
                TempSalesServiceCommitment.Next();
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure CheckRestoreSalesServiceCommitmentFromArchive()
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);
        FindSalesHeaderArchive(SalesHeaderArchive, SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.DeleteAll(true);

        ArchiveManagement.RestoreSalesDocument(SalesHeaderArchive);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
        until SalesLine.Next() = 0;
    end;

    local procedure FindSalesHeaderArchive(var SalesHeaderArchive: Record "Sales Header Archive"; SourceSalesHeader: Record "Sales Header")
    begin
        SalesHeaderArchive.SetRange("Document Type", SourceSalesHeader."Document Type");
        SalesHeaderArchive.SetRange("No.", SourceSalesHeader."No.");
        SalesHeaderArchive.FindFirst();
    end;

    local procedure TestSalesServiceCommitmentValues(var SalesServiceCommitmentToTest: Record "Sales Service Commitment"; var SalesServiceCommitmentToTestWith: Record "Sales Service Commitment")
    begin
        SalesServiceCommitmentToTest.TestField("Item No.", SalesServiceCommitmentToTestWith."Item No.");
        SalesServiceCommitmentToTest.TestField("Package Code", SalesServiceCommitmentToTestWith."Package Code");
        SalesServiceCommitmentToTest.TestField(Template, SalesServiceCommitmentToTestWith.Template);
        SalesServiceCommitmentToTest.TestField(Description, SalesServiceCommitmentToTestWith.Description);
        SalesServiceCommitmentToTest.TestField("Invoicing via", SalesServiceCommitmentToTestWith."Invoicing via");
        SalesServiceCommitmentToTest.TestField("Extension Term", SalesServiceCommitmentToTestWith."Extension Term");
        SalesServiceCommitmentToTest.TestField("Notice Period", SalesServiceCommitmentToTestWith."Notice Period");
        SalesServiceCommitmentToTest.TestField("Initial Term", SalesServiceCommitmentToTestWith."Initial Term");
        SalesServiceCommitmentToTest.TestField(Partner, SalesServiceCommitmentToTestWith.Partner);
        SalesServiceCommitmentToTest.TestField("Calculation Base Type", SalesServiceCommitmentToTestWith."Calculation Base Type");
        SalesServiceCommitmentToTest.TestField("Billing Base Period", SalesServiceCommitmentToTestWith."Billing Base Period");
        SalesServiceCommitmentToTest.TestField("Calculation Base %", SalesServiceCommitmentToTestWith."Calculation Base %");
        SalesServiceCommitmentToTest.TestField("Service Comm. Start Formula", SalesServiceCommitmentToTestWith."Service Comm. Start Formula");
        SalesServiceCommitmentToTest.TestField("Billing Rhythm", SalesServiceCommitmentToTestWith."Billing Rhythm");
    end;

    [Test]
    procedure CheckCopySalesServiceCommitmentFromSalesDocument()
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        LibrarySales.CreateSalesHeader(SalesHeader2, SalesHeader."Document Type"::Quote, Customer."No.");
        CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::Quote, SalesHeader."No.", SalesHeader2);
        SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
        SalesLine2.SetRange("Document No.", SalesHeader2."No.");
        SalesLine2.FindSet();
        repeat
            SalesServiceCommitment2.FilterOnSalesLine(SalesLine2);
            SalesServiceCommitment2.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment2, SalesServiceCommitment);
                SalesServiceCommitment.Next();
            until SalesServiceCommitment2.Next() = 0;
        until SalesLine2.Next() = 0;
    end;

    [Test]
    procedure CheckCreateServiceObjectFromSales()
    var
        FetchSalesLine: Record "Sales Line";
        InitServiceObjectCount: Integer;
    begin
        //Create Item as Sales with Service Commitment
        //Ship Item -  Service Object created
        //Invoice Item - nothing happens
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        Customer.Validate("Customer Price Group", CustomerPriceGroup1.Code);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesHeader."Your Reference")), 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader."Your Reference" := CopyStr(CustomerReference, 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader.Modify(false);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesLine."Qty. to Invoice" := 0;
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        InitServiceObjectCount := ServiceObject.Count;
        ServiceObject.FindFirst();
        ServiceObject.TestField("Item No.", Item."No.");
        ServiceObject.TestField(Description, SalesLine.Description);
        ServiceObject.TestField("Quantity Decimal", Abs(SalesLine."Qty. to Ship"));
        ServiceObject.TestField("Unit of Measure", SalesLine."Unit of Measure Code");
        ServiceObject.TestField("Provision Start Date", SalesLine."Shipment Date");
        ServiceObject.TestField("End-User Contact No.", SalesHeader."Sell-to Contact No.");
        ServiceObject.TestField("End-User Customer No.", SalesHeader."Sell-to Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        ServiceObject.TestField("Customer Price Group", CustomerPriceGroup1.Code);
        ServiceObject.TestField("Customer Reference", CustomerReference);

        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", WorkDate());//set shipment date for next delivery 
        FetchSalesLine.Validate("Qty. to Invoice", 1);
        FetchSalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        AssertThat.AreEqual(InitServiceObjectCount, ServiceObject.Count, 'Service Object is not created properly');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DoNotCreateServiceObjectFromSalesWhenShippingWithNegativeQuantity()
    begin
        //Create Item as Sales with Service Commitment
        //Assign negative value to Quantity
        //Ship Item -  Service Object should not be created
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        Customer.Validate("Customer Price Group", CustomerPriceGroup1.Code);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesHeader."Your Reference")), 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader."Your Reference" := CopyStr(CustomerReference, 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader.Modify(false);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", -LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.SetRange("Customer Reference", CustomerReference);
        asserterror ServiceObject.FindFirst();
    end;

    [Test]
    procedure CheckCreateServiceObjectWithSerialNoOnShipSalesOrder()
    begin
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        TestServiceObjectWithSerialNoExpectedCount();
        TestServiceObjectWithSerialNoExists();
    end;

    local procedure TestServiceObjectWithSerialNoExpectedCount()
    begin
        ServiceObject.Reset();
        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.SetFilter("Serial No.", '<>%1', '');
        AssertThat.AreEqual(NoOfServiceObjects, ServiceObject.Count(), 'Unexpected number of Service Objects with Serial No.');
    end;

    local procedure TestServiceObjectWithSerialNoExists()
    begin
        ServiceObject.Reset();
        ServiceObject.SetRange("Item No.", Item."No.");
        for i := 1 to NoOfServiceObjects do begin
            ServiceObject.SetRange("Serial No.", SerialNo[i]); //check if Serial Object with specific Serial No. is created
            ServiceObject.FindFirst();
            ServiceObject.TestField("Quantity Decimal", 1);
        end;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DoNotCreateServiceObjectWithSerialNoOnShipSalesOrderWithNegativeQuantity()
    begin
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        CheckThatOnlyOneServiceObjectWithSerialNoExists();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", -NoOfServiceObjects);
        CreateSalesLineItemTrackingAndPostSalesDocument(-1, true, false);

        CheckThatOnlyOneServiceObjectWithSerialNoExists();
    end;

    local procedure CreateSalesLineItemTrackingAndPostSalesDocument(Sign: Integer; Ship: Boolean; Invoice: Boolean)
    begin
        CreateSalesLineItemTracking(Sign);
        LibrarySales.PostSalesDocument(SalesHeader, Ship, Invoice);
    end;

    local procedure CreateSalesLineItemTracking(Sign: Integer)
    begin
        for i := 1 to NoOfServiceObjects do
            LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, SerialNo[i], '', 1 * Sign);
    end;

    local procedure CheckThatOnlyOneServiceObjectWithSerialNoExists()
    begin
        for i := 1 to NoOfServiceObjects do begin
            ServiceObject.Reset();
            ServiceObject.SetRange("Item No.", Item."No.");
            ServiceObject.SetRange("Serial No.", SerialNo[i]);
            AssertThat.AreEqual(1, ServiceObject.Count(), 'Unexpected number of Service Objects with Serial No.');
        end;
    end;

    [Test]
    procedure CheckCreateServiceObjectWithSerialNoOnDropShipment()
    begin
        Setup();
        CreateAndReleaseSalesDocumentWithSerialNoForDropShipment();

        LibraryPurchase.CreateVendor(Vendor);
        Item."Vendor No." := Vendor."No.";
        Item.Modify(false);

        RunGetSalesOrders(RequisitionLine, SalesHeader);
        ReqWkshCarryOutActionMessage(RequisitionLine);
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.FindLast();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        TestServiceObjectWithSerialNoExpectedCount();

        TestServiceObjectWithSerialNoExists();
    end;

    [Test]
    procedure CheckCreateServCommitmentsFromSalesServiceCommitment()
    var
        TempSalesServiceCommitment: Record "Sales Service Commitment" temporary;
        SalesServiceCommCount: Integer;
        MaxAdditionalServiceCommitmentPackageLine: Integer;
    begin
        Setup();
        MaxAdditionalServiceCommitmentPackageLine := Random(10);
        for i := 1 to MaxAdditionalServiceCommitmentPackageLine do
            SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommCount := SalesServiceCommitment.Count();
        SalesServiceCommitment.FindSet();
        repeat
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        AssertThat.AreEqual(SalesServiceCommCount, ServiceCommitment.Count(), ErrorTxt);
        ServiceCommitment.FindSet();
        TempSalesServiceCommitment.FindSet();
        repeat
            TestServiceCommitmentValues(ServiceCommitment, TempSalesServiceCommitment);
            TestServiceCommitmentPriceCalculation(ServiceCommitment);
            TempSalesServiceCommitment.Next();
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestServiceCommitmentPriceCalculation(ServiceCommitmentToTest: Record "Service Commitment")
    var
        ExpectedPrice: Decimal;
    begin
        Currency.InitRoundingPrecision();
        ServiceCommitmentToTest.Validate("Calculation Base Amount", LibraryRandom.RandDec(1000, 2));
        ExpectedPrice := Round(ServiceCommitmentToTest."Calculation Base Amount" * ServiceCommitmentToTest."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitmentToTest.TestField(Price, ExpectedPrice);
    end;

    [Test]
    procedure CheckPartiallyShippedSalesOrder()
    var
        FetchSalesLine: Record "Sales Line";
        ServiceObjectCount: Integer;
    begin
        //For each shipment of one sales line new Service object is created
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        //Quantity=2; Qty. to Ship=1; Quantity Shipped=Quantity Invoiced=1
        //Post
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        AssertThat.AreEqual(1, FetchSalesLine."Quantity Shipped", ErrorTxt);
        AssertThat.AreEqual(1, FetchSalesLine."Quantity Invoiced", ErrorTxt);
        //Quantity=2; Qty. to Ship=1; Quantity Shipped=Quantity Invoiced=2
        //Post
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", WorkDate());//set shipment date for next delivery 
        FetchSalesLine.Validate("Qty. to Ship", 1);
        FetchSalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        AssertThat.AreEqual(2, FetchSalesLine."Quantity Shipped", ErrorTxt);
        AssertThat.AreEqual(2, FetchSalesLine."Quantity Invoiced", ErrorTxt);
        //Number of service objects = initial quantity on order
        ServiceObject.SetRange("Item No.", SalesLine."No.");
        ServiceObjectCount := ServiceObject.Count();
        AssertThat.AreEqual(2, ServiceObjectCount, ErrorTxt);

        SalesServiceCommitment.FilterOnSalesLine(FetchSalesLine);
        SalesServiceCommitment.FindFirst();
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Service Amount");
        AssertThat.AreEqual(ServiceCommitment."Service Amount", SalesServiceCommitment."Service Amount" * ServiceObject."Quantity Decimal" / FetchSalesLine.Quantity, ErrorTxt);
    end;

    [Test]
    procedure CheckEqualShipmentDateForPartialSalesShipment()
    var
        FetchSalesLine: Record "Sales Line";
        OldShipmentDate: Date;
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        OldShipmentDate := SalesLine."Shipment Date";
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        AssertThat.AreEqual(1, FetchSalesLine."Quantity Shipped", ErrorTxt);
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", CalcDate('<1D>', OldShipmentDate));
        FetchSalesLine.Validate("Qty. to Ship", 1);
        FetchSalesLine.Modify(false);
        OldShipmentDate := FetchSalesLine."Shipment Date";
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        AssertThat.AreEqual(OldShipmentDate, FetchSalesLine."Shipment Date", ErrorTxt); //After posting last line shipment date must be the same
    end;

    [Test]
    procedure CheckEqualServiceStartDateAndAgreedServCommStartDateAfterInsertServCommFromSalesServComm()
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        Clear(SalesServiceCommitment."Service Comm. Start Formula");
        SalesServiceCommitment.ModifyAll("Agreed Serv. Comm. Start Date", WorkDate(), false);
        SalesServiceCommitment.FindFirst();
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        AssertThat.AreEqual(SalesServiceCommitment."Agreed Serv. Comm. Start Date", ServiceCommitment."Service Start Date", ErrorTxt);
    end;

    [Test]
    procedure CheckEqualServiceStartDateAndSalesLineShipmentDateAfterInsertServCommFromSalesLine()
    begin
        Setup();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.ModifyAll(SalesServiceCommitment."Agreed Serv. Comm. Start Date", 0D, false);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Service Comm. Start Formula", '');
        SalesServiceCommitment.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        AssertThat.AreEqual(SalesLine."Shipment Date", ServiceCommitment."Service Start Date", ErrorTxt);
    end;

    [Test]
    procedure CheckServiceStartDateCalculationFromDateFormulaAfterInsertServCommFromSalesLine()
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        Evaluate(SalesServiceCommitment."Service Comm. Start Formula", '<1M>');
        SalesServiceCommitment.ModifyAll(SalesServiceCommitment."Agreed Serv. Comm. Start Date", 0D, false);
        SalesServiceCommitment.FindFirst();
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        AssertThat.AreEqual(ServiceCommitment."Service Start Date", CalcDate(SalesServiceCommitment."Service Comm. Start Formula", SalesLine."Shipment Date"), ErrorTxt);
    end;

    [Test]
    procedure ExpectErrorOnModifySalesServiceCommitmentIfSalesOrderIsReleased()
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesServiceCommitment.Price := LibraryRandom.RandDec(1000, 2);
        asserterror SalesServiceCommitment.Modify(true);
    end;

    [Test]
    procedure CheckSalesLineQtyToInvoiceAfterSalesQuotetoOrder()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));

        SalesQuotetoOrder.SetHideValidationDialog(true);
        SalesQuotetoOrder.Run(SalesHeader);
        SalesQuotetoOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindFirst();
        repeat
            SalesLine.TestField(SalesLine."Qty. to Invoice", 0);
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesLineQtyToInvoiceOnCreateSalesOrder()
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandInt(100));

        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindFirst();
        repeat
            if SalesLine."No." = Item."No." then
                SalesLine.TestField(SalesLine."Qty. to Invoice", 0)
            else
                if SalesLine."No." = Item2."No." then
                    SalesLine.TestField(SalesLine."Qty. to Invoice", SalesLine.Quantity)
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure TestSalesInvoiceLineOnPostSalesOrder()
    var
        MainSalesLineLineNo: Integer;
    begin
        // Setup a Service Commitment Item with attributed extended text & a "normal" sales item with service commitment
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        MainSalesLineLineNo := SalesLine."Line No.";
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        SalesLine.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesLine.Description)), 1, MaxStrLen(SalesLine.Description));
        SalesLine."Attached to Line No." := MainSalesLineLineNo;
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandInt(100));

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        AssertThat.AreEqual(3, SalesLine.Count, 'Setup failure: Not the expected number of sales lines'); // two item lines and one comment line

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceLine.SetRange("Document No.", PostedDocumentNo);
        AssertThat.AreEqual(1, SalesInvoiceLine.Count, 'Sales Invoice is not posted correctly');
    end;

    local procedure TestServiceCommitmentValues(var ServiceCommitmentToTest: Record "Service Commitment"; var SalesServiceCommitmentToTestWith: Record "Sales Service Commitment")
    begin
        ServiceCommitmentToTest.TestField("Package Code", SalesServiceCommitmentToTestWith."Package Code");
        ServiceCommitmentToTest.TestField(Template, SalesServiceCommitmentToTestWith.Template);
        ServiceCommitmentToTest.TestField(Description, SalesServiceCommitmentToTestWith.Description);
        ServiceCommitmentToTest.TestField("Invoicing via", SalesServiceCommitmentToTestWith."Invoicing via");
        ServiceCommitmentToTest.TestField("Extension Term", SalesServiceCommitmentToTestWith."Extension Term");
        ServiceCommitmentToTest.TestField("Notice Period", SalesServiceCommitmentToTestWith."Notice Period");
        ServiceCommitmentToTest.TestField("Initial Term", SalesServiceCommitmentToTestWith."Initial Term");
        ServiceCommitmentToTest.TestField("Billing Base Period", SalesServiceCommitmentToTestWith."Billing Base Period");
        ServiceCommitmentToTest.TestField("Calculation Base %", SalesServiceCommitmentToTestWith."Calculation Base %");
        ServiceCommitmentToTest.TestField("Billing Rhythm", SalesServiceCommitmentToTestWith."Billing Rhythm");
        ServiceCommitmentToTest.TestField("Currency Code", Customer."Currency Code");
        ServiceCommitmentToTest.TestField(Price, SalesServiceCommitmentToTestWith.Price);
        ServiceCommitmentToTest.TestField("Service Amount", SalesServiceCommitmentToTestWith."Service Amount");
        ServiceCommitmentToTest.TestField("Discount Amount", SalesServiceCommitmentToTestWith."Discount Amount");
        ServiceCommitmentToTest.TestField("Price (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith.Price, ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Service Amount (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith."Service Amount", ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Discount Amount (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith."Discount Amount", ServiceCommitmentToTest."Currency Factor"));
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure CheckSalesServiceCommitmentPackageFilterForSalesLine()
    begin
        //Create three Service Commitment Packages and assign them to one Item. First Serv. Comm. Package is set as Standard
        Setup();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        SetupAdditionalServiceCommPackageAndAssignToItem();
        SetupAdditionalServiceCommPackageAndAssignToItem();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        TestSalesServiceCommitmentPackageFilterForSalesLine(SalesLine, true);
        TestSalesServiceCommitmentPackageFilterForSalesLine(SalesLine, false);
    end;

    local procedure TestSalesServiceCommitmentPackageFilterForSalesLine(SourceSalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean)
    var
        ItemServiceCommitmentPackage: Record "Item Serv. Commitment Package";
        PackageFilter: Text;
        StandardServCommPackageFound: Boolean;
    begin
        PackageFilter := ItemServiceCommitmentPackage.GetPackageFilterForItem(SourceSalesLine, RemoveExistingPackageFromFilter);
        ServiceCommitmentPackage.SetFilter(Code, PackageFilter);
        ServiceCommitmentPackage.FindSet();
        repeat
            ItemServiceCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
            if RemoveExistingPackageFromFilter then
                ItemServiceCommitmentPackage.TestField(Standard, false);
            if ItemServiceCommitmentPackage.Standard then
                StandardServCommPackageFound := true;
        until ServiceCommitmentPackage.Next() = 0;

        if not RemoveExistingPackageFromFilter then
            if not StandardServCommPackageFound then
                Error('Item Service Commitment Package with Standard=true not found.');
    end;

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.Cancel().Invoke();
    end;

    [Test]
    procedure CheckSalesServiceCommitmentBaseAmountCalculation()
    var
        ExpectedCalculationBaseAmount: Decimal;
    begin
        // Creates Service Commitment Packages with Service Commitment Package Lines with combinations of Customer/Vendor and Calculation Base Type
        // Customer - Item Price
        // Customer - Document Price
        // Customer - Document Price and Discount
        // Vendor - Item Price
        // Vendor - Document Price

        Setup(); // Customer - Item Price
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Customer, Enum::"Calculation Base Type"::"Document Price");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Customer, Enum::"Calculation Base Type"::"Document Price And Discount");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor, Enum::"Calculation Base Type"::"Item Price");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor, Enum::"Calculation Base Type"::"Document Price");
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);

        // Customer
        ExpectedCalculationBaseAmount := Item."Unit Price";
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Item Price");
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Price";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        SalesLine.Validate("Line Discount %", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Price";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price And Discount");
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        SalesServiceCommitment.TestField("Discount %", SalesLine."Line Discount %");

        // Vendor
        ExpectedCalculationBaseAmount := Item."Last Direct Cost";
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Item Price");
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        SalesLine.Validate("Unit Cost", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Cost";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentPriceCalculation()
    var
        ExpectedPrice: Decimal;
    begin
        Setup();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Currency.InitRoundingPrecision();
        ExpectedPrice := Round(SalesServiceCommitment."Calculation Base Amount" * SalesServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        SalesServiceCommitment.TestField(Price, ExpectedPrice);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentServiceAmountCalculation()
    var
        ExpectedServiceAmount: Decimal;
        ChangedCalculationBaseAmount: Decimal;
        DiscountPercent: Decimal;
        ServiceAmountBiggerThanPrice: Decimal;
        Price: Decimal;
    begin
        Setup();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        Currency.InitRoundingPrecision();
        Price := Round(SalesServiceCommitment."Calculation Base Amount" * SalesServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(SalesLine.Quantity * Price, Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        ChangedCalculationBaseAmount := LibraryRandom.RandDec(1000, 2);
        SalesServiceCommitment.Validate("Calculation Base Amount", ChangedCalculationBaseAmount);

        ExpectedServiceAmount := Round((SalesServiceCommitment.Price * SalesLine.Quantity), Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        DiscountPercent := LibraryRandom.RandDec(100, 2);
        SalesServiceCommitment.Validate("Discount %", DiscountPercent);

        ExpectedServiceAmount := ExpectedServiceAmount - Round(ExpectedServiceAmount * DiscountPercent / 100, Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        ServiceAmountBiggerThanPrice := SalesServiceCommitment.Price * (SalesLine.Quantity + 1);
        asserterror SalesServiceCommitment.Validate("Service Amount", ServiceAmountBiggerThanPrice);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentDiscountCalculation()
    var
        DiscountPercent: Decimal;
        ExpectedDiscountAmount: Decimal;
        DiscountAmount: Decimal;
        ExpectedDiscountPercent: Decimal;
        ServiceAmountInt: Integer;
    begin
        Setup();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        SalesServiceCommitment.TestField("Discount %", 0);
        SalesServiceCommitment.TestField("Discount Amount", 0);
        Currency.InitRoundingPrecision();

        DiscountPercent := LibraryRandom.RandDec(50, 2);
        ExpectedDiscountAmount := Round(SalesServiceCommitment."Service Amount" * DiscountPercent / 100, Currency."Amount Rounding Precision");
        SalesServiceCommitment.Validate("Discount %", DiscountPercent);
        SalesServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);

        Evaluate(ServiceAmountInt, Format(SalesServiceCommitment."Service Amount", 0, '<Integer>'));
        DiscountAmount := LibraryRandom.RandDec(ServiceAmountInt, 2);
        ExpectedDiscountPercent := Round(DiscountAmount / Round((SalesServiceCommitment.Price * SalesLine.Quantity), Currency."Amount Rounding Precision") * 100, 0.00001);
        SalesServiceCommitment.Validate("Discount Amount", DiscountAmount);
        SalesServiceCommitment.TestField("Discount %", ExpectedDiscountPercent);
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedOnEmptyPriceGroupOnHeader()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine1);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage1.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        ServiceCommitmentPackage1."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage1.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup('', '');
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedSameOnPriceGroupOnHeader()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine1);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage1.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        ServiceCommitmentPackage1."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage1.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroup1.Code, CustomerPriceGroup1.Code);
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedOnDifferentPriceGroupOnHeader()
    begin
        Setup();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage1, ServiceCommPackageLine1);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine1);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage1.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup2);
        ServiceCommitmentPackage1."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage1.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroup2.Code, CustomerPriceGroup1.Code + '|' + '');
    end;

    procedure TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroupCode: Code[20]; CustomerPriceGroupFilter: Text)
    var
        SalesServiceCommPriceGroupFilter: Text;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Customer Price Group", CustomerPriceGroupCode);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.SetRange("Document No.", SalesLine."Document No.");
        SalesServiceCommPriceGroupFilter := CustomerPriceGroupFilter;//SalesServiceCommitment.GetCustomerPriceGroupFilter(SalesServiceCommitment);
        SalesServiceCommitment.FindSet();
        repeat
            AssertThat.AreEqual(SalesServiceCommPriceGroupFilter, CustomerPriceGroupFilter, 'Sales Service Commitments not created properly.');
        until SalesServiceCommitment.Next() = 0;
    end;

#if not CLEAN25
    local procedure SetupSalesLineForTotalAndVatCalculation(var NewItem: Record Item; SetupServiceItemWithPackage: Boolean; ReferentVatPercent: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if SetupServiceItemWithPackage then
            ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(NewItem, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code)
        else
            ContractTestLibrary.CreateInventoryItem(NewItem);
        if ReferentVatPercent <> 0 then begin
            LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
            VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', NewItem."VAT Prod. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', ReferentVatPercent);
            VATPostingSetup.FindFirst();
            NewItem.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        end;
        ContractTestLibrary.UpdateItemUnitCostAndPrice(NewItem, LibraryRandom.RandDec(10000, 2), LibraryRandom.RandDec(10000, 2), false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, NewItem."No.", LibraryRandom.RandInt(100));
    end;
#endif
#if not CLEAN25
    [Test]
    [HandlerFunctions('SalesOrderConfRequestPageHandler')]
    procedure CheckIsServiceItemExcludedFromTotalsInReports()
    var
        Item3: Record Item;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
    begin
        Setup();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SetupSalesLineForTotalAndVatCalculation(Item, true, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(false);
        SetupSalesLineForTotalAndVatCalculation(Item2, false, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(false);
        SetupSalesLineForTotalAndVatCalculation(Item3, false, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Line Discount %", 50);
        SalesLine.Modify(false);
        Commit(); // Commit Data prior to calling the report

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        // Exclude Service Item from expected Totals
        SalesLine.SetFilter("No.", '<>%1', Item."No.");
        SalesLine.CalcSums("Line Amount", "Inv. Discount Amount", Amount, "Amount Including VAT");

        // Filter to only print one document
        SalesHeader.SetRange(SystemId, SalesHeader.SystemId);
        // Run the Report
        XmlParameters := Report.RunRequestPage(Report::"Standard Sales - Order Conf."); // SalesOrderConfRequestPageHandler
        LibraryReportDataset.RunReportAndLoad(Report::"Standard Sales - Order Conf.", SalesHeader, XmlParameters);

        // Verifying totals on report
        LibraryReportDataset.AssertElementWithValueExists('TotalNetAmount', SalesLine.Amount); // TotalAmount
        LibraryReportDataset.AssertElementWithValueExists('TotalSubTotal', SalesLine."Line Amount"); // TotalSubTotal
        LibraryReportDataset.AssertElementWithValueExists('TotalInvoiceDiscountAmount', SalesLine."Inv. Discount Amount"); // TotalInvDiscAmount
        LibraryReportDataset.AssertElementWithValueExists('TotalVATAmount', SalesLine."Amount Including VAT" - SalesLine.Amount); // TotalAmountVAT
        LibraryReportDataset.AssertElementWithValueExists('TotalAmountIncludingVAT', SalesLine."Amount Including VAT"); // TotalAmountInclVAT
    end;
#endif
#if not CLEAN25
    [RequestPageHandler]
    procedure SalesOrderConfRequestPageHandler(var StandardSalesOrderConf: TestRequestPage "Standard Sales - Order Conf.")
    begin
    end;
#endif
#if not CLEAN25
    [Test]
    procedure CheckVatCalculationForServiceCommitmentRhytmInReports()
    var
        TempVatAmountLines: Record "VAT Amount Line" temporary;
        Item3: Record Item;
        Item4: Record Item;
        UniqueRhythmDictionary: Dictionary of [Code[20], Text];
        ExpectedVATAmount: Decimal;
    begin
        Setup();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(SalesHeader."Currency Code");
        ExpectedVATAmount := 0;

        // "Billing Rhythm" = '<1M>', "Billing Base Period" = '<12M>'
        SetupSalesLineForTotalAndVatCalculation(Item, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        ExpectedVATAmount += Round((SalesServiceCommitment."Service Amount" / 12 * 1) * SalesLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        // Item with different VAT for same Billing Rhythm
        SetupSalesLineForTotalAndVatCalculation(Item4, true, SalesLine."VAT %");
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        ExpectedVATAmount += Round((SalesServiceCommitment."Service Amount" / 12 * 1) * SalesLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        // "Billing Rhythm" = '<3M>', "Billing Base Period" = '<12M>'
        SetupSalesLineForTotalAndVatCalculation(Item2, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Billing Rhythm", '3M');
        SalesServiceCommitment.Modify(false);
        ExpectedVATAmount += (SalesServiceCommitment."Service Amount" / 12 * 3) * SalesLine."VAT %" / 100;

        // "Billing Rhythm" = '<3M>', "Billing Base Period" = '<2Y>'
        SetupSalesLineForTotalAndVatCalculation(Item3, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Billing Base Period", '<2Y>');
        Evaluate(SalesServiceCommitment."Billing Rhythm", '<3M>');
        SalesServiceCommitment.Modify(false);
        ExpectedVATAmount += (SalesServiceCommitment."Service Amount" / 24 * 3) * SalesLine."VAT %" / 100;
        ExpectedVATAmount := Round(ExpectedVATAmount, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        SalesServiceCommitment.CalcVATAmountLines(SalesHeader, TempVatAmountLines, UniqueRhythmDictionary);

        AssertThat.AreEqual(UniqueRhythmDictionary.Count + 1, TempVatAmountLines.Count, 'Service Items VAT Lines not created properly.');
        TempVatAmountLines.CalcSums("VAT Amount");
        AssertThat.AreEqual(ExpectedVATAmount, TempVatAmountLines."VAT Amount", 'Service Items VAT Amount not calculated properly.');
    end;
#endif
    [Test]
    procedure CheckShippedNotInvoicedIsZeroForServiceCommitmentItemAfterPostingSalesOrder()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(10));
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        SalesHeader.Get(Enum::"Sales Document Type"::Order, SalesHeader."No.");
        SalesHeader.TestField("Shipped Not Invoiced", false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.TestField("Qty. Shipped Not Invoiced", 0);
        SalesLine.TestField("Qty. Shipped Not Invd. (Base)", 0);
        SalesLine.TestField("Shipped Not Invoiced", 0);
        SalesLine.TestField("Shipped Not Invoiced (LCY)", 0);
        SalesLine.TestField("Shipped Not Inv. (LCY) No VAT", 0);
    end;

    [Test]
    procedure CheckLedgerEntryValues()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SalesInvoiceHeader.CalcFields(Amount);
        AssertThat.AreEqual(SalesLine.Amount, SalesInvoiceHeader.Amount, 'Amounts in Posted Sales Invoice is not correct');
        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.SetRange("Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
        GLEntry.CalcSums(Amount);
        AssertThat.AreEqual(SalesLine.Amount, -GLEntry.Amount, 'Amount in GL Entry is not correct');
        DetailedCustLedgEntry.SetRange("Document No.", PostedDocumentNo);
        DetailedCustLedgEntry.CalcSums(Amount);
        AssertThat.AreEqual(SalesLine."Amount Including VAT", DetailedCustLedgEntry.Amount, 'Amount in Customer Ledger Entry is not correct');
    end;

    [Test]
    procedure ExpectErrorOnMergeContractLinesWithDifferentSerialNo()
    begin
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        ServiceObject.Reset();
        ServiceObject.SetFilter("Serial No.", '<>%1', '');
        ServiceObject.FindFirst();
        repeat
            ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, false);
        until ServiceObject.Next() = 0;

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler')]
    procedure TestTransferSalesServiceCommitmentsOnExplodeBOM()
    begin
        ClearAll();
        Setup();
        LibraryAssembly.CreateItem(Item2, Item."Costing Method"::Standard, Item."Replenishment System"::Assembly, '', '');
        CreateComponentItemWithSalesServiceCommitments();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", WorkDate(), LibraryRandom.RandInt(100));
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", SalesLine);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, Enum::"Sales Line Type"::Item);
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindLast();
        SalesLine.CalcFields("Service Commitments");
        SalesLine.TestField("Service Commitments");
    end;

    [Test]
    procedure ExpectErrorOnInsertSalesServiceCommitmentWithoutInvoicingItemNo()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);        // sales service commitments created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure InsertSalesServiceCommitmentWithInvoiceViaSalesWithoutInvoicingItemNo()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := ServiceCommitmentTemplate."Invoicing via"::Sales;
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure ExpectErrorOnInsertSalesServiceCommitmentWithoutBillingRhythm()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);        // sales service commitments created for this item
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    local procedure CreateComponentItemWithSalesServiceCommitments()
    begin
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        BOMComponent.Init();
        BOMComponent.Validate("Parent Item No.", Item2."No.");
        BOMComponent.Validate(Type, BOMComponent.Type::Item);
        BOMComponent.Validate("No.", Item."No.");
        BOMComponent.Insert(false);
    end;

    local procedure CreateAndPostSalesDocumentWithSerialNo(Ship: Boolean; Invoice: Boolean)
    begin
        Setup();
        CreateSalesServiceCommitmentItemWithSNSpecificTracking();
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);

        PopulateSerialNo();
        CreateAndReceivePurchaseOrderWithItemWithSerialNo();
        CreateSalesLineItemTrackingAndPostSalesDocument(1, Ship, Invoice);
    end;

    local procedure CreateSalesDocumentAndLineWithRandomQuantity(SalesDocumentType: Enum "Sales Document Type")
    var
        Quantity: Decimal;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType, Customer."No.");
        Quantity := LibraryRandom.RandInt(10);
        NoOfServiceObjects := Quantity;
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Quantity);
    end;

    local procedure PopulateSerialNo()
    begin
        for i := 1 to NoOfServiceObjects do
            SerialNo[i] := CopyStr(LibraryRandom.RandText(50), 1, MaxStrLen(SerialNo[i]));
    end;

    local procedure CreateAndReceivePurchaseOrderWithItemWithSerialNo()
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, '');
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", NoOfServiceObjects);
        for i := 1 to NoOfServiceObjects do
            LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, SerialNo[i], '', 1);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    local procedure CreateSalesServiceCommitmentItemWithSNSpecificTracking()
    begin
        CreateSalesServiceCommitmentItemWithSNSpecificTracking(true, false);
    end;

    local procedure CreateSalesServiceCommitmentItemWithSNSpecificTracking(SNSpecific: Boolean; LNSpecific: Boolean)
    begin
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, SNSpecific, LNSpecific);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        Item."Service Commitment Option" := Enum::"Item Service Commitment Type"::"Sales with Service Commitment";
        Item.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    local procedure RunGetSalesOrders(var NewRequisitionLine: Record "Requisition Line"; SourceSalesHeader: Record "Sales Header")
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
        ReqWkshName: Record "Requisition Wksh. Name";
        GetSalesOrders: Report "Get Sales Orders";
        LibraryPlanning: Codeunit "Library - Planning";
        RetrieveDimensions: Option "Sales Line",Item;
    begin
        ReqWkshTemplate.SetRange(Type, ReqWkshName."Template Type"::"Req.");
        ReqWkshTemplate.FindFirst();

        LibraryPlanning.CreateRequisitionWkshName(ReqWkshName, ReqWkshTemplate.Name);
        NewRequisitionLine.Init();
        NewRequisitionLine.Validate("Worksheet Template Name", ReqWkshName."Worksheet Template Name");
        NewRequisitionLine.Validate("Journal Batch Name", ReqWkshName.Name);

        SalesLine.SetRange("Document Type", SourceSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SourceSalesHeader."No.");
        Clear(GetSalesOrders);
        GetSalesOrders.SetTableView(SalesLine);
        GetSalesOrders.InitializeRequest(RetrieveDimensions::"Sales Line");
        GetSalesOrders.SetReqWkshLine(NewRequisitionLine, 0);
        GetSalesOrders.UseRequestPage(false);
        GetSalesOrders.Run();

        NewRequisitionLine.SetRange("Journal Batch Name", ReqWkshName.Name);
        NewRequisitionLine.FindFirst();
    end;

    local procedure ReqWkshCarryOutActionMessage(var SourceRequisitionLine: Record "Requisition Line")
    var
        CarryOutActionMessage: Report "Carry Out Action Msg. - Req.";
    begin
        CarryOutActionMessage.SetReqWkshLine(SourceRequisitionLine);
        CarryOutActionMessage.SetHideDialog(true);

        CarryOutActionMessage.UseRequestPage(false);
        CarryOutActionMessage.RunModal();
    end;

    local procedure CreateAndReleaseSalesDocumentWithSerialNoForDropShipment()
    begin
        LibraryPurchase.CreateDropShipmentPurchasingCode(Purchasing);
        CreateSalesServiceCommitmentItemWithSNSpecificTracking();
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);
        SalesLine.Validate("Purchasing Code", Purchasing.Code);
        SalesLine.Modify(true);

        PopulateSerialNo();
        CreateSalesLineItemTracking(1);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
    end;

    [PageHandler]
    procedure ServCommWOCustContractPageHandler(var ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract")
    begin
        ServCommWOCustContractPage.AssignAllServiceCommitmentsAction.Invoke();
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2;
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [Test]
    procedure CheckNoGetSalesShipmentLinesAvailableForInvoiceForServiceCommitmentItem()
    var
        SalesShptLine: Record "Sales Shipment Line";
    begin
        //when posting Sales Order with Item which is Service Commitment Item
        //it should not be possible to Get Shipment Lines in Sales Invoice
        Setup();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');

        //Post
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        //Test that no Sales Shipment Line is found
        // filter code taken from codeunit 64 "Sales-Get Shipment"
        SalesShptLine.SetCurrentKey("Bill-to Customer No.");
        SalesShptLine.SetRange("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        SalesShptLine.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesShptLine.SetFilter("Qty. Shipped Not Invoiced", '<>0');
        SalesShptLine.SetRange("Currency Code", SalesHeader."Currency Code");
        SalesShptLine.SetRange("Authorized for Credit Card", false);
        AssertThat.AreEqual(true, SalesShptLine.IsEmpty(), 'Sales Shipment Line should not be found for Service Commitment Item.');
    end;

    [Test]
    procedure ExpectErrorOnAssignServiceCommitmentWithInvoicingViaContract()
    begin
        //Expect error if Invoicing Via No. is empty
        Setup();
        ServiceCommPackageLine."Invoicing Item No." := '';
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');

        asserterror LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
    end;

    [Test]
    procedure CreateServiceObjectWithItemTrackingCodeWithoutSNSpecificFlag()
    begin
        // Check that Service Object is created with Item with Item Tracking Code without SNSpecific flag
        Setup();
        CreateSalesServiceCommitmentItemWithSNSpecificTracking(false, false);
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.SetRange("Item No.", Item."No.");
        AssertThat.AreEqual(1, ServiceObject.Count(), 'Unexpected number of Service Objects.');
        ServiceObject.FindFirst();
        ServiceObject.TestField("Serial No.", '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure UsePostingDateFromInventoryPickWhenPostingSalesOrder()
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        CreateInvtPutawayPickMvmt: Report "Create Invt Put-away/Pick/Mvmt";
        InventoryPickPostingDate: Date;
    begin
        // When using Inventory Pick to post Sales Order if "Posting Date" option has been used in Service Contract Setup (Service Start Date for Inventory Pick)
        // then Posting Date is set as Service Start Date in Service Commitments and Provision Start Date in Service Object
        SetupForInventoryPick();
        PurchaseHardwareItemForLocation();
        CreateAndReleaseSalesOrder();
        CreateInvtPutawayPickMvmt.InitializeRequest(false, true, false, false, false);
        CreateInvtPutawayPickMvmt.UseRequestPage(false);
        CreateInvtPutawayPickMvmt.Run();

        InventoryPickPostingDate := SalesLine."Shipment Date" + 10;
        FindAndUpdateWhseActivityPostingDate(
          WarehouseActivityHeader, WarehouseActivityLine,
          Database::"Sales Line", SalesHeader."No.",
          WarehouseActivityHeader.Type::"Invt. Pick", InventoryPickPostingDate);

        LibraryWarehouse.SetQtyToHandleWhseActivity(WarehouseActivityHeader, WarehouseActivityLine.Quantity);
        LibraryWarehouse.PostInventoryActivity(WarehouseActivityHeader, false);

        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceObject.TestField("Provision Start Date", InventoryPickPostingDate);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");

        ServiceCommitment.FindFirst();
        repeat
            ServiceCommitment.TestField("Service Start Date", InventoryPickPostingDate);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure CheckExcludeFromDocumentTotals()
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        ClearAll();
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, '', 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(false);
        AssertThat.AreEqual(false, SalesLine."Exclude from Doc. Total", 'Setup-Failure: Exclude from Doc. Total should be false by default');
        AssertThat.AreNotEqual(0, SalesLine."Line Amount", 'Setup-Failure: Sales Line "Line Amount" should have a value.');

        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        AssertThat.AreNotEqual(0, SalesQuote.SalesLines."Total Amount Excl. VAT".AsDecimal(), 'Sales Line Total should have a value.');
        SalesQuote.Close();

        SalesLine."Exclude from Doc. Total" := true;
        SalesLine.Modify(false);
        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        AssertThat.AreEqual(0, SalesQuote.SalesLines."Total Amount Excl. VAT".AsDecimal(), 'Sales Line Total should be zero.');
        SalesQuote.Close();
    end;

    [Test]
    procedure CheckSalesServiceCommitmentPartialMakeOrderFromBlanketOrder()
    var
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(2, 100));
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                SalesServiceCommitment.TestField("Service Amount", Round(SalesServiceCommitment.Price, 0.01));
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentsInBlanketOrderOnAfterMakeOrder()
    var
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Setup();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(2, 100));
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
        until SalesLine.Next() = 0;
    end;

    local procedure SetupForInventoryPick()
    begin
        ClearAll();
        SetupInventorySetupForInventoryPick();
        SetupServiceContractSetupForInventoryPick();
        SetupHardwareItemWithServiceCommitment("Item Service Commitment Type"::"Sales with Service Commitment");
        SetupLocationForInventoryPick();
        SetupWarehouseWorker();
    end;

    local procedure SetupInventorySetupForInventoryPick()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if InventorySetup."Inventory Pick Nos." = '' then begin
            InventorySetup."Inventory Pick Nos." := CreateNoSeriesWithLine();
            InventorySetup.Modify(false);
        end;
        if InventorySetup."Posted Invt. Pick Nos." = '' then begin
            InventorySetup."Posted Invt. Pick Nos." := CreateNoSeriesWithLine();
            InventorySetup.Modify(false);
        end;
    end;

    internal procedure CreateNoSeriesWithLine(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(
            NoSeriesLine,
            NoSeries.Code,
            CopyStr(NoSeries.Code + '000', 1, MaxStrLen(NoSeries.Code)),
            CopyStr(NoSeries.Code + '999', 1, MaxStrLen(NoSeries.Code)));
        exit(NoSeries.Code);
    end;

    local procedure SetupHardwareItemWithServiceCommitment(ServiceCommitmentType: Enum "Item Service Commitment Type")
    var
        EmptyDateFormula: DateFormula;
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Item."Service Commitment Option" := ServiceCommitmentType;
        Item.Modify(false);
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ServiceCommPackageLine."Service Comm. Start Formula" := EmptyDateFormula;
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    local procedure SetupServiceContractSetupForInventoryPick()
    var
        ServiceContractSetup: Record "Service Contract Setup";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup."Serv. Start Date for Inv. Pick" := ServiceContractSetup."Serv. Start Date for Inv. Pick"::"Posting Date";
        ServiceContractSetup.Modify(false);
    end;

    local procedure SetupLocationForInventoryPick()
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Location.Validate("Require Pick", true);
        Location.Modify(true);
    end;

    local procedure SetupWarehouseWorker()
    begin
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, true);
    end;

    local procedure PurchaseHardwareItemForLocation()
    begin
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, '', Location.Code);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandDecInRange(1, 100, 0));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    local procedure CreateAndReleaseSalesOrder()
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SalesHeader.Validate("Location Code", Location.Code);
        SalesHeader.Modify(false);
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
    end;

    local procedure FindAndUpdateWhseActivityPostingDate(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceType: Integer; SourceNo: Code[20]; ActivityType: Enum "Warehouse Activity Type"; PostingDate: Date)
    begin
        FindWarehouseActivityLine(WarehouseActivityLine, SourceType, SourceNo, ActivityType);
        WarehouseActivityHeader.Get(ActivityType, WarehouseActivityLine."No.");
        WarehouseActivityHeader.Validate("Posting Date", PostingDate);
        WarehouseActivityHeader.Modify(true);
    end;

    local procedure FindWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceType: Integer; SourceNo: Code[20]; ActivityType: Enum "Warehouse Activity Type")
    begin
        WarehouseActivityLine.SetRange("Source Type", SourceType);
        WarehouseActivityLine.SetRange("Source No.", SourceNo);
        WarehouseActivityLine.SetRange("Activity Type", ActivityType);
        WarehouseActivityLine.FindFirst();
    end;

    local procedure SetupServiceCommitmentTemplate()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Invoicing Item No." := Item."No.";
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    internal procedure TestUndoShipmentForServiceCommitmentItem()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        //GIVEN Create Service Commitment Item, Create Sales Order and post it
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandDecInRange(1, 8, 0));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        //WHEN Run Undo Shipment action
        SalesShipmentLine.SetRange("Order No.", SalesHeader."No.");
        SalesShipmentLine.FindFirst();
        CODEUNIT.Run(Codeunit::"Undo Sales Shipment Line", SalesShipmentLine);
        SalesShipmentLine.SetRange("Order No.");
        SalesShipmentLine.SetRange("Document No.", SalesShipmentLine."Document No.");
        SalesShipmentLine.SetRange(Correction, true);
        AssertThat.RecordIsNotEmpty(SalesShipmentLine);
    end;
}