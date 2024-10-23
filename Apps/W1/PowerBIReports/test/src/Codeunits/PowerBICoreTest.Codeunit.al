#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using Microsoft.PowerBIReports;
using Microsoft.Sales.PowerBIReports;
using Microsoft.Purchases.PowerBIReports;
using Microsoft.Manufacturing.PowerBIReports;
using Microsoft.Finance.PowerBIReports;
using System.TestLibraries.Security.AccessControl;

codeunit 139875 "PowerBI Core Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Item Sales Start Date" := Today();
        PBISetup."Item Sales End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Item Sales Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Item Sales Date Formula"));

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Item Purch. Start Date" := Today();
        PBISetup."Item Purch. End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Item Purch. Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Item Purch. Date Formula"));

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Manufacturing Start Date" := Today();
        PBISetup."Manufacturing End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Manufacturing Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Manufacturing Date Formula"));

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Manufacturing Start Date" := Today();
        PBISetup."Manufacturing End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Format(CreateDateTime(Today(), 0T)), Format(CreateDateTime(Today() + 10, 0T)));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Manufacturing Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', Format(CreateDateTime(CalcDate(PBISetup."Manufacturing Date Formula"), 0T)));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateFinanceReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Finance Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateFinanceReportDateFilter
        // [GIVEN] Power BI setup record is created
        AssignAdminPermissionSet();
        RecreatePBISetup();

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Finance Start Date" := Today();
        PBISetup."Finance End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateFinanceReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateFinanceReportDateFilter_Blank()
    var
        PBIMgt: Codeunit "Finance Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateFinanceReportDateFilter
        // [GIVEN] Power BI setup record is created with blank start & end dates
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateFinanceReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    local procedure RecreatePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then
            PBISetup.Delete();
        PBISetup.Init();
        PBISetup.Insert();
    end;

    procedure AssignAdminPermissionSet()
    begin
        PermissionsMock.Assign('PowerBI Report Admin');
    end;
}

#pragma warning restore AA0247
#pragma warning restore AA0137
#pragma warning restore AA0217
#pragma warning restore AA0205
#pragma warning restore AA0210