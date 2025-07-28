codeunit 139659 "E-Doc. Line Matching Test"
{

    Subtype = Test;
    TestType = Uncategorized;
    EventSubscriberInstance = Manual;


    var

        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        Assert: Codeunit Assert;
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        Any: Codeunit Any;
        MatchingLineType: Enum "Purchase Line Type";
        MatchingLineNo: Code[20];
        IsInitialized: Boolean;

    procedure Initialize(Integration: Enum "Service Integration")
    begin
        LibraryPermission.SetOutsideO365Scope();
        if IsInitialized then
            exit;

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::Mock, Integration);

        IsInitialized := true;
    end;

    [Test]
    procedure MatchOneImportLineToOnePOLineSuccess()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match single imported line of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");

        // [GIVEN] We imported a item with quantity 5
        CreateImportedLine(EDocument, 10000, 5, Enum::"Purchase Line Type"::Item);
        Assert.RecordCount(EDocImportedLine, 1);
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        LibraryPermission.SetTeamMember();

        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);

        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] we have qty 5 and matched 0 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 0
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');

        // [GIVEN] We click "Match Manually" action
        EDocOrderLineMatchingPage.MatchManual_Promoted.Invoke();

        // [THEN] we have qty 5 and matched 5 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 5 
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');
    end;

    [Test]
    [HandlerFunctions('EDocumentLineCreationHandler,MessageHandler,PurchaseOrderHandler')]
    procedure MatchOneImportLineToOnePOLineThroughCreatePOLineSuccessItem()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        MatchingItem: Record Item;
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match single imported line of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");

        EDocImportedLine.DeleteAll();

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);
        LibraryEDoc.GetGenericItem(MatchingItem);
        MatchingLineType := Enum::"Purchase Line Type"::Item;
        MatchingLineNo := PurchaseLine."No.";

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");

        // [GIVEN] We imported a item with quantity 5
        CreateImportedLine(EDocument, 10000, 5, MatchingItem);
        Assert.RecordCount(EDocImportedLine, 1);
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        LibraryPermission.SetTeamMember();

        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);

        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] we have qty 5 and matched 0 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 0
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');

        // [GIVEN] We click create the purchase order line and receive all items
        LibraryPermission.SetO365BusFull();
        EDocOrderLineMatchingPage.ImportedLines.CreatePurchaseOrderLine.Invoke();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);

        // [WHEN] We click "Match Automatically" action
        EDocOrderLineMatchingPage.MatchAuto_Promoted.Invoke();
        EDocOrderLineMatchingPage.OrderLines.Last();

        // [THEN] we have qty 5 and matched 5 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 5 
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');
    end;

    [Test]
    [HandlerFunctions('EDocumentLineCreationHandler,MessageHandler')]
    procedure MatchOneImportLineToOnePOLineThroughCreatePOLineSuccessGLAccount()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match single imported line of type G/L Account to single PO line of type G/L Account

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");

        EDocImportedLine.DeleteAll();
        if not VATPostingSetup.Get(Vendor."VAT Bus. Posting Group", '') then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, Vendor."VAT Bus. Posting Group", '');

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");

        // [GIVEN] We imported a G/L Account line with quantity 5
        CreateImportedLine(EDocument, 10000, 5, Enum::"Purchase Line Type"::"G/L Account");
        EDocImportedLine.FindLast();
        EDocImportedLine."Unit Of Measure Code" := PurchaseLine."Unit of Measure Code";
        EDocImportedLine."Direct Unit Cost" := PurchaseLine."Direct Unit Cost";
        EDocImportedLine."Line Discount %" := PurchaseLine."Line Discount %";
        EDocImportedLine.Modify();
        Assert.RecordCount(EDocImportedLine, 1);
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        LibraryPermission.SetTeamMember();

        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);

        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] we have qty 5 and matched 0 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Invalid imported line quantity before matching.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Invalid imported line matched quantity before matching.');
        // [THEN] we have qty 0 and qty to invoice 0 since the item line has not been received
        Assert.AreEqual('0.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Invalid order line available quantity before matching.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Invalid order line quantity to invoice before matching.');

        // [GIVEN] We use create PO line action to create a matching G/L Account in the invoice and a matching rule for it
        LibraryPermission.SetO365BusFull();
        MatchingLineType := Enum::"Purchase Line Type"::"G/L Account";
        MatchingLineNo := LibraryERM.CreateGLAccountNo();
        EDocOrderLineMatchingPage.ImportedLines.CreatePurchaseOrderLine.Invoke();

        // [WHEN] We click "Match Automatically" action
        EDocOrderLineMatchingPage.MatchAuto_Promoted.Invoke();

        // [THEN] we have qty 5 and matched 5
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Invalid imported line quantity after matching.');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Invalid imported line matched quantity after matching.');
        // [THEN] The newly created PO line is matched
        EDocOrderLineMatchingPage.OrderLines.Last();
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Invalid order line available quantity after matching.');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Invalid order line quantity to invoice after matching.');
    end;

    [Test]
    procedure MatchTwoImportLineToOnePOLineSuccess()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary;
        EDocumentLineMatching: Codeunit "E-Doc. Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match two imported lines of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();


        // [GIVEN] We imported item A with quantity 2 and item B with quantity 3
        CreateImportedLine(TempEDocImportedLine, EDocument, 10000, 2, Enum::"Purchase Line Type"::Item);
        CreateImportedLine(TempEDocImportedLine, EDocument, 20000, 3, Enum::"Purchase Line Type"::Item);

        // [GIVEN] 2 Imported lines selected and 1 purchase line
        TempEDocImportedLine.FindSet();
        Assert.RecordCount(TempEDocImportedLine, 2);
        PurchaseLine.FindLast();
        PurchaseLine."Qty. to Invoice" := 0;
        PurchaseLine.Modify();
        TempPurchaseLine := PurchaseLine;
        TempPurchaseLine.Insert();

        // [THEN] Match manually 
        LibraryPermission.SetTeamMember();
        EDocumentLineMatching.MatchManually(TempEDocImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);

        TempEDocImportedLine.FindSet();
        Assert.AreEqual(TempEDocImportedLine.Quantity, TempEDocImportedLine."Matched Quantity", '');
        TempEDocImportedLine.Next();
        Assert.AreEqual(TempEDocImportedLine.Quantity, TempEDocImportedLine."Matched Quantity", '');
    end;

    [Test]
    procedure MatchTwoImportLineToOnePOLineFailure()
    var
        EDocument: Record "E-Document";
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocumentLineMatching: Codeunit "E-Doc. Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match two imported lines of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();

        // [GIVEN] We imported item A with quantity 2 and item B with quantity 4
        CreateImportedLine(TempEDocImportedLine, EDocument, 10000, 2, Enum::"Purchase Line Type"::Item);
        CreateImportedLine(TempEDocImportedLine, EDocument, 20000, 4, Enum::"Purchase Line Type"::Item);

        // [GIVEN] 2 Imported lines selected and 1 purchase line
        TempEDocImportedLine.FindSet();
        Assert.RecordCount(TempEDocImportedLine, 2);
        PurchaseLine.FindLast();
        PurchaseLine."Qty. to Invoice" := 0;
        PurchaseLine.Modify();
        TempPurchaseLine := PurchaseLine;
        TempPurchaseLine.Insert();

        TempEDocImportedLine.Next();

        // [THEN] Match manually will assign what can be assigned
        LibraryPermission.SetTeamMember();
        EDocumentLineMatching.MatchManually(TempEDocImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);

        // [THEN] Quantity was partially assigned
        // Second line only 3 out of 4
        TempEDocImportedLine.FindSet();
        Assert.AreEqual(TempEDocImportedLine.Quantity, TempEDocImportedLine."Matched Quantity", '');
        TempEDocImportedLine.Next();
        Assert.AreEqual(3, TempEDocImportedLine."Matched Quantity", '');

        // [THEN] Apply fails as partial assignment is not allowed
        asserterror EDocumentLineMatching.ApplyToPurchaseOrder(EDocument, TempEDocImportedLine);
        Assert.ExpectedError('Matching of Imported Line 20000 is incomplete. It is not fully matched to purchase order lines.');
    end;

    [Test]
    procedure CreateMatchingRulesFromCopilotScenario()
    var
        EDocument: Record "E-Document";
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemReference: Record "Item Reference";
        EDocumentLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Persisting Copilot changes creates matching rules

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::"Mock");
        ItemReference.SetRange("Reference Type No.", Vendor."No.");
        ItemReference.DeleteAll();

        // [GIVEN] A purchase order with Qty 5 that has been received
        CreateAndReceivePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);

        // [GIVEN] An E-Doc with 3 imported items of quantities 1, 2 and 2
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);
        EDocument.FindLast();
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        CreateImportedLine(TempEDocImportedLine, EDocument, 10000, 1, PurchaseLine);
        CreateImportedLine(TempEDocImportedLine, EDocument, 20000, 2, PurchaseLine);
        CreateImportedLine(TempEDocImportedLine, EDocument, 30000, 2, PurchaseLine);
        Assert.RecordCount(TempEDocImportedLine, 3);

        // [GIVEN] Given these are matched and we setup create matching rules for the first 2 lines
        LibraryPermission.SetTeamMember();
        TempPurchaseLine := PurchaseLine;
        TempPurchaseLine.Insert();
        EDocumentLineMatching.MatchManually(TempEDocImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);
        Assert.RecordCount(TempEDocMatchesThatWasMatched, 3);
        TempEDocMatchesThatWasMatched.FindSet();
        TempEDocMatchesThatWasMatched."Learn Matching Rule" := true;
        TempEDocMatchesThatWasMatched.Modify();
        TempEDocMatchesThatWasMatched.Next();
        TempEDocMatchesThatWasMatched."Learn Matching Rule" := true;
        TempEDocMatchesThatWasMatched.Modify();

        // [GIVEN] We have no Item reference rules
        ItemReference.SetRange("Reference Type No.", Vendor."No.");
        Assert.RecordCount(ItemReference, 0);

        // [WHEN] We persist the changes
        EDocLineMatching.PersistsUpdates(TempEDocMatchesThatWasMatched, false);

        // [THEN] 2 item references are made for the two first imported lines
        Assert.RecordCount(ItemReference, 2);
        TempEDocImportedLine.FindSet();
        ItemReference.SetRange("Reference No.", TempEDocImportedLine."No.");
        ItemReference.FindFirst();
        VerifyItemReference(ItemReference, PurchaseLine."No.", PurchaseLine."Unit of Measure Code", Enum::"Item Reference Type"::Vendor, Vendor."No.", TempEDocImportedLine."No.");

        TempEDocImportedLine.Next();
        ItemReference.SetRange("Reference No.", TempEDocImportedLine."No.");
        ItemReference.FindFirst();
        VerifyItemReference(ItemReference, PurchaseLine."No.", PurchaseLine."Unit of Measure Code", Enum::"Item Reference Type"::Vendor, Vendor."No.", TempEDocImportedLine."No.");

        // [GIVEN] We run the Matching page, remove all matches
        Commit();
        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);
        EDocOrderLineMatchingPage.RemoveAllMatch.Invoke(); // Remove the persisted matches above
        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] The order line is not matched with anything
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Invalid order line available quantity before matching.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Invalid order line quantity to invoice before matching.');

        // [WHEN] Automatic matching is applied
        EDocOrderLineMatchingPage.MatchAuto_Promoted.Invoke();

        // [THEN] The new item references are used and we have matched the first two imported lines of Qty 1 and 2, I.E. 3 is matched in total
        Assert.AreEqual('1', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Invalid imported line quantity after matching.');
        Assert.AreEqual('1', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Invalid imported line matched quantity after matching.');
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Invalid order line available quantity after matching.');
        Assert.AreEqual('3', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Invalid order line quantity to invoice after matching.');

        // [THEN] The last line is not matched
        EDocOrderLineMatchingPage.ImportedLines.Last();
        Assert.AreEqual('2', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Invalid imported line quantity after matching.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Invalid imported line matched quantity after matching.');
    end;

    local procedure VerifyItemReference(ItemReference: Record "Item Reference"; ItemNo: Code[20]; UnitOfMeasure: Code[10]; Type: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[20])
    begin
        Assert.AreEqual(ItemNo, ItemReference."Item No.", 'Incorrect Item No.');
        Assert.AreEqual(UnitOfMeasure, ItemReference."Unit of Measure", 'Incorrect Unit of Measure.');
        Assert.AreEqual(Type, ItemReference."Reference Type", 'Incorrect Reference Type.');
        Assert.AreEqual(ReferenceTypeNo, ItemReference."Reference Type No.", 'Incorrect Reference Type No.');
        Assert.AreEqual(ReferenceNo, ItemReference."Reference No.", 'Incorrect Reference No.');
    end;

    local procedure CreateEDocumentWithPOReference(var EDocument: Record "E-Document"; PurchaseHeader: Record "Purchase Header")
    begin
        EDocument.Init();
        EDocument."Order No." := PurchaseHeader."No.";
        EDocument."Document Record ID" := PurchaseHeader.RecordId();
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Order";
        EDocument.Direction := Enum::"E-Document Direction"::Incoming;
        EDocument."Bill-to/Pay-to No." := PurchaseHeader."Buy-from Vendor No.";
        EDocument.Insert();
        EDocument.SetRecFilter();
    end;

    local procedure CreateAndReceivePurchaseOrderWithLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Quantity: Decimal)
    begin
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        PurchaseLine.FindLast();
        PurchaseLine."Qty. to Invoice" := 0;
        PurchaseLine.Modify();
    end;

    local procedure CreatePurchaseOrderWithLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Quantity: Decimal)
    begin
        LibraryEDoc.CreatePurchaseOrderWithLine(Vendor, PurchaseHeader, PurchaseLine, Quantity);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindLast();
        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Validate("Qty. to Invoice", 0);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify();
    end;

    local procedure CreateImportedLine(var TempEDocImportedLine: Record "E-Doc. Imported Line" temporary; EDocument: Record "E-Document"; LineNo: Integer; Quantity: Integer; MatchingPurchaseLine: Record "Purchase Line")
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        CreateImportedLine(EDocument, LineNo, Quantity, MatchingPurchaseLine.Type);
        EDocImportedLine.FindLast();
        EDocImportedLine."Unit Of Measure Code" := MatchingPurchaseLine."Unit of Measure Code";
        EDocImportedLine."Direct Unit Cost" := MatchingPurchaseLine."Direct Unit Cost";
        EDocImportedLine."Line Discount %" := MatchingPurchaseLine."Line Discount %";
        EDocImportedLine.Modify();
        TempEDocImportedLine.Copy(EDocImportedLine);
        TempEDocImportedLine.Insert();
    end;

    local procedure CreateImportedLine(var TempEDocImportedLine: Record "E-Doc. Imported Line" temporary; EDocument: Record "E-Document"; LineNo: Integer; Quantity: Integer; Type: Enum "Purchase Line Type")
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        CreateImportedLine(EDocument, LineNo, Quantity, Type);
        EDocImportedLine.FindLast();
        TempEDocImportedLine.Copy(EDocImportedLine);
        TempEDocImportedLine.Insert();
    end;

    local procedure CreateImportedLine(EDocument: Record "E-Document"; LineNo: Integer; Quantity: Decimal; Type: Enum "Purchase Line Type")
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        EDocImportedLine.Init();
        EDocImportedLine."E-Document Entry No." := EDocument."Entry No";
        EDocImportedLine."Line No." := LineNo;
        EDocImportedLine.Quantity := Quantity;
        EDocImportedLine.Type := Type;
        EDocImportedLine."No." := CopyStr(Any.AlphanumericText(20), 1, 20);
        EDocImportedLine.Insert();
    end;

    local procedure CreateImportedLine(EDocument: Record "E-Document"; LineNo: Integer; Quantity: Decimal; Item: Record Item)
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        EDocImportedLine.Init();
        EDocImportedLine."E-Document Entry No." := EDocument."Entry No";
        EDocImportedLine."Line No." := LineNo;
        EDocImportedLine.Quantity := Quantity;
        EDocImportedLine.Type := Enum::"Purchase Line Type"::Item;
        EDocImportedLine."Unit Of Measure Code" := Item."Base Unit of Measure";
        EDocImportedLine.Description := Item."No.";
        EDocImportedLine."Direct Unit Cost" := Item."Unit Cost";
        EDocImportedLine.Insert();
    end;

#if not CLEAN26

    [Test]
    internal procedure MatchOneImportLineToOnePOLineSuccess26()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match single imported line of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::Mock);

        EDocImportedLine.DeleteAll();

        // [GIVEN] We create e-document and PO line with Qty 5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");

        // [GIVEN] We imported a item with quantity 5
        CreateImportedLine(EDocument, 10000, 5, Enum::"Purchase Line Type"::Item);
        Assert.RecordCount(EDocImportedLine, 1);
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        LibraryPermission.SetTeamMember();

        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);

        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] we have qty 5 and matched 0 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 0
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');

        // [GIVEN] We click "Match Manually" action
        EDocOrderLineMatchingPage.MatchManual_Promoted.Invoke();

        // [THEN] we have qty 5 and matched 5 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 5 
        Assert.AreEqual('5.00', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');
    end;

#endif

    [Test]
    procedure MatchDecimalQuantitySuccess()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        EDocLog: Codeunit "E-Document Log";
        EDocProcessing: Codeunit "E-Document Processing";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching]
        // [SCENARIO] Match imported line with decimal quantity to purchase order line with decimal quantity

        // Setup E-Document with link to purchase order
        Initialize(Enum::"Service Integration"::Mock);

        // [GIVEN] We create a purchase order with a line of quantity 5.5
        CreatePurchaseOrderWithLine(PurchaseHeader, PurchaseLine, 5.5);
        CreateEDocumentWithPOReference(EDocument, PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();
        EDocLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");
        EDocProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Order Linked");

        // [GIVEN] We imported an item with quantity 5.5
        CreateImportedLine(EDocument, 10000, 5.5, Enum::"Purchase Line Type"::Item);

        // Verify counts
        EDocImportedLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        Assert.RecordCount(EDocImportedLine, 1);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        LibraryPermission.SetTeamMember();

        EDocOrderLineMatchingPage.Trap();
        EDocLineMatching.RunMatching(EDocument);

        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] Verify quantities before matching
        Assert.AreEqual('5.5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Incorrect imported line quantity.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Imported line should not be matched yet.');
        Assert.AreEqual('5.50', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Incorrect order line available quantity.');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Order line should not have quantity to invoice yet.');

        // [GIVEN] We click "Match Manually" action
        EDocOrderLineMatchingPage.MatchManual_Promoted.Invoke();

        // [THEN] Verify quantities after matching
        Assert.AreEqual('5.5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), 'Incorrect imported line quantity after matching.');
        Assert.AreEqual('5.5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), 'Imported line should be fully matched.');
        Assert.AreEqual('5.50', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), 'Incorrect order line available quantity after matching.');
        Assert.AreEqual('5.5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), 'Order line should have quantity to invoice after matching.');
    end;

    [ModalPageHandler]
    internal procedure EDocumentLineCreationHandler(var EDocCreatePurchOrderLine: TestPage "E-Doc. Create Purch Order Line")
    begin
        EDocCreatePurchOrderLine.Type.SetValue(MatchingLineType);
        EDocCreatePurchOrderLine."No.".SetValue(MatchingLineNo);
        EDocCreatePurchOrderLine."Learn matching rule".SetValue(true);
        EDocCreatePurchOrderLine.OK().Invoke();
    end;

    [PageHandler]
    internal procedure PurchaseOrderHandler(var PurchaseOrder: TestPage "Purchase Order")
    begin
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

}
