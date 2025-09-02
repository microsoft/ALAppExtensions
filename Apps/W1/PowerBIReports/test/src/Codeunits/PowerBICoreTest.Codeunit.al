namespace Microsoft.Finance.PowerBIReports.Test;

using Microsoft.PowerBIReports;
using Microsoft.PowerBIReports.Test;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.AuditCodes;
using System.TestLibraries.Security.AccessControl;
using Microsoft.CRM.Contact;
using System.Utilities;
using System.Text;
using Microsoft.Projects.Resources.Resource;


codeunit 139875 "PowerBI Core Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBIAPIRequests: Codeunit "PowerBI API Requests";
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibMarketing: Codeunit "Library - Marketing";
        LibInv: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibERM: Codeunit "Library - ERM";
        LibResource: Codeunit "Library - Resource";
        LibRandom: Codeunit "Library - Random";
        UriBuilder: Codeunit "Uri Builder";
        FilterScenario: Enum "PowerBI Filter Scenarios";
        PowerBIAPIEndpoints: Enum "PowerBI API Endpoints";
        IsInitialized: Boolean;
        ResponseEmptyErr: Label 'Response should not be empty.';
        FieldHiddenMsg: Label '''%1'' field should be hidden.', Comment = '%1 - field caption';
        FieldShownMsg: Label '''%1'' field should be shown.', Comment = '%1 - field caption';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Sales Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Sales Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Sales End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Sales Date Formula".Visible();

        // [THEN] A filter text of format "%1..%2" should be created
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Start Date & End Date fields should be shown.
        Assert.IsTrue(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales Start Date".Caption()));
        Assert.IsTrue(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Sales Date Formula".Caption()));
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Item Sales Date Formula")) + '..';

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Sales Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Sales Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Sales End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Sales Date Formula".Visible();

        // [THEN] A filter text of format "%1.." should be created
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Date Formula field should be shown
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales End Date".Caption()));
        Assert.IsTrue(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales Date Formula".Caption()));
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Sales Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Sales Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Sales End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Sales Date Formula".Visible();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] All date setup fields must be hidden.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Sales Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Purchases Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Purch. Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Purch. End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Purch. Date Formula".Visible();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Start Date & End Date fields should be shown.
        Assert.IsTrue(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Purch. Start Date".Caption()));
        Assert.IsTrue(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Purch. End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Item Purch. Date Formula")) + '..';

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Purchases Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Purch. Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Purch. End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Purch. Date Formula".Visible();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Date Formula field should be shown.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. End Date".Caption()));
        Assert.IsTrue(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Item Purch. Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateItemPurchasesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Purchases Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Item Purch. Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Item Purch. End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Item Purch. Date Formula".Visible();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] All date setup fields should be hidden.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Item Purch. Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Manufacturing Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Manufacturing End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Manufacturing Date Formula".Visible();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Start Date & End Date fields should be shown.
        Assert.IsTrue(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Manufacturing Start Date".Caption()));
        Assert.IsTrue(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Manufacturing End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
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

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Manufacturing Date Formula")) + '..';

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Manufacturing Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Manufacturing End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Manufacturing Date Formula".Visible();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Date Formula field should be shown.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing End Date".Caption()));
        Assert.IsTrue(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Manufacturing Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateManufacturingReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date");

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Manufacturing Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Manufacturing End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Manufacturing Date Formula".Visible();


        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] All date setup fields should be hidden.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Manufacturing Date Formula".Caption()));
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
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

        ExpectedFilterTxt := Format(CreateDateTime(Today(), 0T)) + '..' + Format(CreateDateTime(Today() + 10, 0T));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date Time");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
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

        ExpectedFilterTxt := Format(CreateDateTime(CalcDate(PBISetup."Manufacturing Date Formula"), 0T)) + '..';

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date Time");

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateManufacturingReportDateTimeFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
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
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Manufacturing Date Time");

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateFinanceReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        ExpectedFilterTxt: Text;
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Finance Date");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure GenerateFinanceReportDateFilter_Blank()
    var
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateFinanceReportDateFilter
        // [GIVEN] Power BI setup record is created with blank start & end dates
        AssignAdminPermissionSet();
        RecreatePBISetup();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(FilterScenario::"Finance Date");

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
        PermissionsMock.Assign('D365 BUS FULL ACCESS');
    end;

    [Test]
    procedure TestGetContact()
    var
        Contact: Record Contact;
        Uri: Codeunit Uri;
        Response: Text;
        TargetURL: Text;
    begin
        Initialize();

        // [GIVEN] A company contact with full address details
        LibMarketing.CreateCompanyContact(Contact);
        LibMarketing.UpdateContactAddress(Contact);
        Commit();

        // [WHEN] Get request for Contact
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::Contacts);
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'contactNo eq ''' + Format(Contact."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the contact information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyContact(Response, Contact);
    end;

    local procedure VerifyContact(Response: Text; Contact: Record Contact)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.contactNo == ''' + Format(Contact."No.") + ''')]'), 'Contact not found.');
        Assert.AreEqual(Contact."No.", JsonMgt.GetValue('contactNo'), 'Contact No. does not match.');
        Assert.AreEqual(Format(Contact.Type), JsonMgt.GetValue('contactType'), 'Contact Type does not match.');
        Assert.AreEqual(Contact."Company No.", JsonMgt.GetValue('companyNo'), 'Company No. does not match.');
        Assert.AreEqual(Contact."Company Name", JsonMgt.GetValue('companyName'), 'Company Name does not match.');
        Assert.AreEqual(Contact.Address, JsonMgt.GetValue('address'), 'Address does not match.');
        Assert.AreEqual(Contact."Address 2", JsonMgt.GetValue('address2'), 'Address 2 does not match.');
        Assert.AreEqual(Contact.City, JsonMgt.GetValue('city'), 'City does not match.');
        Assert.AreEqual(Contact."Post Code", JsonMgt.GetValue('postCode'), 'Post Code Type does not match.');
        Assert.AreEqual(Contact.County, JsonMgt.GetValue('county'), 'County does not match.');
        Assert.AreEqual(Contact."Country/Region Code", JsonMgt.GetValue('countryRegionCode'), 'Contry/Region Code does not match.');
    end;

    [Test]
    procedure TestGetItemCategory()
    var
        ItemCategory: Record "Item Category";
        ParentCategory: Record "Item Category";
        Uri: Codeunit Uri;
        Response: Text;
        TargetURL: Text;
    begin
        Initialize();

        // [GIVEN] An Item Category that has a parent category
        LibInv.CreateItemCategory(ParentCategory);
        LibInv.CreateItemCategory(ItemCategory);
        ItemCategory.Validate(Description, LibraryUtility.GenerateRandomText(20));
        ItemCategory.Validate("Parent Category", ParentCategory.Code);
        ItemCategory.Modify(true);
        Commit();

        // [WHEN] Get request for Item Category
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Item Categories");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'code eq ''' + Format(ItemCategory.Code) + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the item category information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyItemCategory(Response, ItemCategory, ParentCategory.Code);
    end;

    local procedure VerifyItemCategory(Response: Text; ItemCategory: Record "Item Category"; ParentCategoryCode: Code[20])
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.code == ''' + Format(ItemCategory.Code) + ''')]'), 'Item Category not found.');
        Assert.AreEqual(ItemCategory.Code, JsonMgt.GetValue('code'), 'Item Category Code does not match.');
        Assert.AreEqual(ItemCategory.Description, JsonMgt.GetValue('description'), 'Description does not match.');
        Assert.AreEqual(ParentCategoryCode, JsonMgt.GetValue('parentCategory'), 'Parent Category does not match.');
        Assert.AreEqual(Format(ItemCategory.SystemId), '{' + JsonMgt.GetValue('systemId').ToUpper() + '}', 'System ID does not match.');
    end;

    [Test]
    procedure TestGetReturnReason()
    var
        ReturnReason: Record "Return Reason";
        Uri: Codeunit Uri;
        Response: Text;
        TargetURL: Text;
    begin
        Initialize();

        // [GIVEN] An return reason code
        LibERM.CreateReturnReasonCode(ReturnReason);
        Commit();

        // [WHEN] Get request for Return Reason
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Return Reason Codes");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'reasonCode eq ''' + Format(ReturnReason.Code) + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the return reason information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyReturnReason(Response, ReturnReason);
    end;

    local procedure VerifyReturnReason(Response: Text; ReturnReason: Record "Return Reason")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.reasonCode == ''' + Format(ReturnReason.Code) + ''')]'), 'Return Reason not found.');
        Assert.AreEqual(ReturnReason.Code, JsonMgt.GetValue('reasonCode'), 'Return Reason Code does not match.');
        Assert.AreEqual(ReturnReason.Description, JsonMgt.GetValue('reasonDescription'), 'Description does not match.');
    end;

    [Test]
    procedure TestGetResource()
    var
        Resource: Record Resource;
        Uri: Codeunit Uri;
        Response: Text;
        TargetURL: Text;
    begin
        Initialize();

        // [GIVEN] A new resource
        LibResource.CreateResourceNew(Resource);
        Resource.Validate("Unit Cost", LibRandom.RandInt(50));
        Resource.Modify();
        Commit();

        // [WHEN] Get request for Resource
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::Resources);
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'resourceNo eq ''' + Format(Resource."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the resource information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyResource(Response, Resource);
    end;

    local procedure VerifyResource(Response: Text; Resource: Record Resource)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.resourceNo == ''' + Format(Resource."No.") + ''')]'), 'Resource not found.');
        Assert.AreEqual(Resource."No.", JsonMgt.GetValue('resourceNo'), 'Resource no. does not match.');
        Assert.AreEqual(Resource.Name, JsonMgt.GetValue('resourceName'), 'Resource name does not match.');
        Assert.AreEqual(Resource."Base Unit of Measure", JsonMgt.GetValue('baseUnitofMeasure'), 'Base unit of measure does not match.');
        Assert.AreEqual(Format(Resource."Unit Cost" / 1.0, 0, 9), JsonMgt.GetValue('unitCost'), 'Unit cost does not match.');
        Assert.AreEqual(Format(Resource."Unit Price" / 1.0, 0, 9), JsonMgt.GetValue('unitPrice'), 'Unit price does not match.');
    end;
}
