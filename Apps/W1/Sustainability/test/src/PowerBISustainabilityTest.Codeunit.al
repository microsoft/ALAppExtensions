namespace Microsoft.Finance.PowerBIReports.Test;

using Microsoft.PowerBIReports;
using Microsoft.HumanResources.Payables;
using Microsoft.PowerBIReports.Test;
using Microsoft.Sustainability.PowerBIReports;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Inventory.Location;
using System.TestLibraries.Security.AccessControl;
using System.Text;
using System.Security.User;

codeunit 148215 "PowerBI Sustainability Test"
{
    Subtype = Test;
    Access = Internal;
    Permissions = tabledata "Employee Ledger Entry" = RIMD, tabledata "Detailed Employee Ledger Entry" = RIMD;

    var

        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        PowerBIAPIRequests: Codeunit "PowerBI API Requests";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBIMockPermissions: Codeunit "Power BI Mock Permissions";
        PBISustainFilterHelper: Codeunit "PBI Sustain. Filter Helper";
        ResponseEmptyErr: Label 'Response should not be empty.';
        FieldHiddenMsg: Label '''%1'' field should be hidden.', Comment = '%1 - field caption';
        FieldShownMsg: Label '''%1'' field should be shown.', Comment = '%1 - field caption';

    [Test]
    procedure TestSustainLedgerEntry()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Insert a Sustainability Ledger Entry
        SustainabilityLedgerEntry.Init();
        SustainabilityLedgerEntry."Account No." := LibUtility.GenerateGUID();
        Clear(SustainabilityLedgerEntry."Entry No.");
        SustainabilityLedgerEntry."Posting Date" := WorkDate();
        SustainabilityLedgerEntry."Document Type" := SustainabilityLedgerEntry."Document Type"::Invoice;
        SustainabilityLedgerEntry."Emission CO2" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Emission N2O" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Emission CH4" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Carbon Fee" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Water Intensity" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Discharged Into Water" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Waste Intensity" := LibRandom.RandDec(100, 2);
        SustainabilityLedgerEntry."Dimension Set ID" := LibRandom.RandIntInRange(3, 5);
        SustainabilityLedgerEntry."Responsibility Center" := 'RC1';
        SustainabilityLedgerEntry."Country/Region Code" := 'AU';
        SustainabilityLedgerEntry.Description := 'This is a API Test';
        SustainabilityLedgerEntry."Water Type" := SustainabilityLedgerEntry."Water Type"::"Ground water";
        SustainabilityLedgerEntry."Water/Waste Intensity Type" := SustainabilityLedgerEntry."Water/Waste Intensity Type"::Recycled;
        SustainabilityLedgerEntry.Insert();

        Commit();

        // [WHEN] Get request for sales value entry is made
        TargetURL := PowerBIAPIRequests.GetEndpointURLForAPIObject(ObjectType::Query, Query::"Sust Ledger Entries - PBI API");
        LibGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response contains the sales value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifySustainabilityLedgerEntry(Response, SustainabilityLedgerEntry);
    end;

    procedure VerifySustainabilityLedgerEntry(Response: Text; SustainabilityLedgerEntry: Record "Sustainability Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.entryNo == ' + Format(Format(SustainabilityLedgerEntry."Entry No.") + ')]')), 'Sustainability ledger entry not found.');
        Assert.AreEqual(SustainabilityLedgerEntry."Account No.", JsonMgt.GetValue('sustainAccountNo'), 'Account No did not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Entry No did not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Document type does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Emission CO2" / 1.0, 0, 9), JsonMgt.GetValue('emissionco2'), 'Emission Co2 does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Emission CH4" / 1.0, 0, 9), JsonMgt.GetValue('emissionch4'), 'Emission CH4 does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Emission N2O" / 1.0, 0, 9), JsonMgt.GetValue('emissionN2O'), 'Emission N2O does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."CO2e Emission" / 1.0, 0, 9), JsonMgt.GetValue('emissionCo2e'), 'Emission Co2e does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Carbon Fee" / 1.0, 0, 9), JsonMgt.GetValue('carbonFee'), 'Carbon Fee does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Water Intensity" / 1.0, 0, 9), JsonMgt.GetValue('waterIntensity'), 'Water Intensity does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Discharged Into Water" / 1.0, 0, 9), JsonMgt.GetValue('dischargedIntoWater'), 'Discharged Into Water does not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Waste Intensity" / 1.0, 0, 9), JsonMgt.GetValue('wasteIntensity'), 'Waste Intensity does not match.');
        Assert.AreEqual(SustainabilityLedgerEntry."Responsibility Center", JsonMgt.GetValue('responsibilityCenter'), 'Responsibility Centre did not match.');
        Assert.AreEqual(SustainabilityLedgerEntry."Country/Region Code", JsonMgt.GetValue('countryRegionCode'), 'Country Region Code did not match.');
        Assert.AreEqual(SustainabilityLedgerEntry."Description", JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Water Type"), JsonMgt.GetValue('waterType'), 'Water Type did not match.');
        Assert.AreEqual(Format(SustainabilityLedgerEntry."Water/Waste Intensity Type"), JsonMgt.GetValue('waterWasteIntensityType'), 'Water Waste Intensity Type did not match.');
    end;

    [Test]
    procedure TestEmployeeLedgerEntry()
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        DetailEmployLedgEntry: Record "Detailed Employee Ledger Entry";
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Insert a Sustainability Ledger Entry
        EmployeeLedgerEntry.Init();
        DetailEmployLedgEntry.Init();
        EmployeeLedgerEntry."Employee No." := LibUtility.GenerateGUID();
        EmployeeLedgerEntry."Entry No." := LibRandom.RandIntInRange(3, 5);
        EmployeeLedgerEntry."Posting Date" := WorkDate();
        EmployeeLedgerEntry."Document Type" := EmployeeLedgerEntry."Document Type"::Payment;
        EmployeeLedgerEntry."Document No." := LibUtility.GenerateGUID();
        EmployeeLedgerEntry."Dimension Set ID" := LibRandom.RandIntInRange(3, 5);
        EmployeeLedgerEntry.Description := 'This is an API Test';
        DetailEmployLedgEntry."Employee No." := EmployeeLedgerEntry."Employee No.";
        DetailEmployLedgEntry."Entry No." := LibRandom.RandIntInRange(3, 5);
        DetailEmployLedgEntry."Employee Ledger Entry No." := EmployeeLedgerEntry."Entry No.";
        DetailEmployLedgEntry."Posting Date" := WorkDate();
        DetailEmployLedgEntry."Document Type" := EmployeeLedgerEntry."Document Type"::Payment;
        DetailEmployLedgEntry."Document No." := EmployeeLedgerEntry."Document No.";
        DetailEmployLedgEntry.Amount := LibRandom.RandDec(100, 2);
        EmployeeLedgerEntry.Insert();
        DetailEmployLedgEntry.Insert();
        Commit();

        // [WHEN] Get request for sales value entry is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrlForAPIObject(ObjectType::Query, Query::"EmployeeLedgerEntry - PBI API");
        LibGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response contains the sales value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyEmployeeLedgerEntry(Response, EmployeeLedgerEntry);
    end;

    procedure VerifyEmployeeLedgerEntry(Response: Text; EmployeeLedgerEntry: Record "Employee Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.entryNo == ' + Format(Format(EmployeeLedgerEntry."Entry No.") + ')]')), 'Employee ledger entry not found.');
        Assert.AreEqual(EmployeeLedgerEntry."Employee No.", JsonMgt.GetValue('employeeNo'), 'Employee No did not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Entry No did not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Document type does not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry."Document No."), JsonMgt.GetValue('documentNo'), 'Document No does not match.');
        Assert.AreEqual(EmployeeLedgerEntry."Description", JsonMgt.GetValue('description'), 'Description No did not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension Set ID did not match.');
        Assert.AreEqual(Format(EmployeeLedgerEntry.Amount / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Amount does not match.');
    end;

    [Test]
    procedure TestSustainabilityGoal()
    var
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        UserSetup: Record "User Setup";
        RespCenter: Record "Responsibility Center";
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Insert a Sustainability Goal

        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, 50);
            UserSetup."Sustainability Manager" := true;
            UserSetup.Insert();
        end else begin
            UserSetup."Sustainability Manager" := true;
            UserSetup.Modify();
        end;

        if not RespCenter.FindFirst() then begin
            RespCenter.Init();
            RespCenter.Code := CopyStr(LibRandom.RandText(10), 1, 10);
            RespCenter.Insert();
        end;


        SustainabilityScorecard.Init();
        SustainabilityScorecard."No." := CopyStr(LibRandom.RandText(20), 1, 20);
        SustainabilityScorecard.Name := CopyStr(LibRandom.RandText(100), 1, 100);
        SustainabilityScorecard.Insert();

        SustainabilityGoal.Init();
        SustainabilityGoal."No." := CopyStr(LibRandom.RandText(20), 1, 20);
        SustainabilityGoal."Scorecard No." := SustainabilityScorecard."No.";
        SustainabilityGoal."Line No." := LibRandom.RandInt(10);
        SustainabilityGoal.Name := CopyStr(LibRandom.RandText(100), 1, 100);
        SustainabilityGoal.Owner := UserSetup."User ID";
        SustainabilityGoal."Country/Region Code" := 'US';
        SustainabilityGoal."Responsibility Center" := RespCenter.Code;
        SustainabilityGoal."Start Date" := WorkDate();
        SustainabilityGoal."End Date" := WorkDate() + 30;
        SustainabilityGoal."Target Value for CO2" := LibRandom.RandDec(50, 2);
        SustainabilityGoal."Target Value for CH4" := LibRandom.RandDec(50, 2);
        SustainabilityGoal."Target Value for N2O" := LibRandom.RandDec(50, 2);
        SustainabilityGoal."Target Value for Waste Int." := LibRandom.RandDec(50, 2);
        SustainabilityGoal."Target Value for Water Int." := LibRandom.RandDec(50, 2);
        SustainabilityGoal."Main Goal" := true;
        SustainabilityGoal."Baseline Start Date" := WorkDate();
        SustainabilityGoal."Baseline End Date" := WorkDate() + 30;
        SustainabilityGoal.Insert();
        Commit();

        // [WHEN] Get request for Sustainability Goal is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrlForAPIObject(ObjectType::Query, Query::"Sustainability Goals - PBI API");
        LibGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response contains the sustainability goal information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifySustainabilityGoal(Response, SustainabilityGoal);
    end;

#if not CLEAN27
#pragma warning disable AL0801
#endif
    [Test]
    procedure TestGenerateSustainabilityReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateSustainabilityReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        PowerBIMockPermissions.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Sustainability Load Date Type" := PBISetup."Sustainability Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Sustainability Start Date" := Today();
        PBISetup."Sustainability End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBISustainFilterHelper.GenerateSustainabilityReportDateFilter();

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Sustainability Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Sustainability End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Sustainability Date Formula".Visible();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Start Date & End Date fields should be shown.
        Assert.IsTrue(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability Start Date".Caption()));
        Assert.IsTrue(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Sustainability Date Formula".Caption()));
    end;

    [Test]
    procedure TestGenerateSustainabilityReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateSustainabilityReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        PowerBIMockPermissions.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Sustainability Load Date Type" := PBISetup."Sustainability Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Sustainability Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Sustainability Date Formula")) + '..';

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBISustainFilterHelper.GenerateSustainabilityReportDateFilter();

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Sustainability Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Sustainability End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Sustainability Date Formula".Visible();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] The Date Formula field should be shown.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Sustainability Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldHiddenMsg, PowerBIReportsSetup."Sustainability End Date".Caption()));
        Assert.IsTrue(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability Date Formula".Caption()));
    end;

    [Test]
    procedure TestGenerateSustainabilityReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PowerBIReportsSetup: TestPage "PowerBI Reports Setup";
        ActualFilterTxt: Text;
        IsStartDateVisible: Boolean;
        IsEndDateVisible: Boolean;
        IsDateFormulaVisible: Boolean;
    begin
        // [SCENARIO] Test GenerateSustainabilityReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        PowerBIMockPermissions.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Sustainability Load Date Type" := PBISetup."Sustainability Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBISustainFilterHelper.GenerateSustainabilityReportDateFilter();

        // [WHEN] The Power BI Reports Setup page opens
        PowerBIReportsSetup.OpenEdit();
        IsStartDateVisible := PowerBIReportsSetup."Sustainability Start Date".Visible();
        IsEndDateVisible := PowerBIReportsSetup."Sustainability End Date".Visible();
        IsDateFormulaVisible := PowerBIReportsSetup."Sustainability Date Formula".Visible();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');

        // [THEN] All date setup fields should be hidden.
        Assert.IsFalse(IsStartDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability Start Date".Caption()));
        Assert.IsFalse(IsEndDateVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability End Date".Caption()));
        Assert.IsFalse(IsDateFormulaVisible, StrSubstNo(FieldShownMsg, PowerBIReportsSetup."Sustainability Date Formula".Caption()));
    end;
#if not CLEAN27
#pragma warning restore AL0801
#endif

    local procedure RecreatePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then
            PBISetup.Delete();
        PBISetup.Init();
        PBISetup.Insert();
    end;

    procedure VerifySustainabilityGoal(Response: Text; SustainabilityGoal: Record "Sustainability Goal")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.no == ''' + SustainabilityGoal."No." + ''')]'), 'Sustainability goal not found.');
        Assert.AreEqual(SustainabilityGoal."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(SustainabilityGoal."Scorecard No.", JsonMgt.GetValue('scoreCardNo'), 'Scorecard No. did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Line No.", 0, 9), JsonMgt.GetValue('lineNo'), 'Line No. did not match.');
        Assert.AreEqual(SustainabilityGoal.Name, JsonMgt.GetValue('name'), 'Name did not match.');
        Assert.AreEqual(SustainabilityGoal.Owner, JsonMgt.GetValue('owner'), 'Owner did not match.');
        Assert.AreEqual(SustainabilityGoal."Country/Region Code", JsonMgt.GetValue('countryRegion'), '"Country/Region Code did not match.');
        Assert.AreEqual(SustainabilityGoal."Responsibility Center", JsonMgt.GetValue('responsibilityCentre'), 'Responsibility Center did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Target Value for CO2" / 1.0, 0, 9), JsonMgt.GetValue('targetValueForCo2'), 'Target Value for CO2 did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Target Value for CH4" / 1.0, 0, 9), JsonMgt.GetValue('targetValueForCh4'), 'Target Value for CH4 did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Target Value for N2O" / 1.0, 0, 9), JsonMgt.GetValue('targetValueForN2O'), 'Target Value for N2O did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Target Value for Water Int." / 1.0, 0, 9), JsonMgt.GetValue('targetValueForWaterIntensity'), 'Target Value For Water Intensity did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Target Value for Waste Int." / 1.0, 0, 9), JsonMgt.GetValue('targetValueForWasteIntensity'), 'Target Value For Waste Intensity did not match.');
        Assert.AreEqual(SustainabilityGoal."Main Goal" ? 'True' : 'False', JsonMgt.GetValue('mainGoal'), 'Main Goal did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Start Date", 0, 9), JsonMgt.GetValue('startDate'), 'Start Date did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."End Date", 0, 9), JsonMgt.GetValue('endDate'), 'End Date did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Baseline Start Date", 0, 9), JsonMgt.GetValue('baselineStartDate'), 'Baseline Start Date did not match.');
        Assert.AreEqual(Format(SustainabilityGoal."Baseline End Date", 0, 9), JsonMgt.GetValue('baselineEndDate'), 'Baseline End Date did not match.');
    end;
}
