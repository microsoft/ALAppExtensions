codeunit 144015 "UT REP Purchase & Sales"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        CurrentSaveValuesId: Integer;

    [Test]
    [HandlerFunctions('PurchaseCreditMemoGBRequestPageHandler')]
    procedure OnAfterGetRecordPurchaseCreditMemoGB()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of Report 10578 Purchase - Credit Memo GB.

        // Setup: Create Posted Purchase Credit Memo.
        Initialize();
        CreatePostedPurchaseCreditMemoMultipleLine(PurchCrMemoLine);
        Commit();  // Commit required as it is called explicitly from OnRun Trigger of Codeunit 320 PurchCrMemo-Printed.

        // Exercise.
        REPORT.Run(REPORT::"Purchase Credit Memo");  // Open PurchaseCreditMemoGBRequestPageHandler.

        // Verify: Verify Number and Description on Report Purchase - Credit Memo GB.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('No_PurchCrMemoLine', PurchCrMemoLine."No.");
        LibraryReportDataset.AssertElementWithValueExists('Desc_PurchCrMemoLine', PurchCrMemoLine.Description);
    end;

    [Test]
    [HandlerFunctions('PurchaseInvoiceGBRequestPageHandler')]
    procedure OnAfterGetRecordPurchaseInvoiceGB()
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of Report 10577 Purchase - Invoice GB.

        // Setup: Create Posted Purchase Invoice.
        Initialize();
        CreatePostedPurchaseInvoiceWithMultipleLine(PurchInvLine);
        Commit();  // Commit required as it is called explicitly from OnRun Trigger of Codeunit 319 Purch. Inv.-Printed.

        // Exercise.
        REPORT.Run(REPORT::"Purchase Invoice");  // Open PurchaseInvoiceGBRequestPageHandler.

        // Verify: Verify Number and Description on Report Purchase - Invoice GB.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('No_PurchInvLine', PurchInvLine."No.");
        LibraryReportDataset.AssertElementWithValueExists('Description_PurchInvLine', PurchInvLine.Description);
    end;

    local procedure Initialize()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyUpdateStatus: Record "Feature Data Update Status";
    begin
        LibraryVariableStorage.Clear();
        DeleteObjectOptionsIfNeeded();

        if FeatureKey.Get('ReminderTermsCommunicationTexts') then begin
            FeatureKey.Enabled := FeatureKey.Enabled::None;
            FeatureKey.Modify();
        end;
        if FeatureKeyUpdateStatus.Get('ReminderTermsCommunicationTexts', CompanyName()) then begin
            FeatureKeyUpdateStatus."Feature Status" := FeatureKeyUpdateStatus."Feature Status"::Disabled;
            FeatureKeyUpdateStatus.Modify();
        end;
    end;

    local procedure CreatePostedPurchaseInvoiceWithMultipleLine(var PurchInvLine: Record "Purch. Inv. Line")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader."No." := LibraryUTUtility.GetNewCode();
        PurchInvHeader.Insert();
        CreatePostedPurchaseInvoiceLine(PurchInvLine, PurchInvLine.Type::Item, PurchInvHeader."No.", LibraryUTUtility.GetNewCode());
        CreatePostedPurchaseInvoiceLine(PurchInvLine, PurchInvLine.Type::Item, PurchInvHeader."No.", '');  // Blank value for Number.
        LibraryVariableStorage.Enqueue(PurchInvHeader."No.");  // Enqueue required for PurchaseCreditMemoGBRequestPageHandler.
    end;

    local procedure CreatePostedPurchaseInvoiceLine(var PurchInvLine: Record "Purch. Inv. Line"; Type: Enum "Purchase Line Type"; DocumentNo: Code[20]; No: Code[20])
    begin
        PurchInvLine."Line No." := SelectPurchaseInvoiceLineNo(DocumentNo);
        PurchInvLine."Document No." := DocumentNo;
        PurchInvLine.Type := Type;
        PurchInvLine."No." := No;
        PurchInvLine.Description := LibraryUTUtility.GetNewCode();
        PurchInvLine.Insert();
    end;

    local procedure SelectPurchaseInvoiceLineNo(DocumentNo: Code[20]): Integer
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", DocumentNo);
        if PurchInvLine.FindLast() then
            exit(PurchInvLine."Line No." + 1);
        exit(1);
    end;

    local procedure CreatePostedPurchaseCreditMemoMultipleLine(var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHeader."No." := LibraryUTUtility.GetNewCode();
        PurchCrMemoHeader.Insert();
        CreatePostedPurchaseCreditMemoLine(
          PurchCrMemoLine, PurchCrMemoLine.Type::Item, PurchCrMemoHeader."No.", LibraryUTUtility.GetNewCode());
        CreatePostedPurchaseCreditMemoLine(PurchCrMemoLine, PurchCrMemoLine.Type::Item, PurchCrMemoHeader."No.", '');  // Blank value for - Number.
        LibraryVariableStorage.Enqueue(PurchCrMemoHeader."No.");  // Enqueue required for PurchaseCreditMemoGBRequestPageHandler.
    end;

    local procedure CreatePostedPurchaseCreditMemoLine(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; Type: Enum "Purchase Line Type"; DocumentNo: Code[20]; No: Code[20])
    begin
        PurchCrMemoLine."Line No." := SelectPurchaseCreditMemoLineNo(DocumentNo);
        PurchCrMemoLine."Document No." := DocumentNo;
        PurchCrMemoLine.Type := Type;
        PurchCrMemoLine."No." := No;
        PurchCrMemoLine.Description := LibraryUTUtility.GetNewCode();
        PurchCrMemoLine.Insert();
    end;

    local procedure SelectPurchaseCreditMemoLineNo(DocumentNo: Code[20]): Integer
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        if PurchCrMemoLine.FindLast() then
            exit(PurchCrMemoLine."Line No." + 1);
        exit(1);
    end;

    [RequestPageHandler]
    procedure PurchaseCreditMemoGBRequestPageHandler(var PurchaseCreditMemoGB: TestRequestPage "Purchase Credit Memo")
    var
        No: Variant;
    begin
        CurrentSaveValuesId := REPORT::"Purchase Credit Memo";
        LibraryVariableStorage.Dequeue(No);
        PurchaseCreditMemoGB."Purch. Cr. Memo Hdr.".SetFilter("No.", No);
        PurchaseCreditMemoGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure PurchaseInvoiceGBRequestPageHandler(var PurchaseInvoiceGB: TestRequestPage "Purchase Invoice")
    var
        No: Variant;
    begin
        CurrentSaveValuesId := REPORT::"Purchase Invoice";
        LibraryVariableStorage.Dequeue(No);
        PurchaseInvoiceGB."Purch. Inv. Header".SetFilter("No.", No);
        PurchaseInvoiceGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    local procedure DeleteObjectOptionsIfNeeded()
    var
        LibraryReportValidation: Codeunit "Library - Report Validation";
    begin
        LibraryReportValidation.DeleteObjectOptions(CurrentSaveValuesId);
    end;
}

