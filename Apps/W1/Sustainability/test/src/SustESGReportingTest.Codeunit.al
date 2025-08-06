namespace Microsoft.Test.Sustainability;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Ledger;

codeunit 148206 "Sust. ESG Reporting Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySustainability: Codeunit "Library - Sustainability";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        FilterIsIncorrectErr: Label '%1 is incorrect.', Comment = '%1 = Field Caption';
        DrillDownIsNotPossibleErr: Label 'Drilldown is not possible when %1 is %2.', Comment = '%1 = Field Caption , %2 = Field Value';
        RowNotfoundErr: Label 'The row does not exist on the TestPage.';

    [Test]
    procedure TestESGReportingPreviewForSustainabilityAccount()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 537477] Verify the ESG Reporting Preview Data for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [WHEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [THEN] Verify the ESG Reporting Preview Data.
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[1]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals(ExpectedCO2eEmission * 2);

        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[2]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals(ExpectedCarbonFee * 2);

        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals((ExpectedCO2eEmission * 2) + (ExpectedCarbonFee * 2));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestPostedESGReportingForSustainabilityAccount()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        PostedESGReportSub: TestPage "Sust. Posted ESG Report Sub.";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 537477] Verify the Posted ESG Reporting Data for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Posted ESG Reporting Nos." in Sustainability Setup.
        LibrarySustainability.UpdatePostedESGReportingNoInSustainabilitySetup();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);
        ESGReportingName.Validate(Period, Date2DMY(WorkDate(), 3));
        ESGReportingName.Modify();

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [WHEN] Open Calculate and Post ESG Report.
        ESGReportingAggregation."Calc. and Post ESG Report".Invoke();

        // [THEN] Verify the Posted ESG Reporting Data.
        PostedESGReportSub.OpenView();
        FindPostedESGReportingLine(PostedESGReportingLine, ESGReportingLine[1]."Row No.");
        PostedESGReportSub.GoToRecord(PostedESGReportingLine);
        PostedESGReportSub."Posted Amount".AssertEquals(ExpectedCO2eEmission * 2);

        FindPostedESGReportingLine(PostedESGReportingLine, ESGReportingLine[2]."Row No.");
        PostedESGReportSub.GoToRecord(PostedESGReportingLine);
        PostedESGReportSub."Posted Amount".AssertEquals(ExpectedCarbonFee * 2);

        FindPostedESGReportingLine(PostedESGReportingLine, ESGReportingLine[3]."Row No.");
        PostedESGReportSub.GoToRecord(PostedESGReportingLine);
        PostedESGReportSub."Posted Amount".AssertEquals((ExpectedCO2eEmission * 2) + (ExpectedCarbonFee * 2));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestESGReportingForSustainabilityAccountCannotBePostForSamePeriod()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the ESG Reporting Data for Sustainability Account cannot be posted for same period.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Posted ESG Reporting Nos." in Sustainability Setup.
        LibrarySustainability.UpdatePostedESGReportingNoInSustainabilitySetup();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);
        ESGReportingName.Validate(Period, Date2DMY(WorkDate(), 3));
        ESGReportingName.Modify();

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation and Post ESG Report.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);
        ESGReportingAggregation."Calc. and Post ESG Report".Invoke();

        // [WHEN] Open Calculate and Post ESG Report again.
        asserterror ESGReportingAggregation."Calc. and Post ESG Report".Invoke();

        // [THEN] Verify the ESG Reporting Data cannot be posted for same period.
        Assert.ExpectedTestFieldError(ESGReportingName.FieldCaption(Posted), Format(false));
    end;

    [Test]
    procedure TestDrillDownAndFiltersOfESGReportingPreviewWhenSelectOnColumnValueField()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        SustainabilityLedgerEntries: TestPage "Sustainability Ledger Entries";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the DrillDown and Filters of ESG Reporting Preview When "Column Value" field is selected.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [GIVEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[1]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Account No." and "Posting Date" filters in Sustainability Ledger Entries. 
        Assert.AreEqual(
            AccountCode,
            SustainabilityLedgerEntries.Filter.GetFilter("Account No."),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Account No.".Caption()));
        Assert.AreEqual(
            StrSubstNo('''''..' + Format(DMY2Date(31, 12, 9999))),
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Posting Date".Caption()));
    end;

    [Test]
    procedure TestDrillDownIsNotPossibleForFieldTypeFormulaInESGReportingPreviewWhenSelectOnColumnValueField()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        SustainabilityLedgerEntries: TestPage "Sustainability Ledger Entries";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the DrillDown is not possible in ESG Reporting Preview When "Column Value" field is selected.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [GIVEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);
        asserterror ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify the DrillDown is not possible in ESG Reporting Preview.
        Assert.ExpectedError(StrSubstNo(DrillDownIsNotPossibleErr, ESGReportingLine[3].FieldCaption("Field Type"), ESGReportingLine[3]."Field Type"));
    end;

    [Test]
    procedure TestFiltersOfESGReportingPreviewWhenSelectOnColumnValueFieldWithRowType()
    var
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        SustainabilityLedgerEntries: TestPage "Sustainability Ledger Entries";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the Filters of ESG Reporting Preview When "Column Value" field is selected with different "Row Type".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name with Period.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);
        ESGReportingName.Validate(Period, Date2DMY(WorkDate(), 3));
        ESGReportingName.Validate("Country/Region Code", CountryRegion.Code);
        ESGReportingName.Modify();

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Balance at Date",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Beginning Balance",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[3]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[3]."Row Type"::"Net Change",
            '',
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [GIVEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[1]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Country/Region Code" and "Posting Date" filters in Sustainability Ledger Entries with "Row Type"-"Balance at Date".
        Assert.AreEqual(
            CountryRegion.Code,
            SustainabilityLedgerEntries.Filter.GetFilter("Country/Region Code"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Country/Region Code".Caption()));
        Assert.AreEqual(
            StrSubstNo('''''..' + Format(CalcDate('<CY>', WorkDate()))),
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Posting Date".Caption()));

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[2]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Country/Region Code" and "Posting Date" filters in Sustainability Ledger Entries with "Row Type"-"Beginning Balance".
        Assert.AreEqual(
            CountryRegion.Code,
            SustainabilityLedgerEntries.Filter.GetFilter("Country/Region Code"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Country/Region Code".Caption()));
        Assert.AreEqual(
            StrSubstNo(Format('..C') + Format(CalcDate('<-CY>', WorkDate()) - 1)),
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Posting Date".Caption()));

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Country/Region Code" and "Posting Date" filters in Sustainability Ledger Entries with "Row Type"-"Net Change".
        Assert.AreEqual(
            CountryRegion.Code,
            SustainabilityLedgerEntries.Filter.GetFilter("Country/Region Code"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Country/Region Code".Caption()));
        Assert.AreEqual(
            StrSubstNo(Format(CalcDate('<-CY>', WorkDate())) + '..' + Format(CalcDate('<CY>', WorkDate()))),
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Posting Date".Caption()));
    end;

    [Test]
    procedure TestESGReportingPreviewForSustainabilityAccountWithOppositeSign()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 537477] Verify the ESG Reporting Preview Data for Sustainability Account using "Calculate With" and "Show With".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::"Opposite Sign",
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::"Opposite Sign");

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::"Opposite Sign",
            true,
            ESGReportingLine[3]."Show with"::"Opposite Sign");

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [WHEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [THEN] Verify the ESG Reporting Preview Data with "Calculate with"::"Opposite Sign" and "Show with"::"Sign".
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[1]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals(-ExpectedCO2eEmission * 2);

        // [THEN] Verify the ESG Reporting Preview Data with "Calculate with"::"Sign" and "Show with"::"Opposite Sign".
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[2]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals(-ExpectedCarbonFee * 2);

        // [THEN] Verify the ESG Reporting Preview Data with "Calculate with"::"Opposite Sign" and "Show with"::"Opposite Sign".
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.AssertEquals(0);
    end;

    [Test]
    procedure TestRowShouldNotBeVisibleInESGReportingPreviewForSustainabilityAccount()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[3] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the row should not be visible in ESG Reporting Preview Data for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::"Opposite Sign",
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("Carbon Fee"),
            ESGReportingLine[2]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::"Opposite Sign");

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::Formula,
            0,
            0,
            ESGReportingLine[3]."Value Settings"::" ",
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            ESGReportingLine[1]."Row No." + '+' + ESGReportingLine[2]."Row No.",
            ESGReportingLine[3]."Calculate with"::"Opposite Sign",
            false,
            ESGReportingLine[3]."Show with"::"Opposite Sign");

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [GIVEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [WHEN] Open ESG Reporting Line C with Show False. 
        asserterror ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);

        // [THEN] Verify the row should not be visible in ESG Reporting Preview Data.
        Assert.ExpectedError(RowNotfoundErr);
    end;

    [Test]
    procedure TestDrillDownAndFiltersOfESGReportingPreview()
    var
        GLEntry: Record "G/L Entry";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        EmissionFee: array[3] of Record "Emission Fee";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: array[5] of Record "Sust. ESG Reporting Line";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ESGReportingManagement: Codeunit "Sust. ESG Reporting Management";
        ESGReportingAggregation: TestPage "Sust. ESG Report. Aggregation";
        ESGReportingPreview: TestPage "Sust. ESG Reporting Preview";
        SustainabilityLedgerEntries: TestPage "Sustainability Ledger Entries";
        GeneralLedgerEntries: TestPage "General Ledger Entries";
        CustomerList: TestPage "Customer List";
        VendorList: TestPage "Vendor List";
        EmployeeList: TestPage "Employee List";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 537477] Verify the DrillDown and Filters of ESG Reporting Preview When "Column Value" field is selected.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create ESG Reporting Template.
        LibrarySustainability.CreateESGReportingTemplate(ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Name.
        LibrarySustainability.CreateESGReportingName(ESGReportingName, ESGReportingTemplate);

        // [GIVEN] Create ESG Reporting Line A.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[1],
            ESGReportingName,
            10000,
            '',
            '10',
            ESGReportingLine[1]."Field Type"::"Table Field",
            Database::"Sustainability Ledger Entry",
            SustainabilityLedgerEntry.FieldNo("CO2e Emission"),
            ESGReportingLine[1]."Value Settings"::Sum,
            AccountCode,
            ESGReportingLine[1]."Row Type"::"Net Change",
            '',
            ESGReportingLine[1]."Calculate with"::Sign,
            true,
            ESGReportingLine[1]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line B.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[2],
            ESGReportingName,
            20000,
            '',
            '20',
            ESGReportingLine[2]."Field Type"::"Table Field",
            Database::"G/L Entry",
            GLEntry.FieldNo(Amount),
            ESGReportingLine[2]."Value Settings"::Sum,
            '',
            ESGReportingLine[2]."Row Type"::"Net Change",
            '',
            ESGReportingLine[2]."Calculate with"::Sign,
            true,
            ESGReportingLine[2]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line C.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[3],
            ESGReportingName,
            30000,
            '',
            '30',
            ESGReportingLine[3]."Field Type"::"Table Field",
            Database::Customer,
            Customer.FieldNo("No."),
            ESGReportingLine[3]."Value Settings"::Count,
            '',
            ESGReportingLine[3]."Row Type"::"Net Change",
            '',
            ESGReportingLine[3]."Calculate with"::Sign,
            true,
            ESGReportingLine[3]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line D.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[4],
            ESGReportingName,
            40000,
            '',
            '40',
            ESGReportingLine[4]."Field Type"::"Table Field",
            Database::Vendor,
            Vendor.FieldNo("No."),
            ESGReportingLine[4]."Value Settings"::Count,
            '',
            ESGReportingLine[4]."Row Type"::"Net Change",
            '',
            ESGReportingLine[4]."Calculate with"::Sign,
            true,
            ESGReportingLine[4]."Show with"::Sign);

        // [GIVEN] Create ESG Reporting Line E.
        LibrarySustainability.CreateESGReportingLine(
            ESGReportingLine[5],
            ESGReportingName,
            50000,
            '',
            '50',
            ESGReportingLine[5]."Field Type"::"Table Field",
            Database::Employee,
            Employee.FieldNo("No."),
            ESGReportingLine[5]."Value Settings"::Count,
            '',
            ESGReportingLine[5]."Row Type"::"Net Change",
            '',
            ESGReportingLine[5]."Calculate with"::Sign,
            true,
            ESGReportingLine[5]."Show with"::Sign);

        // [GIVEN] Open ESG Reporting Aggregation.
        ESGReportingAggregation.Trap();
        ESGReportingManagement.TemplateSelectionFromBatch(ESGReportingName);

        // [GIVEN] Open ESG Reporting Preview.
        ESGReportingPreview.Trap();
        ESGReportingAggregation.Preview.Invoke();
        ESGReportingPreview.GoToRecord(ESGReportingName);

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        SustainabilityLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[1]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Posting Date" filters in Sustainability Ledger Entries.
        Assert.AreEqual(
            StrSubstNo('''''..' + Format(DMY2Date(31, 12, 9999))),
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, SustainabilityLedgerEntries."Posting Date".Caption()));

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        GeneralLedgerEntries.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[2]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify "Posting Date" filters in General Ledger Entries.
        Assert.AreEqual(
            StrSubstNo('''''..' + Format(DMY2Date(31, 12, 9999))),
            GeneralLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterIsIncorrectErr, GeneralLedgerEntries."Posting Date".Caption()));

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        CustomerList.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[3]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify Customer List must be trapped.

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        VendorList.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[4]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify Vendor List must be trapped.

        // [WHEN] Drill Down On "Column Value" Field in ESG Reporting Preview.
        EmployeeList.Trap();
        ESGReportingPreview.ESGReportingPreviewSubPage.GoToRecord(ESGReportingLine[5]);
        ESGReportingPreview.ESGReportingPreviewSubPage.ColumnValue.Drilldown();

        // [THEN] Verify Employee List must be trapped.
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
            AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure CreateAndPostPurchaseOrderWithSustAccount(AccountCode: Code[20]; PostingDate: Date; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify();

        // Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O .
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateEmissionFeeWithEmissionScope(var EmissionFee: array[3] of Record "Emission Fee"; EmissionScope: Enum "Emission Scope"; CountryRegionCode: Code[10])
    begin
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
    end;

    local procedure FindPostedESGReportingLine(var PostedESGReportingLine: Record "Sust. Posted ESG Report Line"; RowNo: Code[10])
    begin
        PostedESGReportingLine.SetRange("Row No.", RowNo);
        PostedESGReportingLine.FindFirst();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;
}
