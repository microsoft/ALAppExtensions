namespace Microsoft.Finance.ExcelReports.Test;
using Microsoft.FixedAssets.Posting;
using Microsoft.Finance.ExcelReports;

codeunit 139545 "Fixed Asset Excel Reports"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
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

    local procedure CleanupFixedAssetData()
    var
        FAPostingType: Record "FA Posting Type";
    begin
        FAPostingType.DeleteAll();
    end;

    [RequestPageHandler]
    procedure EXRFixedAssetAnalysisExcelHandler(var EXRFixedAssetAnalysisExcel: TestRequestPage "EXR Fixed Asset Analysis Excel")
    begin
        EXRFixedAssetAnalysisExcel.OK().Invoke();
    end;

}