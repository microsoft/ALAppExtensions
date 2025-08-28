codeunit 144014 "UT REP Doclay"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PurchHeaderCapLbl: Label 'No_PurchaseHeader';
        SalesHeaderCapLbl: Label 'No_SalesHeader';

    [Test]
    [HandlerFunctions('OrderGBRequestPageHandler')]
    procedure OnAfterGetRecordCopyLoopOrderGB()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of CopyLoop of  Report 10576 - Order GB.
        OnAfterGetCopyLoopPurchaseDocument(PurchaseHeader."Document Type"::Order, REPORT::OrderGB, PurchHeaderCapLbl);
    end;

    [Test]
    [HandlerFunctions('BlanketPurchaseOrderGBRequestPageHandler')]
    procedure OnAfterGetRecordCopyLoopBlanketPurchaseOrderGB()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of CopyLoop of Report 10579 - Blanket Purchase Order GB.
        OnAfterGetCopyLoopPurchaseDocument(
          PurchaseHeader."Document Type"::"Blanket Order", REPORT::"Blanket Purch. Order GB", PurchHeaderCapLbl);
    end;

    local procedure OnAfterGetCopyLoopPurchaseDocument(DocumentType: Enum "Purchase Document Type"; ReportID: Option; DocumentNoCaption: Text[30])
    var
        No: Code[20];
    begin
        // Setup: Create Purchase Document.
        Initialize();
        No := CreatePurchaseDocument(DocumentType);
        Commit();  // Codeunit 317 Purch.Header - Printed OnRUN calls commit.

        // Exercise.
        REPORT.Run(ReportID);  // Opens BlanketPurchaseOrderGBRequestPageHandler,OrderGBRequestPageHandler.

        // Verify: Verify Document No. on Report - Order GB, Blanket Purchase Order GB
        VerifyDataOnReport(DocumentNoCaption, No);
    end;

    [Test]
    [HandlerFunctions('PurchaseInvoiceGBRequestPageHandler')]
    procedure OnAfterGetCopyLoopPurchaseInvoiceGB()
    var
        No: Code[20];
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of CopyLoop of Report 10577 Purchase - Invoice GB.

        // Setup: Create Posted Purchase Invoice.
        Initialize();
        No := CreatePostedPurchaseInvoice();
        Commit();  // Codeunit 319 (Purch. Inv.-Printed) OnRun calls commit.

        // Exercise.
        REPORT.Run(REPORT::"Purchase Invoice");  // Open PurchaseInvoiceGBRequestPageHandler.

        // Verify: Verify No_PurchInvHeader on Report - Purchase Invoice GB.
        VerifyDataOnReport('No_PurchInvHeader', No);
    end;

    [Test]
    [HandlerFunctions('PurchaseCreditMemoGBMemoRequestPageHandler')]
    procedure OnAfterGetRecCopyLoopPurchaseCreditMemoGB()
    var
        No: Code[20];
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of CopyLoop of Report 10578 Purchase - Credit Memo GB.

        // Setup: Create Posted Purchase Credit Memo.
        Initialize();
        No := CreatePostedPurchaseCreditMemo();
        Commit();  // Codeunit 320 PurchCrMemo-Printed OnRun Calls commit.

        // Exercise.
        REPORT.Run(REPORT::"Purchase Credit Memo");  // Open PurchaseCreditMemoGBMemoRequestPageHandler.

        // Verify: Verify No_PurchCrMemoHdr on Report Purchase - Credit Memo GB.
        VerifyDataOnReport('No_PurchCrMemoHdr', No);
    end;

    [Test]
    [HandlerFunctions('OrderConfirmationGBRequestPageHandler')]
    procedure OnAfterGetRoundLoopOrderConfirmationGB()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of RoundLoop of Report 10571 Order Confirmation GB.
        OnAfterGetRoundLoopSalesDocument(SalesHeader."Document Type"::Order, REPORT::"Order Confirmation", SalesHeaderCapLbl);
    end;

    [Test]
    [HandlerFunctions('BlanketSalesOrderGBRequestPageHandler')]
    procedure OnAfterGetRoundLoopBlanketSalesOrderGB()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of RoundLoop of Report 10574 Blanket Sales Order GB
        OnAfterGetRoundLoopSalesDocument(SalesHeader."Document Type"::"Blanket Order", REPORT::"Blanket Order Sales GB", SalesHeaderCapLbl);
    end;

    local procedure OnAfterGetRoundLoopSalesDocument(DocumentType: Enum "Sales Document Type"; ReportID: Option; DocumentNoCaption: Text[30])
    var
        No: Code[20];
    begin
        // Setup: Create Sales Document according to the Document Type provided in parameter.
        Initialize();
        No := CreateSalesDocument(DocumentType);
        Commit();  // Commit required since explicit Commit used on OnRun Trigger of COD313: Sales-Printed.

        // Exercise.
        REPORT.Run(ReportID);  // Opens OrderConfirmationGBRequestPageHandler Or BlanketSalesOrderGBRequestPageHandler

        // Verify: Verify Tax Amount on Report - Order Confirmation GB or Blanket Sales Order GB.
        VerifyDataOnReport(DocumentNoCaption, No);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreatePostedPurchaseCreditMemo(): Code[20]
    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCrMemoHeader."No." := LibraryUTUtility.GetNewCode();
        PurchCrMemoHeader.Insert();
        PurchCrMemoLine."Document No." := PurchCrMemoHeader."No.";
        PurchCrMemoLine.Type := PurchCrMemoLine.Type::Item;
        PurchCrMemoLine."No." := LibraryUTUtility.GetNewCode();
        PurchCrMemoLine.Insert();
        LibraryVariableStorage.Enqueue(PurchCrMemoHeader."No.");  // Enqueue required for PurchaseCreditMemoGBMemoRequestPageHandler.
        exit(PurchCrMemoHeader."No.");
    end;

    local procedure CreatePostedPurchaseInvoice(): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvHeader."No." := LibraryUTUtility.GetNewCode();
        PurchInvHeader.Insert();
        PurchInvLine."Document No." := PurchInvHeader."No.";
        PurchInvLine.Type := PurchInvLine.Type::Item;
        PurchInvLine."No." := LibraryUTUtility.GetNewCode();
        PurchInvLine.Insert();
        LibraryVariableStorage.Enqueue(PurchInvHeader."No.");  // Enqueue required for PurchaseInvoiceGBRequestPageHandler.
        exit(PurchInvHeader."No.");
    end;

    local procedure CreatePurchaseDocument(DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader."Document Type" := DocumentType;
        PurchaseHeader."No." := LibraryUTUtility.GetNewCode();
        PurchaseHeader.Insert();
        PurchaseLine."Document Type" := DocumentType;
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := LibraryUTUtility.GetNewCode();
        PurchaseLine.Insert();

        // Enqueue for BlanketPurchaseOrderGBRequestPageHandler or OrderGBRequestPageHandler.
        LibraryVariableStorage.Enqueue(PurchaseHeader."No.");
        exit(PurchaseLine."Document No.");
    end;

    local procedure CreateSalesDocument(DocumentType: Enum "Sales Document Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."No." := LibraryUTUtility.GetNewCode();
        SalesHeader.Insert();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := LibraryUTUtility.GetNewCode();
        SalesLine.Insert();

        // Enqueue required for BlanketSalesOrderGBRequestPageHandler,OrderConfirmationGBTestRequestPageHandler.
        LibraryVariableStorage.Enqueue(SalesHeader."No.");
        exit(SalesLine."Document No.");
    end;

    local procedure VerifyDataOnReport(ElementName: Text; ExpectedValue: Variant)
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(ElementName, ExpectedValue);
    end;

    [RequestPageHandler]
    procedure BlanketPurchaseOrderGBRequestPageHandler(var PurchaseBlanketOrderGB: TestRequestPage "Blanket Purch. Order GB")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        PurchaseBlanketOrderGB."Purchase Header".SetFilter("No.", No);
        PurchaseBlanketOrderGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure BlanketSalesOrderGBRequestPageHandler(var BlanketSalesOrderGB: TestRequestPage "Blanket Order Sales GB")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        BlanketSalesOrderGB."Sales Header".SetFilter("No.", No);
        BlanketSalesOrderGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure OrderConfirmationGBRequestPageHandler(var OrderConfirmationGB: TestRequestPage "Order Confirmation")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        OrderConfirmationGB."Sales Header".SetFilter("No.", No);
        OrderConfirmationGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure OrderGBRequestPageHandler(var OrderGB: TestRequestPage OrderGB)
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        OrderGB."Purchase Header".SetFilter("No.", No);
        OrderGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure PurchaseCreditMemoGBMemoRequestPageHandler(var PurchaseCreditMemoGB: TestRequestPage "Purchase Credit Memo")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        PurchaseCreditMemoGB."Purch. Cr. Memo Hdr.".SetFilter("No.", No);
        PurchaseCreditMemoGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure PurchaseInvoiceGBRequestPageHandler(var PurchaseInvoiceGB: TestRequestPage "Purchase Invoice")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        PurchaseInvoiceGB."Purch. Inv. Header".SetFilter("No.", No);
        PurchaseInvoiceGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

