codeunit 144016 "UT REP UKGEN"
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
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        IsInitialized: Boolean;
        DimensionFilterCap: Label '%1 %2';
        DimensionTextCap: Label 'DimText';

    [Test]
    [HandlerFunctions('PurchaseCreditMemoGBRequestPageHandler')]
    procedure OnAfterGetRecordDimLoopPurchaseCreditMemoGB()
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // [SCENARIO] validate the DimensionLoop1 - OnAfterGetRecord trigger of Report ID: 10578, Purchase - Credit Memo GB.
        Initialize();

        // [GIVEN] Setup.
        CreatePostedPurchaseCreditMemoWithDimension(DimensionSetEntry);

        // [WHEN] Run and verify the Dimension Text after running Report, Purchase - Credit Memo GB.
        RunReportAndVerifyDimension(
          REPORT::"Purchase Credit Memo", DimensionTextCap,
          StrSubstNo(DimensionFilterCap, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code"));
    end;

    [Test]
    [HandlerFunctions('SalesCreditMemoGBRequestPageHandler')]
    procedure OnAfterGetRecordDimLoopSalesCreditMemoGB()
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // [SCENARIO] validate the DimensionLoop1 - OnAfterGetRecord trigger of Report ID: 10573, Sales - Credit Memo GB.
        Initialize();

        // [GIVEN] Setup.
        CreatePostedSalesCreditMemoWithDimension(DimensionSetEntry);

        // [WHEN] Run and verify the Dimension Text after running Report, Sales - Credit Memo GB.
        RunReportAndVerifyDimension(
          REPORT::"Sales - Credit Memo", DimensionTextCap,
          StrSubstNo(DimensionFilterCap, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code"));
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceGBRequestPageHandler')]
    procedure OnAfterGetRecordDimLoopSalesInvoiceGB()
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // [SCENARIO] validate the DimensionLoop1 - OnAfterGetRecord trigger of Report ID: 10572, Sales - Invoice GB.
        Initialize();

        // [GIVEN] Setup.
        CreatePostedSalesInvoiceWithDimension(DimensionSetEntry);

        // [WHEN] Run and verify the Dimension Text after running Report, Sales - Invoice GB.
        RunReportAndVerifyDimension(
          REPORT::"Sales - Invoice", DimensionTextCap,
          StrSubstNo(DimensionFilterCap, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code"));
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
        LibrarySetupStorage.Save(DATABASE::"General Ledger Setup");
        LibrarySetupStorage.Save(DATABASE::"Company Information");
        LibrarySetupStorage.Save(DATABASE::"Sales & Receivables Setup");
        LibrarySetupStorage.Save(DATABASE::"Purchases & Payables Setup");
    end;

    local procedure CreatePostedSalesInvoiceWithDimension(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        CreateDimensionSetEntry(DimensionSetEntry);
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        SalesInvoiceHeader."No." := LibraryUTUtility.GetNewCode();
        SalesInvoiceHeader."Bill-to Customer No." := Customer."No.";
        SalesInvoiceHeader."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
        SalesInvoiceHeader.Insert();
        SalesInvoiceLine."Document No." := SalesInvoiceHeader."No.";
        SalesInvoiceLine."No." := LibraryUTUtility.GetNewCode();
        SalesInvoiceLine.Insert();
        LibraryVariableStorage.Enqueue(SalesInvoiceHeader."No.");  // Enqueue value for use in SalesInvoiceGBRequestPageHandler.
    end;

    local procedure CreatePostedSalesCreditMemoWithDimension(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        CreateDimensionSetEntry(DimensionSetEntry);
        SalesCrMemoHeader."No." := LibraryUTUtility.GetNewCode();
        SalesCrMemoHeader."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
        SalesCrMemoHeader.Insert();
        SalesCrMemoLine."Document No." := SalesCrMemoHeader."No.";
        SalesCrMemoLine."No." := LibraryUTUtility.GetNewCode();
        SalesCrMemoLine.Insert();
        LibraryVariableStorage.Enqueue(SalesCrMemoHeader."No.");  // Enqueue value for use in SalesCreditMemoGBRequestPageHandler.
    end;

    local procedure CreateDimensionSetEntry(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        DimensionValue: Record "Dimension Value";
        DimensionSetEntry2: Record "Dimension Set Entry";
    begin
        DimensionValue."Dimension Code" := LibraryUTUtility.GetNewCode();
        DimensionValue.Code := LibraryUTUtility.GetNewCode();
        DimensionValue.Insert();

        DimensionSetEntry2.FindLast();
        DimensionSetEntry."Dimension Set ID" := DimensionSetEntry2."Dimension Set ID" + 1;
        DimensionSetEntry."Dimension Code" := DimensionValue."Dimension Code";
        DimensionSetEntry."Dimension Value Code" := DimensionValue.Code;
        DimensionSetEntry.Insert();
    end;

    local procedure CreatePostedPurchaseCreditMemoWithDimension(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        CreateDimensionSetEntry(DimensionSetEntry);
        PurchCrMemoHdr."No." := LibraryUTUtility.GetNewCode();
        PurchCrMemoHdr."Dimension Set ID" := DimensionSetEntry."Dimension Set ID";
        PurchCrMemoHdr.Insert();
        PurchCrMemoLine."Document No." := PurchCrMemoHdr."No.";
        PurchCrMemoLine."No." := LibraryUTUtility.GetNewCode();
        PurchCrMemoLine.Insert();
        LibraryVariableStorage.Enqueue(PurchCrMemoHdr."No.");  // Enqueue value for use in PurchaseCreditMemoGBRequestPageHandler.
    end;

    local procedure RunReportAndVerifyDimension(ReportID: Integer; ElementName: Text; ExpectedValue: Variant)
    begin
        // Exercise.
        Commit();  // Used explicit commit.
        REPORT.Run(ReportID);

        // Verify: Verify the Dimension Text after running Report.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(ElementName, ExpectedValue);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesInvoiceGBRequestPageHandler(var SalesInvoiceGB: TestRequestPage "Sales - Invoice")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SalesInvoiceGB."Sales Invoice Header".SetFilter("No.", No);
        SalesInvoiceGB.ShowInternalInformation.SetValue(true);
        SalesInvoiceGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseCreditMemoGBRequestPageHandler(var PurchaseCreditMemoGB: TestRequestPage "Purchase Credit Memo")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        PurchaseCreditMemoGB."Purch. Cr. Memo Hdr.".SetFilter("No.", No);
        PurchaseCreditMemoGB.ShowInternalInformation.SetValue(true);
        PurchaseCreditMemoGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesCreditMemoGBRequestPageHandler(var SalesCreditMemoGB: TestRequestPage "Sales - Credit Memo")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SalesCreditMemoGB."Sales Cr.Memo Header".SetFilter("No.", No);
        SalesCreditMemoGB.ShowInternalInformation.SetValue(true);
        SalesCreditMemoGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

