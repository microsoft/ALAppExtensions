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

    local procedure VerifyDataOnReport(ElementName: Text; ExpectedValue: Variant)
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(ElementName, ExpectedValue);
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

