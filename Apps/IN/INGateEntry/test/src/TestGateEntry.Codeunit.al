codeunit 18629 "Test Gate Entry"
{
    Subtype = Test;

    var
        GateEntryLibrary: Codeunit "Gate Entry Library";
        Assert: Codeunit Assert;
        VerifyInventorySetupErr: Label 'Inventory Setup not verified';
        PostedGateEntryStatusErr: Label 'Posted Gate Entry Status is not verified';
        GateEntryPostLbl: Label 'Gate Entry Posted successfully.';
        NotPostedLbl: Label 'Not Posted Successfully';
        SourceTypeErr: Label 'Source Type must not be blank in %1 %2.', Comment = ' %1= FieldCaption("Line No."),  %2 = "Line No."';
        Storage: Dictionary of [Text, Code[10]];
        StorageEnum: Dictionary of [Text, Enum "Gate Entry Source Type"];
        LocationCodeLbl: Label 'LocationCode';
        GateEntrySourceTypeLbl: Label 'GateEntrySourceType';


    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryInwardWithPurchaseOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375108] Check if the program is allowing you to create and post the Gate Entry - Inward form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward 
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    procedure CheckSourceNoValidationOnGateEntryInwardForm()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryLine: Record "Gate Entry Line";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
    begin
        // [SCENARIO] [386187] Check if the program is throwing the error on create and post the Gate Entry - Inward for Source Type Blank
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create Gate Entry Inward  Document
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        RemoveSourceTypeFromGateEntryLine(GateEntryHeader."No.");

        // [THEN] Assert Error Verified
        asserterror GateEntryLine.Validate("Source No.");
        Assert.ExpectedError(StrSubstNo(SourceTypeErr, GateEntryLine.FieldCaption("Line No."), GateEntryLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure CheckPostedGateEntriesInwardStatus()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375151] Check if the program is displaying the status of Gate Entry line in the Posted Gate Entry – Inward History.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Purchase Order 
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Purchase Gate Entry Lines Verified With Status
        VerifyPostedGateEntryLineWithStatus(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryInwardWithDifferentDates()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        GateEntryType: Enum "Gate Entry Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375109] Check if the program is allowing you to post the Gate Entry - Inward form if Document Date is Different From Posting Date.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward With different Posting Date
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        GateEntryHeader.Validate("Posting Date", CalcDate('<1M>', WorkDate()));
        GateEntryHeader.Modify(true);
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryInwardWithDifferentTime()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        GateEntryType: Enum "Gate Entry Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375110] Check if the program is allowing you to post the Gate Entry - Inward form if Document Time is Different From Posting Time.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward With different Time
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        GateEntryHeader.Validate("Posting Time", Time);
        GateEntryHeader.Modify(true);
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyGetGateEntryLinesOnPurchaseOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375160] Check if the program is allowing you to attach posted Gate Entry – Inward record in the Purchase Invoice form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Purchase Order with GetGateEntries
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetPurchaseOrdGateEntryLines(PurchaseHeader."No.");

        // [THEN] Posted Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyAttachedGateEntryLinesOnPurchaseOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375161] Check if the program is displaying the attached posted Gate Entry – Inward record in the Purchase Order form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Purchase Order with Attached Entries
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetPurchaseOrdGateEntryLines(PurchaseHeader."No.");
        GateEntryLibrary.VerifyAttachedPurchaseOrdGateEntryLines(PurchaseHeader."No.");

        // [THEN] Attached Purchase Gate Entries Verified
        GateEntryLibrary.VerifyAttachedGateEntries(PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('NoSeriesPageHandler')]
    procedure VerifyAssistEditButtonOnGateEntryInwardForm()
    var
        GateEntryHeader: Record "Gate Entry Header";
        InventorySetup: Record "Inventory Setup";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
    begin
        // [SCENARIO] Verify Assist Edit Button on Gate Entry Inward Form
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        InventorySetup.Get();
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create Gate Entry Inward Document
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        GateEntryHeader.AssistEdit(GateEntryHeader);

        // [THEN] No. Series Verified on Gate Entry inward form with Inventory Posting Setup
        VerifyInventorySetupWithGateEntryNo(InventorySetup);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure VerifyAttachedGateEntryLinesOnPurchaseInvoice()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375344] Check if the program is displaying the attached posted Gate Entry – Inward record in the Purchase Invoice form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Purchase Invoice
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetPurchaseInvGateEntryLines(PurchaseHeader."No.");
        GateEntryLibrary.VerifyAttachedPurchaseInvGateEntryLines(PurchaseHeader."No.");

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure VerifyGetGateEntryLinesOnPurchaseInvoice()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        GateEntryType: Enum "Gate Entry Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [375343] [Check if the program is allowing you to attach posted Gate Entry – Inward record in the Purchase Invoice form]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Purchase Invoice 
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetPurchaseInvGateEntryLines(PurchaseHeader."No.");
        GateEntryLibrary.VerifyAttachedPurchaseInvGateEntryLines(PurchaseHeader."No.");

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    procedure VerifyInventorySetupWithGateEntryNos()
    var
        InventorySetup: Record "Inventory Setup";
        InwardGateEntryNo: Code[20];
        OutwardGateEntryNo: Code[20];
    begin
        // [SCENARIO] [375093] [Check if the program is allowing you to insert the number from the series you have defined in Inventory Setup while recording an entry using the Gate Entry - Inward form.]
        // [GIVEN] Create Inward and Outward Gate Entry Nos
        InventorySetup.Get();
        InwardGateEntryNo := GateEntryLibrary.CreateNoSeries();
        OutwardGateEntryNo := GateEntryLibrary.CreateNoSeries();

        // [WHEN] Validated Inward and Outward Gate Entry No in Inventory Setup
        InventorySetup.Validate("Inward Gate Entry Nos.", InwardGateEntryNo);
        InventorySetup.Validate("Outward Gate Entry Nos.", OutwardGateEntryNo);
        InventorySetup.Modify(true);

        // [THEN] Gate Entry Inventory Setup Verified
        VerifyInventorySetupWithGateEntryNo(InventorySetup);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryOutward()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the program is allowing you to create and post the Gate Entry - Outward form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Outward with Source Type Sales Shipment
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Sales Shipment");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Sales Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('NoSeriesPageHandler')]
    procedure VerifyAssistEditButtonOnGateEntryOutwardForm()
    var
        GateEntryHeader: Record "Gate Entry Header";
        InventorySetup: Record "Inventory Setup";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
    begin
        // [SCENARIO] Verify Assist Edit Button on Gate Entry Outward Form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        InventorySetup.Get();
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create Gate Entry Outward with Source Type Sales Shipment
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Sales Shipment");
        GateEntryHeader.AssistEdit(GateEntryHeader);

        // [THEN] Inventory Setup Verified
        VerifyInventorySetupWithGateEntryNo(InventorySetup);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryOutwardWithSalesShipment()
    var
        GateEntryHeader: Record "Gate Entry Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385367] [Check if the program is allowing you to create and post the Gate Entry - Outward for Sales Shipment]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Outward with Source Type Sales Shipment with Attached Entries
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Sales Shipment");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        SalesShipmentHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.VerifyAttachedSalesShpmtGateEntryLines(SalesShipmentHeader."No.");

        // [THEN] Posted Sales Shipment Gate Entries Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryOutwardWithDifferentDate()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the program is allowing you to post the Gate Entry - Outward document where the Document Date is not same as the Posting Date.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Outward with Different Date
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Sales Shipment");
        GateEntryHeader.Validate("Posting Date", CalcDate('<1M>', WorkDate()));
        GateEntryHeader.Modify(true);
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Sales Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryOutwardWithDifferentTime()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the program is allowing you to post the Gate Entry - Outward document where the Document Time is not same as Posting Time.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry IOutward with Different Time
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Sales Shipment");
        GateEntryHeader.Validate("Posting Time", Time);
        GateEntryHeader.Modify(true);
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Sales Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure PostFromGateEntryInwardForSalesReturnOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        SalesHeader: Record "Sales Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is allowing you to create and post the Gate Entry - Outward for Sales Return Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Sales Return Order
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Sales Return Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetSalesRetrnOrdGateEntryLines(SalesHeader."No.");

        // [THEN] Posted Sales Return Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,SalesReturnOrderListHandler,GateEntryPostMsgHandler')]
    procedure VerifySourceNoLookupWithSourceTypeSalesReturnOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Verify Source No Lookup On Gate Entry Inward Form with Source Type Sales Return Order
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Sales Return Order
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Sales Return Order");
        Storage.Set(LocationCodeLbl, GateEntryHeader."Location Code");
        StorageEnum.Set(GateEntrySourceTypeLbl, GateEntrySourceType::"Sales Return Order");
        SourceNoLookUp(GateEntryHeader."No.");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Sales Return Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure PostFromGateEntryInForSalesRetrnOrdWithAttchedEntries()
    var
        GateEntryHeader: Record "Gate Entry Header";
        SalesHeader: Record "Sales Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385812] [Check if the program is allowing you to attach posted Gate Entry – Outward record in the Sales Return Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Sales Return Order with Attached Entries
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Sales Return Order");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetSalesRetrnOrdGateEntryLines(SalesHeader."No.");
        GateEntryLibrary.VerifyAttachedSalesRetrnOrdGateEntryLines(SalesHeader."No.");

        // [THEN] Attached Sales Return Order Gate Entry Lines Verified
        GateEntryLibrary.VerifyAttachedGateEntries(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,PurchaseOrderListHandler,GateEntryPostMsgHandler')]
    procedure VerifySourceNoLookUpOnInwardGateEntrySubform()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Verify Source No LookUp on Inward Gate Entry SubForm
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceNo Lookup
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        Storage.Set(LocationCodeLbl, GateEntryHeader."Location Code");
        StorageEnum.Set(GateEntrySourceTypeLbl, GateEntrySourceType::"Purchase Order");
        SourceNoLookUp(GateEntryHeader."No.");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Posted Purchase Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryOutwardWithTransferShipment()
    var
        GateEntryHeader: Record "Gate Entry Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385770] [Check if the program is allowing you to create and post the Gate Entry - Outward for Transfer Shipment.]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Outward with Source Type Transfer Shipment
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Outward,
            GateEntrySourceType::"Transfer Shipment");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        TransferShipmentHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetTransferGateEntryLines(TransferShipmentHeader."No.");
        GateEntryLibrary.VerifyAttachedTransferOrdGateEntryLines(TransferShipmentHeader."No.");

        // [THEN] Posted Transfer Shipment Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler')]
    procedure PostFromGateEntryInwardWithTransferReceipt()
    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385146] [Check if the program is allowing you to attach posted Gate Entry – Inward record in the Transfer Order – Receipt form.]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Transfer Receipt
        GateEntryLibrary.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Transfer Receipt");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);

        // [THEN] Attached Posted Transfer Receipt Gate Entry Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure PostFromGateEntryInTrnsferRcptWithGetGateEntryLines()
    var
        GateEntryHeader: Record "Gate Entry Header";
        TransferHeader: Record "Transfer Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENAR;IO] [385147] [Check if the program is displaying the attached posted Gate Entry – Inward record in the Transfer Order – Receipt form]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with SourceType Transfer Receipt with GetGateEntries
        GateEntryLibrary.CreateGateEntryDocument(
             GateEntryHeader,
             GateEntryType::Inward,
             GateEntrySourceType::"Transfer Receipt");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        TransferHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetTransferGateEntryLines(TransferHeader."No.");

        // [THEN] Posted Gate Entries Lines Verified
        GateEntryLibrary.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure PostFromGateEntryInTrnsferRcptWithAttchedPostedEntrs()
    var
        GateEntryHeader: Record "Gate Entry Header";
        TransferHeader: Record "Transfer Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENAR;IO] [385150] [Check if the program is displaying attached Gate Entry – Inward record in Posted Purchase Receipt which is created from the Transfer Order – Receipt form]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward and Transfer Receipt Document with Attached Entries
        GateEntryLibrary.CreateGateEntryDocument(
             GateEntryHeader,
             GateEntryType::Inward,
             GateEntrySourceType::"Transfer Receipt");
        PostedDocumentNo := GateEntryLibrary.PostGateEnty(GateEntryHeader);
        TransferHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLibrary.GetTransferGateEntryLines(TransferHeader."No.");
        GateEntryLibrary.VerifyAttachedTransferRcptGateEntryLines(TransferHeader."No.");

        // [THEN] Attached Transfer Receipt Gate Entry Lines Verified
        GateEntryLibrary.VerifyAttachedGateEntries(TransferHeader."No.");
    end;

    local procedure GetSourceNo(PostedDocumentNo: Code[20]): Code[20]
    var
        PostedGateEntryLine: Record "Posted Gate Entry Line";
    begin
        PostedGateEntryLine.SetRange("Gate Entry No.", PostedDocumentNo);
        PostedGateEntryLine.FindFirst();
        exit(PostedGateEntryLine."Source No.");
    end;

    local procedure VerifyInventorySetupWithGateEntryNo(InventorySetup: Record "Inventory Setup")
    begin
        if (InventorySetup."Inward Gate Entry Nos." = '') and (InventorySetup."Outward Gate Entry Nos." = '') then
            Error(VerifyInventorySetupErr);
    end;

    local procedure CreateInventorySetupWithGateEntyNos()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if InventorySetup."Inward Gate Entry Nos." <> '' then
            InventorySetup.Validate("Inward Gate Entry Nos.", InventorySetup."Inward Gate Entry Nos.")
        else
            InventorySetup.Validate("Inward Gate Entry Nos.", GateEntryLibrary.CreateNoSeries());
        if InventorySetup."Outward Gate Entry Nos." <> '' then
            InventorySetup.Validate("Outward Gate Entry Nos.", InventorySetup."Outward Gate Entry Nos.")
        else
            InventorySetup.Validate("Outward Gate Entry Nos.", GateEntryLibrary.CreateNoSeries());
        InventorySetup.Modify(true);
    end;

    local procedure VerifyPostedGateEntryLineWithStatus(PostedDocumentNo: Code[20])
    var
        PostedGateEntryLine: Record "Posted Gate Entry Line";
    begin
        PostedGateEntryLine.SetRange("Gate Entry No.", PostedDocumentNo);
        PostedGateEntryLine.SetFilter(Status, '%1', PostedGateEntryLine.Status::Open);
        if PostedGateEntryLine.IsEmpty then
            Error(PostedGateEntryStatusErr);
    end;

    local procedure RemoveSourceTypeFromGateEntryLine(No: Code[20])
    var
        GateEntryLine: Record "Gate Entry Line";
    begin
        GateEntryLine.SetRange("Gate Entry No.", No);
        GateEntryLine.FindFirst();
        GateEntryLine."Source No." := '';
        GateEntryLine."Source Type" := GateEntryLine."Source Type"::" ";
        GateEntryLine.Modify(true);
    end;

    [ModalPageHandler]
    procedure PostedGateEntryLineListHndlr(var PostedGateEntryLineList: TestPage "Posted Gate Entry Line List")
    begin
        PostedGateEntryLineList.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure GateEntryPostConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure GateEntryPostMsgHandler(SuccessMessage: Text[1024])
    begin
        if SuccessMessage <> GateEntryPostLbl then
            Error(NotPostedLbl);
    end;

    local procedure SourceNoLookUp(DocumentNo: Code[20])
    var
        InwardGateEntrySubForm: TestPage "Inward Gate Entry SubForm";
    begin
        InwardGateEntrySubForm.OpenEdit();
        InwardGateEntrySubForm.Filter.SetFilter("Gate Entry No.", DocumentNo);
        InwardGateEntrySubForm."Source Type".SetValue(StorageEnum.Get(GateEntrySourceTypeLbl));
        InwardGateEntrySubForm."Source No.".Lookup();
        InwardGateEntrySubForm.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure PurchaseOrderListHandler(var PurchaseList: TestPage "Purchase List")
    begin
        PurchaseList.Filter.SetFilter("Location Code", Storage.Get(LocationCodeLbl));
        PurchaseList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SalesReturnOrderListHandler(var SalesList: TestPage "Sales List")
    begin
        SalesList.Filter.SetFilter("Location Code", Storage.Get(LocationCodeLbl));
        SalesList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure NoSeriesPageHandler(var NoSeriesList: TestPage "No. Series")
    begin
        NoSeriesList.OK().Invoke();
    end;
}