codeunit 147100 "Library - CD Tracking"
{

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryRandom: Codeunit "Library - Random";
        AvailableQtyToTakeErr: Label 'Available Qty. to Take field is incorrect';

    [Scope('OnPrem')]
    procedure CreateCDNumberHeaderWithCountryRegion(var CDNumberHeader: Record "CD Number Header")
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.FindFirst();
        CreateCDNumberHeader(CDNumberHeader, CountryRegion.Code);
    end;

    [Scope('OnPrem')]
    procedure CreateCDNumberHeader(var CDNumberHeader: Record "CD Number Header"; CountryCode: Code[10])
    begin
        CDNumberHeader.Init();
        CDNumberHeader."No." := LibraryUtility.GenerateRandomCode(CDNumberHeader.FieldNo("No."), DATABASE::"CD Number Header");
        CDNumberHeader."Country/Region of Origin Code" := CountryCode;
        CDNumberHeader."Source Type" := CDNumberHeader."Source Type"::Vendor;
        CDNumberHeader.Insert();
    end;

    [Scope('OnPrem')]
    procedure UpdatePackageInfo(CDNumberHeader: Record "CD Number Header"; var PackageNoInformation: Record "Package No. Information"; ItemNo: Code[20]; PackageNo: Code[50])
    begin
        if PackageNoInformation.Get(ItemNo, '', PackageNo) then begin
            PackageNoInformation."CD Header Number" := CDNumberHeader."No.";
            PackageNoInformation.Modify();
        end else begin
            PackageNoInformation.Init();
            PackageNoInformation."Item No." := ItemNo;
            PackageNoInformation."Package No." := PackageNo;
            PackageNoInformation."CD Header Number" := CDNumberHeader."No.";
            PackageNoInformation."Country/Region Code" := CDNumberHeader."Country/Region of Origin Code";
            PackageNoInformation.Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateCDFAInformation(CDNumberHeader: Record "CD Number Header"; var CDFAInformation: Record "CD FA Information"; FANo: Code[20]; CDNo: Code[50])
    begin
        if CDFAInformation.Get(FANo, CDNo) then begin
            CDFAInformation."CD Header Number" := CDNumberHeader."No.";
            CDFAInformation.Modify();
        end else begin
            CDFAInformation.Init();
            CDFAInformation."FA No." := FANo;
            CDFAInformation."CD No." := CDNo;
            CDFAInformation."CD Header Number" := CDNumberHeader."No.";
            CDFAInformation."Country/Region Code" := CDNumberHeader."Country/Region of Origin Code";
            CDFAInformation.Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateJnlLine(JnlTemplateName: Code[10]; JnlBatchName: Code[10]; JnlBatchSeries: Code[20]; var ItemJournalLine: Record "Item Journal Line"; EntryType: Enum "Item Ledger Entry Type"; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10])
    var
        NoSeries: Codeunit "No. Series";
        LineNo: Integer;
    begin
        with ItemJournalLine do begin
            SetRange("Journal Template Name", JnlTemplateName);
            SetRange("Journal Batch Name", JnlBatchName);
            if FindLast() then;
            LineNo := "Line No." + 10000;

            Init();
            "Journal Template Name" := JnlTemplateName;
            "Journal Batch Name" := JnlBatchName;
            "Line No." := LineNo;
            Insert(true);
            Validate("Posting Date", PostingDate);
            "Document No." := NoSeries.GetNextNo(JnlBatchSeries, "Posting Date");
            Validate("Entry Type", EntryType);
            Validate("Item No.", ItemNo);
            Validate(Quantity, Qty);
            Validate("Location Code", LocationCode);
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; EntryType: Enum "Item Ledger Entry Type"; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10])
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        FindItemJnlTemplate(ItemJournalTemplate, "Item Journal Template Type"::Item);
        FindItemJnlBatch(ItemJournalBatch, "Item Journal Template Type"::Item.AsInteger(), ItemJournalTemplate.Name);
        CreateJnlLine(ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalBatch."No. Series",
          ItemJournalLine, EntryType, PostingDate, ItemNo, Qty, LocationCode);
    end;

    [Scope('OnPrem')]
    procedure CreateItemRecLine(var ItemJournalLine: Record "Item Journal Line"; EntryType: Enum "Item Ledger Entry Type"; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
        WhseJnlTemplateType: Option Item,"Physical Inventory",Reclassification;
    begin
        WarehouseJournalTemplate.SetRange(Type, WhseJnlTemplateType::Reclassification);
        WarehouseJournalTemplate.FindFirst();
        FindItemJnlBatch(ItemJournalBatch, WhseJnlTemplateType, WarehouseJournalTemplate.Name);
        CreateJnlLine(WarehouseJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalBatch."No. Series",
          ItemJournalLine, EntryType, PostingDate, ItemNo, Qty, LocationCode);
    end;

    [Scope('OnPrem')]
    procedure PostItemJnlLine(ItemJournalLine: Record "Item Journal Line")
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    [Scope('OnPrem')]
    procedure FindItemJnlTemplate(var ItemJournalTemplate: Record "Item Journal Template"; ItemJournalTemplateType: Enum "Item Journal Template Type")
    begin
        // Find Item Journal Template for the given Template Type.
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplateType);
        ItemJournalTemplate.FindFirst();
    end;

    [Scope('OnPrem')]
    procedure FindItemJnlBatch(var ItemJournalBatch: Record "Item Journal Batch"; ItemJnlBatchTemplateType: Option; ItemJnlTemplateName: Code[10])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Find Name for Batch Name.
        ItemJournalBatch.SetRange("Template Type", ItemJnlBatchTemplateType);
        ItemJournalBatch.SetRange("Journal Template Name", ItemJnlTemplateName);

        // If Item Journal Batch not found then create it.
        if not ItemJournalBatch.FindFirst() then
            CreateItemJnlBatch(ItemJournalBatch, ItemJnlTemplateName);

        if ItemJournalBatch."No. Series" = '' then begin
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
            ItemJournalBatch."No. Series" := NoSeries.Code;
        end;
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateItemJnlBatch(var ItemJournalBatch: Record "Item Journal Batch"; ItemJnlTemplateName: Code[10])
    begin
        // Create Item Journal Batch with a random Name of String length less than 10.
        ItemJournalBatch.Init();
        ItemJournalBatch.Validate("Journal Template Name", ItemJnlTemplateName);
        ItemJournalBatch.Validate(
          Name, CopyStr(LibraryUtility.GenerateRandomCode(ItemJournalBatch.FieldNo(Name), DATABASE::"Item Journal Batch"), 1,
            MaxStrLen(ItemJournalBatch.Name)));
        ItemJournalBatch.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreateFAActHeader(var FADocumentHeader: Record "FA Document Header"; DocType: Option Writeoff,Release,Movement; PostingDate: Date)
    begin
        FADocumentHeader.Init();
        FADocumentHeader."Document Type" := DocType;
        FADocumentHeader.Insert(true);
        FADocumentHeader.Validate("Posting Date", PostingDate);
        FADocumentHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure CreateFAActLine(DocType: Option Writeoff,Release,Movement; FADocNo: Code[20]; FANo: Code[20])
    var
        FADocumentLine: Record "FA Document Line";
    begin
        FADocumentLine.Init();
        FADocumentLine."Document Type" := DocType;
        FADocumentLine."Document No." := FADocNo;
        FADocumentLine."Line No." := 10000;
        FADocumentLine.Validate("FA No.", FANo);
        FADocumentLine.Insert();
    end;

    [Scope('OnPrem')]
    procedure CreateFAWriteOffAct(var FADocumentHeader: Record "FA Document Header"; FANo: Code[20]; PostingDate: Date)
    var
        DocType: Option Writeoff,Release,Movement;
    begin
        CreateFAActHeader(FADocumentHeader, DocType::Writeoff, PostingDate);
        CreateFAActLine(DocType::Writeoff, FADocumentHeader."No.", FANo);
    end;

    [Scope('OnPrem')]
    procedure PostFAWriteOffAct(FADocumentHeader: Record "FA Document Header")
    var
        FADocumentPost: Codeunit "FA Document-Post";
    begin
        FADocumentPost.Run(FADocumentHeader);
    end;

    [Scope('OnPrem')]
    procedure CreateFAReleaseAct(var FADocumentHeader: Record "FA Document Header"; FANo: Code[20]; PostingDate: Date)
    var
        DocType: Option Writeoff,Release,Movement;
    begin
        CreateFAActHeader(FADocumentHeader, DocType::Release, PostingDate);
        CreateFAActLine(DocType::Release, FADocumentHeader."No.", FANo);
    end;

    [Scope('OnPrem')]
    procedure PostFAReleaseAct(FADocumentHeader: Record "FA Document Header")
    var
        FADocumentPost: Codeunit "FA Document-Post";
    begin
        FADocumentPost.Run(FADocumentHeader);
    end;

    [Scope('OnPrem')]
    procedure CreateCDTracking(var CDLocationSetup: Record "CD Location Setup"; ItemTrackingCode: Code[10]; CDLocationCode: Code[10])
    begin
        CDLocationSetup."Item Tracking Code" := ItemTrackingCode;
        CDLocationSetup."Location Code" := CDLocationCode;
        CDLocationSetup.Insert();
    end;

    [Scope('OnPrem')]
    procedure CreateForeignVendor(var Vendor: Record Vendor)
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateRandomExchangeRate(Currency.Code);
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Currency Code", Currency.Code);
        Vendor.Modify(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePurchLineFA(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; FANo: Code[20]; UnitCost: Decimal; Quantity: Decimal)
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Fixed Asset", FANo, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", UnitCost);
        PurchaseLine.Modify();
    end;

    [Scope('OnPrem')]
    procedure CreateSalesLineFA(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; FANo: Code[20]; UnitPrice: Decimal; Quantity: Decimal)
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Fixed Asset", FANo, Quantity);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify();
    end;

    [Scope('OnPrem')]
    procedure CreateVATPurchaseLedger(StartDate: Date; EndDate: Date; VendorFilter: Text[250]): Code[20]
    var
        VATLedger: Record "VAT Ledger";
        CreateVATPurchaseLedgerRep: Report "Create VAT Purchase Ledger";
    begin
        // TODO Method is copied from codeunit 82404 and should be replaced by original version
        // after the merge with VAT_Update functionality
        VATLedger.Init();
        VATLedger.Type := VATLedger.Type::Purchase;
        VATLedger.Insert(true);
        VATLedger.Validate("Start Date", StartDate);
        VATLedger.Validate("End Date", EndDate);
        VATLedger.Modify();

        VATLedger.SetRecFilter();
        CreateVATPurchaseLedgerRep.SetTableView(VATLedger);
        CreateVATPurchaseLedgerRep.UseRequestPage(false);
        CreateVATPurchaseLedgerRep.SetParameters(VendorFilter, '', '', 0, false, false, 0, 0, true, true, true, true);
        CreateVATPurchaseLedgerRep.Run();

        exit(VATLedger.Code);
    end;

    [Scope('OnPrem')]
    procedure CreateVATSalesLedger(StartDate: Date; EndDate: Date; CustFilter: Text[250]): Code[20]
    var
        VATLedger: Record "VAT Ledger";
        CreateVATSalesLedgerRep: Report "Create VAT Sales Ledger";
    begin
        // TODO Method is copied from codeunit 82404 and should be replaced by original version
        // after the merge with VAT_Update functionality
        VATLedger.Init();
        VATLedger.Type := VATLedger.Type::Sales;
        VATLedger.Insert(true);
        VATLedger.Validate("Start Date", StartDate);
        VATLedger.Validate("End Date", EndDate);
        VATLedger.Modify();

        VATLedger.SetRecFilter();
        CreateVATSalesLedgerRep.SetTableView(VATLedger);
        CreateVATSalesLedgerRep.UseRequestPage(false);
        CreateVATSalesLedgerRep.SetParameters(CustFilter, '', '', 0, false, false, true, true, true, true, true);
        CreateVATSalesLedgerRep.Run();

        exit(VATLedger.Code);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateWMSLocation(var Location: Record Location)
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Location."Require Receive" := true;
        Location."Require Shipment" := true;
        Location."Require Put-away" := true;
        Location."Require Pick" := true;
        Location."Bin Mandatory" := true;
        Location."Directed Put-away and Pick" := false;
        Location.Modify();
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateBin(Location: Record Location; BinNo: Integer): Code[20]
    var
        Bin: Record Bin;
    begin
        Bin.Init();
        Bin."Location Code" := Location.Code;
        Bin.Code := Location.Code + Format(BinNo);
        Bin.Insert();
        exit(Bin.Code);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure PostWarehouseActivityLine(Location: Record Location; BinCode: Code[20]; Qty: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActRegisterYesNo: Codeunit "Whse.-Act.-Register (Yes/No)";
    begin
        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetCurrentKey("Location Code");
        WarehouseActivityLine.SetFilter("Location Code", Location.Code);
        WarehouseActivityLine.FindSet();
        repeat
            if WarehouseActivityLine."Bin Code" = '' then
                WarehouseActivityLine."Bin Code" := BinCode;
            WarehouseActivityLine.Validate("Qty. to Handle", Qty);
            WarehouseActivityLine.Modify();
        until WarehouseActivityLine.Next() = 0;

        WhseActRegisterYesNo.Run(WarehouseActivityLine);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure RegisterPick(Location: Record Location; Qty: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActRegisterYesNo: Codeunit "Whse.-Act.-Register (Yes/No)";
    begin
        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetCurrentKey("Location Code");
        WarehouseActivityLine.SetFilter("Location Code", Location.Code);
        WarehouseActivityLine.FindSet();
        repeat
            WarehouseActivityLine.Validate("Qty. to Handle", Qty);
            WarehouseActivityLine.Modify();
        until WarehouseActivityLine.Next() = 0;

        WhseActRegisterYesNo.Run(WarehouseActivityLine);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure ValidateBinContentQty(Location: Record Location; BinCode: Code[20]; Qty: Decimal)
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.Reset();
        BinContent.SetRange("Location Code", Location.Code);
        BinContent.SetRange("Bin Code", BinCode);
        BinContent.FindFirst();
        Assert.AreEqual(Qty, BinContent.CalcQtyAvailToPick(0), AvailableQtyToTakeErr);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure WhseRcptSetBinCode(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; Item: Record Item; BinCode: Code[20])
    begin
        WarehouseReceiptLine.Reset();
        WarehouseReceiptLine.SetCurrentKey("Item No.");
        WarehouseReceiptLine.SetFilter("Item No.", Item."No.");
        WarehouseReceiptLine.FindFirst();
        WarehouseReceiptLine.Validate("Bin Code", BinCode);
        WarehouseReceiptLine.Modify();
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure WhseShptSetBinCode(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; Item: Record Item; BinCode: Code[20])
    begin
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SetCurrentKey("Item No.");
        WarehouseShipmentLine.SetFilter("Item No.", Item."No.");
        WarehouseShipmentLine.FindFirst();
        WarehouseShipmentLine.Validate("Bin Code", BinCode);
        WarehouseShipmentLine.Modify();
    end;

    [Scope('OnPrem')]
    procedure CreatePickFromWhseShpt(WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WhseShipmentCreatePick: Report "Whse.-Shipment - Create Pick";
    begin
        WhseShipmentCreatePick.SetWhseShipmentLine(WarehouseShipmentLine, WarehouseShipmentHeader);
        WhseShipmentCreatePick.SetHideValidationDialog(true);
        WhseShipmentCreatePick.UseRequestPage(false);
        WhseShipmentCreatePick.RunModal();
    end;

    [Scope('OnPrem')]
    procedure UpdateERMCountryData()
    begin
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
    end;

    [Scope('OnPrem')]
    procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset")
    var
        FASetup: Record "FA Setup";
        TaxRegisterSetup: Record "Tax Register Setup";
        FAPostingGroup: Record "FA Posting Group";
    begin
        FAPostingGroup.SetFilter("Acquisition Cost Account", '<>%1', '');
        FAPostingGroup.SetFilter("Acq. Cost Acc. on Disposal", '<>%1', '');
        FAPostingGroup.FindFirst();
        UpdateGLAccWithVATPostingSetup(FAPostingGroup."Acquisition Cost Account");
        UpdateGLAccWithVATPostingSetup(FAPostingGroup."Acq. Cost Acc. on Disposal");

        FASetup.Get();
        TaxRegisterSetup.Get();
        FixedAsset.Init();
        FixedAsset.Insert(true);
        FixedAsset.InitFADeprBooks(FixedAsset."No.");
        FixedAsset.Modify(true);
        UpdateFADeprBook(FixedAsset."No.", FASetup."Default Depr. Book", FAPostingGroup.Code);
        UpdateFADeprBook(FixedAsset."No.", FASetup."Release Depr. Book", FAPostingGroup.Code);
        UpdateFADeprBook(FixedAsset."No.", TaxRegisterSetup."Tax Depreciation Book", FAPostingGroup.Code);
    end;

    local procedure UpdateFADeprBook(FANo: Code[20]; DeprBookCode: Code[10]; FAPostingGroupCode: Code[20])
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        if FADepreciationBook.Get(FANo, DeprBookCode) then begin
            FADepreciationBook.Validate("FA Posting Group", FAPostingGroupCode);
            FADepreciationBook.Validate("No. of Depreciation Years", 1 + LibraryRandom.RandInt(5));
            FADepreciationBook.Modify(true);
        end;
    end;

    local procedure UpdateGLAccWithVATPostingSetup(GLAccNo: Code[20])
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GLAccount.Get(GLAccNo);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);
    end;
}

