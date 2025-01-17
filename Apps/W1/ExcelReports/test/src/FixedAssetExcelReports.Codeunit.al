namespace Microsoft.Finance.ExcelReports.Test;
using Microsoft.FixedAssets.Posting;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using System.TestLibraries.Utilities;
using Microsoft.Finance.ExcelReports;

codeunit 139545 "Fixed Asset Excel Reports"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('EXRFixedAssetAnalysisExcelHandler')]
    procedure FirstTimeOpeningRequestPageOfFixedAssetAnalysisShouldInsertPostingTypes()
    var
        RequestPageXml: Text;
    begin
        // [SCENARIO 544231] First time opening the Fixed Asset Analysis Excel report requestpage should insert the FixedAssetTypes required by the report
        // [GIVEN] There is no FA Posting Type
        CleanupFixedAssetData();
        Commit();
        Assert.TableIsEmpty(Database::"FA Posting Type");
        // [WHEN] Opening the requestpage of the Fixed Asset Analysis report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Fixed Asset Analysis Excel", RequestPageXml);
        // [THEN] The default FA Posting Type's are inserted
        Assert.TableIsNotEmpty(Database::"FA Posting Type");
    end;

    [Test]
    [HandlerFunctions('EXRFixedAssetAnalysisExcelHandler')]
    procedure FixedAssetAnalysisShouldntExportFixedAssetWithoutEntries()
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        Variant: Variant;
        VariantText: Text;
        ReportAcquisitionDate: Date;
        RequestPageXml: Text;
    begin
        // [SCENARIO 546182] Fixed Asset Analysis report should report the correct acquisition date and not export fixed assets if they have no entries.
        CleanupFixedAssetData();
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        // [GIVEN] An acquired fixed asset
        FixedAsset."No." := 'FA01';
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code);
        FADepreciationBook."Acquisition Date" := WorkDate();
        FADepreciationBook.Modify();
        // [GIVEN] An unacquired fixed asset (no entries)
        FixedAsset."No." := 'FA02';
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        Commit();
        // [WHEN] Running the fixed asset analysis excel report
        LibraryVariableStorage.Enqueue(DepreciationBook.Code);
        RequestPageXml := Report.RunRequestPage(Report::"EXR Fixed Asset Analysis Excel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(report::"EXR Fixed Asset Analysis Excel", Variant, RequestPageXml);
        // [THEN] The dataset contains both fixed assets
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="FixedAssetData"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'Just the acquired fixed asset should be exported on the report');
        // [THEN] Only the first fixed asset has defined AcquisitionDate
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('AcquisitionDateField', Variant);
        VariantText := Variant;
        Evaluate(ReportAcquisitionDate, VariantText);
        Assert.AreEqual(FADepreciationBook."Acquisition Date", ReportAcquisitionDate, 'Acquisition date of first fixed asset should match the one in the depreciation book');
    end;

    local procedure CleanupFixedAssetData()
    var
        FAPostingType: Record "FA Posting Type";
        FixedAsset: Record "Fixed Asset";
    begin
        FAPostingType.DeleteAll();
        FixedAsset.DeleteAll();
    end;

    [RequestPageHandler]
    procedure EXRFixedAssetAnalysisExcelHandler(var EXRFixedAssetAnalysisExcel: TestRequestPage "EXR Fixed Asset Analysis Excel")
    var
        DepreciationBookCode: Code[10];
    begin
        if LibraryVariableStorage.Length() = 1 then begin
            DepreciationBookCode := CopyStr(LibraryVariableStorage.DequeueText(), 1, 10);
            EXRFixedAssetAnalysisExcel.DepreciationBookCodeField.SetValue(DepreciationBookCode);
        end;
        EXRFixedAssetAnalysisExcel.OK().Invoke();
    end;

}