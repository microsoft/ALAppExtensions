codeunit 147106 "CD FacturaInvoiceSubUnit"
{
    // // [FEATURE] [Factura-Invoice] [Proforma-Invoice] [Report]

    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryVATLedger: Codeunit "Library - VAT Ledger";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportValidation: Codeunit "Library - Report Validation";
        LibraryRUReports: Codeunit "Library RU Reports";
        IsInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure SalesFacturaWithCustomDeclarationOneLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        CDNo: Code[30];
        CountryCode: Code[10];
        Qty: Decimal;
    begin
        // [FEATURE] [Custom Declaration]
        // [SCENARIO 377298] Order Factura-Invoice (A) generates one line for Item line with Custom Declaration in case of one Item Tracking line
        Initialize();

        // [GIVEN] Item "X" with Custom Declaration "CD"
        ItemNo := CreateItemWithItemTracking();
        CreateCustomDeclaration(CDNo, CountryCode, ItemNo);

        // [GIVEN] Released Sales Order with line for Item "X" of Quantity 3 and Item Tracking Line with "CD"
        Qty := LibraryRandom.RandDec(100, 2);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibraryVATLedger.CreateCustomerEAEU());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Qty);
        CreateSalesLineTracking(SalesLine, CDNo, Qty);
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [WHEN] Run Order Factura-Invoice
        FacturaInvoiceExcelExport(SalesHeader, false);

        // [THEN] Sales Line for ItemNo = "X" is exported with Quantity = 3, Amounts, Country Code and Custom Declaration "CD"
        VerifySalesLineColumns(
          22, SalesLine."No.",
          Format(SalesLine.Quantity), FormatAmount(SalesLine."Unit Price"), FormatAmount(SalesLine.Amount), Format(SalesLine."VAT %"),
          FormatAmount(SalesLine."Amount Including VAT" - SalesLine.Amount),
          FormatAmount(SalesLine."Amount Including VAT"),
          CountryCode, CDNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesFacturaWithCustomDeclarationTwoLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        CDNo1: Code[30];
        CDNo2: Code[30];
        CountryCode1: Code[10];
        CountryCode2: Code[10];
        Qty1: Decimal;
        Qty2: Decimal;
    begin
        // [FEATURE] [Custom Declaration]
        // [SCENARIO 377298] Order Factura-Invoice (A) generates one line for Item and a line for each Custom Declaration in case of more than one Item Tracking line
        Initialize();

        // [GIVEN] Item "X" with Custom Declarations "CD1", "CD2"
        ItemNo := CreateItemWithItemTracking();
        CreateCustomDeclaration(CDNo1, CountryCode1, ItemNo);
        CreateCustomDeclaration(CDNo2, CountryCode2, ItemNo);

        // [GIVEN] Released Sales Order with one line for Item "X" of Quantity 3
        Qty1 := LibraryRandom.RandDec(100, 2);
        Qty2 := LibraryRandom.RandDec(100, 2);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibraryVATLedger.CreateCustomerEAEU());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Qty1 + Qty2);

        // [GIVEN] Item Tracking Line with "CD1" of Qty = 1, Item Tracking Line with "CD2" of Qty = 2,
        CreateSalesLineTracking(SalesLine, CDNo1, Qty1);
        CreateSalesLineTracking(SalesLine, CDNo2, Qty2);
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [WHEN] Run Order Factura-Invoice
        FacturaInvoiceExcelExport(SalesHeader, false);

        // [THEN] Sales Line for ItemNo = "X" is exported with Quantity = 3, Amounts, fields for Custom Declaration are filled in with dashes
        VerifySalesLineColumns(
          22, SalesLine."No.",
          Format(SalesLine.Quantity), Format(SalesLine."Unit Price"), FormatAmount(SalesLine.Amount), Format(SalesLine."VAT %"),
          FormatAmount(SalesLine."Amount Including VAT" - SalesLine.Amount),
          FormatAmount(SalesLine."Amount Including VAT"),
          '-', '-');
        // [THEN] Country Code and Custom Declaration "CD1" are exported for ItemNo = "X" with Quantity = 1, Amounts are filled in with dashes
        VerifySalesLineColumns(
          23, SalesLine."No.",
          Format(Qty1), '-', '-', '-', '-', '-',
          CountryCode1, CDNo1);
        // [THEN] Country Code and Custom Declaration "CD2" are exported for ItemNo = "X" with Quantity = 2, Amounts are filled in with dashes
        VerifySalesLineColumns(
          24, SalesLine."No.",
          Format(Qty2), '-', '-', '-', '-', '-',
          CountryCode2, CDNo2);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        Clear(LibraryReportValidation);

        if IsInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        UpdateStockOutWarning();
        UpdateCompanyInformation();

        IsInitialized := true;
    end;

    local procedure CreateCountryRegion(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion.Validate(Name, LibraryUtility.GenerateGUID());
        CountryRegion.Validate("Local Country/Region Code", CountryRegion.Code);
        CountryRegion.Modify(true);
        exit(CountryRegion.Code);
    end;

    local procedure CreateCustomDeclaration(var CDNo: Code[30]; var CountryCode: Code[10]; ItemNo: Code[20])
    var
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
    begin
        CountryCode := CreateCountryRegion();
        LibraryCDTracking.CreateCDNumberHeader(CDNumberHeader, CountryCode);
        CDNo := LibraryUtility.GenerateGUID();
        LibraryCDTracking.UpdatePackageInfo(CDNumberHeader, PackageNoInformation, ItemNo, CDNo);
    end;

    local procedure CreateItemWithItemTracking(): Code[20]
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        CDLocationSetup: Record "CD Location Setup";
    begin
        Item.Get(CreateItemNoWithTariff());
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, '');
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Validate("Unit Price", LibraryRandom.RandInt(100));
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreateSalesLineTracking(SalesLine: Record "Sales Line"; CDNo: Code[30]; Qty: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', '', CDNo, Qty);
    end;

    local procedure CreateItemNoWithTariff(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        with Item do begin
            Validate(Description, CopyStr(LibraryUtility.GenerateRandomAlphabeticText(MaxStrLen(Description), 0), 1, MaxStrLen(Description)));
            Validate("Unit Price", LibraryRandom.RandDecInRange(1000, 2000, 2));
            Validate("Tariff No.", CreateTariffNo());
            Modify(true);
            exit("No.");
        end;
    end;

    local procedure CreateTariffNo(): Code[20]
    var
        TariffNumber: Record "Tariff Number";
    begin
        with TariffNumber do begin
            Init();
            "No." := LibraryUtility.GenerateRandomCode(FieldNo("No."), DATABASE::"Tariff Number");
            Description := LibraryUtility.GenerateGUID();
            Insert();
            exit("No.");
        end;
    end;

    local procedure FacturaInvoiceExcelExport(SalesHeader: Record "Sales Header"; IsProforma: Boolean) FileName: Text
    var
        OrderFacturaInvoiceA: Report "Order Factura-Invoice (A)";
    begin
        LibraryReportValidation.SetFileName(SalesHeader."No.");
        FileName := LibraryReportValidation.GetFileName();
        Commit();
        SalesHeader.SetRange("No.", SalesHeader."No.");
        OrderFacturaInvoiceA.SetTableView(SalesHeader);
        OrderFacturaInvoiceA.InitializeRequest(1, 1, false, false, IsProforma);
        OrderFacturaInvoiceA.SetFileNameSilent(FileName);
        OrderFacturaInvoiceA.UseRequestPage(false);
        OrderFacturaInvoiceA.Run();
    end;

    local procedure UpdateStockOutWarning()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        with SalesReceivablesSetup do begin
            Get();
            "Stockout Warning" := false;
            Modify(true);
        end;
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            "Bank Name" := LibraryUtility.GenerateGUID();
            "Bank City" := LibraryUtility.GenerateGUID();
            "VAT Registration No." := LibraryUtility.GenerateGUID();
            "KPP Code" := LibraryUtility.GenerateGUID();
            "Full Name" := LibraryUtility.GenerateGUID();
            "Bank Branch No." := LibraryUtility.GenerateGUID();
            "Bank BIC" := LibraryUtility.GenerateGUID();
            "Bank Corresp. Account No." := LibraryUtility.GenerateGUID();
            "Bank Account No." := LibraryUtility.GenerateGUID();
            "Country/Region Code" := LibraryVATLedger.MockCountryEAEU();
            Modify();
        end;
        LibraryRUReports.UpdateCompanyAddress();
    end;

    local procedure FormatAmount(DecimalValue: Decimal): Text
    begin
        exit(Format(DecimalValue, 0, '<Sign><Integer Thousand><Decimal,3><Filler Character,0>'));
    end;

    local procedure VerifySalesLineColumns(LineNo: Integer; ItemNo: Code[20]; Qty: Text; UnitPrice: Text; Amount: Text; VATPct: Text; VATAmt: Text; AmtInclVAT: Text; CountryCode: Code[10]; CDNo: Code[30])
    var
        Item: Record Item;
        Offset: Integer;
        FileName: Text;
    begin
        Offset := LineNo - 22;
        Item.Get(ItemNo);
        FileName := LibraryReportValidation.GetFileName();
        LibraryRUReports.VerifyFactura_ItemNo(FileName, Item.Description, 0);
        LibraryRUReports.VerifyFactura_TariffNo(FileName, Item."Tariff No.", 0);
        LibraryRUReports.VerifyFactura_Qty(FileName, Qty, Offset);
        LibraryRUReports.VerifyFactura_Price(FileName, UnitPrice, Offset);
        LibraryRUReports.VerifyFactura_Amount(FileName, Amount, Offset);
        LibraryRUReports.VerifyFactura_VATPct(FileName, VATPct, Offset);
        LibraryRUReports.VerifyFactura_VATAmount(FileName, VATAmt, Offset);
        LibraryRUReports.VerifyFactura_AmountInclVAT(FileName, AmtInclVAT, Offset);
        LibraryRUReports.VerifyFactura_CountryCode(FileName, CountryCode, Offset);
        LibraryRUReports.VerifyFactura_GTD(FileName, CDNo, Offset);
    end;
}
