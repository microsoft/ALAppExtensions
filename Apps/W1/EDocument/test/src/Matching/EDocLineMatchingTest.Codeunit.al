codeunit 139658 "E-Doc. Line Matching Test"
{

    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;


    var

        Assert: Codeunit Assert;
        LibraryPurchase: Codeunit "Library - Purchase";

    procedure Initialize()
    var
        PurchaseLine: Record "Purchase Line";
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        EDocImportedLine.DeleteAll();
        PurchaseLine.DeleteAll();
    end;

    [Test]
    procedure MatchOneImportLineToOnePOLineSuccess()
    var
        EDocument: Record "E-Document";
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocOrderLineMatchingPage: TestPage "E-Doc. Order Line Matching";
    begin
        // [FEATURE] [E-Document] [Matching] 
        // [SCENARIO] Match single imported line of type Item to single PO line of type Item

        // Setup E-Document with link to purchase order
        Initialize();

        // [GIVEN] We create e-document and PO line with Qty 5
        PurchaseHeader := CreatePurchaseLine(5);
        CreateEDocumentWithPOReference(PurchaseHeader);

        // Receive
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);
        EDocument.FindLast();

        // [GIVEN] We imported a item with quantity 5
        CreateImportedLine(EDocument, 10000, 5, Enum::"Purchase Line Type"::Item);
        Assert.RecordCount(EDocImportedLine, 1);
        Assert.RecordCount(PurchaseLine, 1);

        // [WHEN] Open Matching page and select first entry
        Commit();
        EDocOrderLineMatchingPage.OpenEdit();
        EDocOrderLineMatchingPage.Last();
        EDocOrderLineMatchingPage.ImportedLines.First();
        EDocOrderLineMatchingPage.OrderLines.First();

        // [THEN] we have qty 5 and matched 0 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 0
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('0', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');

        // [GIVEN] We click "Match Manually" action
        EDocOrderLineMatchingPage.MatchManual_Promoted.Invoke();

        // [THEN] we have qty 5 and matched 5 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines.Quantity.Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.ImportedLines."Matched Quantity".Value(), '');
        // [THEN] we have qty 5 and qty to invoice 5 
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Available Quantity".Value(), '');
        Assert.AreEqual('5', EDocOrderLineMatchingPage.OrderLines."Qty. to Invoice".Value(), '');
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
        Initialize();

        // [GIVEN] We create e-document and PO line with Qty 5
        PurchaseHeader := CreatePurchaseLine(5);
        CreateEDocumentWithPOReference(PurchaseHeader);

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
        Initialize();

        // [GIVEN] We create e-document and PO line with Qty 5
        PurchaseHeader := CreatePurchaseLine(5);
        CreateEDocumentWithPOReference(PurchaseHeader);

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

    local procedure CreateEDocumentWithPOReference(PurchaseHeader: Record "Purchase Header")
    var
        EDocument: Record "E-Document";
    begin
        EDocument.Init();
        EDocument."Order No." := PurchaseHeader."No.";
        EDocument."Document Record ID" := PurchaseHeader.RecordId();
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Order";
        EDocument.Insert();
    end;

    local procedure CreatePurchaseLine(Quantity: Integer): Record "Purchase Header";
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindLast();
        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Validate("Qty. to Invoice", 0);
        PurchaseLine.Modify();

        exit(PurchaseHeader);
    end;

    local procedure AddPurchaseLine(Quantity: Integer; Type: Enum "Purchase Line Type")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader.FindLast();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, '', Quantity);
        PurchaseLine.FindLast();
        PurchaseLine.Validate("Qty. to Invoice", 0);
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

    local procedure CreateImportedLine(EDocument: Record "E-Document"; LineNo: Integer; Quantity: Integer; Type: Enum "Purchase Line Type")
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        EDocImportedLine.Init();
        EDocImportedLine."E-Document Entry No." := EDocument."Entry No";
        EDocImportedLine."Line No." := LineNo;
        EDocImportedLine.Quantity := Quantity;
        EDocImportedLine.Type := Type;
        EDocImportedLine.Insert();
    end;


}