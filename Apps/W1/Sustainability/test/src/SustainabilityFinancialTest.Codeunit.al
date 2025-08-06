namespace Microsoft.Test.Sustainability;

using System.TestLibraries.Utilities;
using Microsoft.Sustainability.Emission;
using Microsoft.Finance.FinancialReports;
using Microsoft.Sustainability.Account;
using Microsoft.Finance.Analysis;
using Microsoft.Sustainability.Ledger;
using Microsoft.Purchases.Document;

codeunit 148186 "Sustainability Financial Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        RecordCountMustBeEqualErr: Label 'Record Count must be equal to %1 in Page %2', Comment = '%1 = Record Count , %2 = Page Caption';
        EmissionAmountMustBeEqualErr: Label 'Total %1 must be equal to %2 in Page %3', Comment = '%1 = Field Caption ,%2 = Total Amount, %3 = Page Caption';

    [Test]
    procedure TestFinancialReportsForSustainabilityAccount()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        FinancialReport: Record "Financial Report";
        SustainabilityAccount: Record "Sustainability Account";
        FinancialReports: TestPage "Financial Reports";
        AccScheduleOverview: TestPage "Acc. Schedule Overview";
        FinancialReportName: Code[10];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 507032] Verify the Financial Report Data for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Change WorkDate + 1.
        WorkDate(Today + 1);

        // [GIVEN] Create and Post Purchase Order with WorkDate() + 1.
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create Financial Report.
        FinancialReportName := Format(LibraryRandom.RandText(10));
        CreateFinancialReport(FinancialReportName, AccountCode);

        // [WHEN] View Financial Reports.
        FinancialReport.Get(FinancialReportName);
        FinancialReports.OpenEdit();
        FinancialReports.GoToRecord(FinancialReport);
        AccScheduleOverview.Trap();
        FinancialReports.ViewFinancialReport.Invoke();

        // [VERIFY] Financial Report shows the correct data
        VerifyDataFinancialReport(AccScheduleOverview, ExpectedCO2eEmission, ExpectedCarbonFee);
    end;

    [Test]
    procedure VerifyAnalysisViewEntryForSustainabilityAccount()
    var
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 507032] Verify the Analysis View Entry for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [WHEN] Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [VERIFY] Verify the Analysis View Entry for Sustainability Account.
        VerifyAnalysisViewEntry(AnalysisView.Code, AccountCode, EmissionCO2 * 2, EmissionCH4 * 2, EmissionN2O * 2)
    end;

    [Test]
    procedure VerifyAnalysisViewEntryForSustainabilityAccountWithDifferentDates()
    var
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 507032] Verify the Analysis View Entry for Sustainability Account with Different Dates.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(10);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Change WorkDate + 1.
        WorkDate(Today + 1);

        // [GIVEN] Create and Post another Purchase Order with WorkDate() + 1 .
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [WHEN] Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [VERIFY] Verify the Analysis View Entry for Sustainability Account with Different Dates.
        VerifyAnalysisViewEntryWithDifferentDates(AnalysisView.Code, AccountCode, EmissionCO2, EmissionCH4, EmissionN2O)
    end;

    [Test]
    [HandlerFunctions('SustainabilityAccountListPageHandler')]
    procedure VerifyAccountFilterShouldOpenSustainabilityAccountListInAnalysisViewCard()
    var
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewCard: TestPage "Analysis View Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 507032] Verify Account Filter Should Open Page Sustainability Account List in Analysis View Card.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Save Account Code.
        LibraryVariableStorage.Enqueue(AccountCode);

        AnalysisViewCard.OpenNew();
        AnalysisViewCard.Code.SetValue(Format(LibraryRandom.RandText(10)));
        AnalysisViewCard."Account Source".SetValue(AnalysisView."Account Source"::"Sust. Account");
        AnalysisViewCard."Account Filter".Lookup();

        // [WHEN] Verify Account Filter Should Open Page Sustainability Account List in Analysis View Card through Handler.
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('SustainabilityLedgEntriesPageHandler')]
    procedure VerifyAmountLookupShouldOpenSustainablityLedgerEntriesInAnalysisViewEntry()
    var
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        AnalysisViewEntries: TestPage "Analysis View Entries";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 507032] Verify amount Lookup should open Sustainability Ledger Entries in Analysis View Entry.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [WHEN] Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [GIVEN] Save Expected Amount.
        LibraryVariableStorage.Enqueue(2);
        LibraryVariableStorage.Enqueue(EmissionCO2 * 2);
        LibraryVariableStorage.Enqueue(EmissionCH4 * 2);
        LibraryVariableStorage.Enqueue(EmissionN2O * 2);

        // [WHEN] Open Analysis View Entry.
        AnalysisViewEntries.OpenView();
        AnalysisViewEntries.Filter.SetFilter("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntries.Amount.Lookup();
        AnalysisViewEntries.Close();

        // [VERIFY] Verify amount Lookup should open Sustainability Ledger Entries in Analysis View Entry through handler.
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('SustainabilityLedgEntriesPageHandler')]
    procedure VerifyAmountLookupShouldOpenSustainablityLedgerEntriesInAnalysisViewEntryWithDifferentDates()
    var
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        AnalysisViewEntries: TestPage "Analysis View Entries";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
    begin
        // [SCENARIO 507032] Verify amount Lookup should open Sustainability Ledger Entries in Analysis View Entry with different dates.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(10);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Change WorkDate + 1.
        WorkDate(Today + 1);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Change WorkDate to today.
        WorkDate(Today);

        // [WHEN] Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [GIVEN] Save Expected Amount.
        LibraryVariableStorage.Enqueue(1);
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);

        // [WHEN] Open Analysis View Entry.
        AnalysisViewEntries.OpenView();
        AnalysisViewEntries.Filter.SetFilter("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntries.Filter.SetFilter("Posting Date", Format(WorkDate()));
        AnalysisViewEntries.Amount.Lookup();
        AnalysisViewEntries.Close();

        // [VERIFY] Verify amount Lookup should open Sustainability Ledger Entries in Analysis View Entry through handler.
        LibraryVariableStorage.Clear();

        // [GIVEN] Save Expected Amount.
        LibraryVariableStorage.Enqueue(1);
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);

        // [WHEN] Open Analysis View Entry.
        AnalysisViewEntries.OpenView();
        AnalysisViewEntries.Filter.SetFilter("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntries.Filter.SetFilter("Posting Date", Format(WorkDate() + 1));
        AnalysisViewEntries.Amount.Lookup();
        AnalysisViewEntries.Close();

        // [VERIFY] Verify amount Lookup should open Sustainability Ledger Entries in Analysis View Entry through handler.
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifyAnalysisViewEntryForCO2eEmissionAndCarbonFee()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AnalysisView: Record "Analysis View";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 564701] Verify "CO2e Emission" and "Carbon Fee" in Analysis View Entry for Sustainability Account.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create and Post another Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [WHEN] Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [VERIFY] Verify "CO2e Emission" and "Carbon Fee" in Analysis View Entry for Sustainability Account.
        VerifyAnalysisViewEntryForCO2eEmissionAndCarbonFee(AnalysisView.Code, AccountCode, ExpectedCO2eEmission * 2, ExpectedCarbonFee * 2)
    end;

    [Test]
    procedure TestFinancialReportsForAnalysisView()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AnalysisView: Record "Analysis View";
        FinancialReport: Record "Financial Report";
        SustainabilityAccount: Record "Sustainability Account";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewCard: TestPage "Analysis View Card";
        FinancialReports: TestPage "Financial Reports";
        AccScheduleOverview: TestPage "Acc. Schedule Overview";
        FinancialReportName: Code[10];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 564701] Verify "CO2e Emission" and "Carbon Fee" in the Financial Report Data for Analysis View.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Delete Analysis View Entry.
        AnalysisViewEntry.DeleteAll();

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(5);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create and Post Purchase Order with WorkDate().
        CreateAndPostPurchaseOrderWithSustAccount(AccountCode, WorkDate(), EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create Analysis view record for Sustainability Account.
        CreateAnalysisViewForSustainabilityAccount(AnalysisViewCard, AnalysisView, AccountCode);
        AnalysisViewCard.Close();

        // [GIVEN] Create Financial Report.
        FinancialReportName := Format(LibraryRandom.RandText(10));
        CreateFinancialReportWithAnalysisView(FinancialReportName, AnalysisView.Code, AccountCode);

        // [WHEN] View Financial Reports.
        FinancialReport.Get(FinancialReportName);
        FinancialReports.OpenEdit();
        FinancialReports.GoToRecord(FinancialReport);
        AccScheduleOverview.Trap();
        FinancialReports.ViewFinancialReport.Invoke();

        // [VERIFY] Verify "CO2e Emission" and "Carbon Fee" in the Financial Report Data for Analysis View.
        VerifyDataFinancialReport(AccScheduleOverview, ExpectedCO2eEmission, ExpectedCarbonFee);
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

    local procedure CreateFinancialReport(FinancialReportName: Code[10]; TotalingFilter: Text[250])
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleLine: Record "Acc. Schedule Line";
        FinancialReport: Record "Financial Report";
        ColumnLayoutName: Record "Column Layout Name";
    begin
        if FinancialReport.Get(FinancialReportName) then
            FinancialReport.Delete();

        Clear(FinancialReport);
        FinancialReport.Name := FinancialReportName;
        FinancialReport.Description := FinancialReportName;
        FinancialReport.Insert();

        AccScheduleLine.SetRange("Schedule Name", FinancialReportName);
        AccScheduleLine.DeleteAll();

        if AccScheduleName.Get(FinancialReportName) then
            AccScheduleName.Delete();

        AccScheduleName.Name := FinancialReportName;
        AccScheduleName.Description := FinancialReportName;
        AccScheduleName."Analysis View Name" := '';
        AccScheduleName.Insert();

        AccScheduleLine.Init();
        AccScheduleLine."Schedule Name" := FinancialReportName;
        AccScheduleLine."Line No." := 10000;
        AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Sust. Accounts";
        AccScheduleLine.Totaling := TotalingFilter;
        AccScheduleLine."Row No." := '20';
        AccScheduleLine.Description := FinancialReportName;
        AccScheduleLine."Row Type" := AccScheduleLine."Row Type"::"Balance at Date";
        AccScheduleLine.Bold := true;
        AccScheduleLine.Insert();

        LibraryERM.CreateColumnLayoutName(ColumnLayoutName);
        CreateColumnLayout(ColumnLayoutName.Name, '10', Format("Account Schedule Amount Type"::CO2e), 10000, "Account Schedule Amount Type"::CO2e);
        CreateColumnLayout(ColumnLayoutName.Name, '20', Format("Account Schedule Amount Type"::"Carbon Fee"), 20000, "Account Schedule Amount Type"::"Carbon Fee");

        FinancialReport.Find();
        FinancialReport."Financial Report Row Group" := AccScheduleName.Name;
        FinancialReport."Financial Report Column Group" := ColumnLayoutName.Name;
        FinancialReport.Modify();
    end;

    local procedure CreateColumnLayout(ColumnLayoutName: Code[10]; ColumnNo: Code[10]; ColumnHeader: Code[30]; LineNo: Integer; AmountType: Enum "Account Schedule Amount Type")
    var
        ColumnLayout: Record "Column Layout";
    begin
        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Insert();
    end;

    local procedure VerifyDataFinancialReport(var AccScheduleOverview: TestPage "Acc. Schedule Overview"; ExpectedCO2Amount: Decimal; ExpectedCarbonAmount: Decimal)
    begin
        Assert.AreEqual(
            ExpectedCO2Amount,
            AccScheduleOverview.ColumnValues1.AsDecimal(),
            StrSubstNo(ValueMustBeEqualErr, AccScheduleOverview.ColumnValues1.Caption(), ExpectedCO2Amount, AccScheduleOverview.Caption));
        Assert.AreEqual(
            ExpectedCarbonAmount,
            AccScheduleOverview.ColumnValues2.AsDecimal(),
            StrSubstNo(ValueMustBeEqualErr, AccScheduleOverview.ColumnValues2.Caption(), ExpectedCarbonAmount, AccScheduleOverview.Caption));
    end;

    local procedure CreateAnalysisViewForSustainabilityAccount(var AnalysisViewCard: TestPage "Analysis View Card"; var AnalysisView: Record "Analysis View"; AccountCode: Code[20])
    var
        AnalysisViewCode: Code[10];
    begin
        AnalysisViewCard.OpenNew();
        AnalysisViewCode := Format(LibraryRandom.RandText(10));
        AnalysisViewCard.Code.SetValue(AnalysisViewCode);
        AnalysisViewCard."Account Source".SetValue(AnalysisView."Account Source"::"Sust. Account");
        AnalysisViewCard."Account Filter".SetValue(AccountCode);
        AnalysisViewCard."&Update".Invoke();
        AnalysisView.Get(AnalysisViewCode);
    end;

    local procedure VerifyAnalysisViewEntry(AnalysisViewCode: Code[10]; AccountCode: Code[20]; ExpectedCO2Amount: Decimal; ExpectedCH4Amount: Decimal; ExpectedN2OAmount: Decimal)
    var
        AnalysisViewEntry: Record "Analysis View Entry";
    begin
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisViewCode);
        AnalysisViewEntry.SetRange("Account No.", AccountCode);
        AnalysisViewEntry.FindSet();
        Assert.RecordCount(AnalysisViewEntry, 1);

        Assert.AreEqual(
            ExpectedCO2Amount,
            AnalysisViewEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission CO2"), ExpectedCO2Amount, AnalysisViewEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCH4Amount,
            AnalysisViewEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission CH4"), ExpectedCH4Amount, AnalysisViewEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedN2OAmount,
            AnalysisViewEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission N2O"), ExpectedN2OAmount, AnalysisViewEntry.TableCaption()));
    end;

    local procedure VerifyAnalysisViewEntryWithDifferentDates(AnalysisViewCode: Code[10]; AccountCode: Code[20]; ExpectedCO2Amount: Decimal; ExpectedCH4Amount: Decimal; ExpectedN2OAmount: Decimal)
    var
        AnalysisViewEntry: Record "Analysis View Entry";
    begin
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisViewCode);
        AnalysisViewEntry.SetRange("Account No.", AccountCode);
        AnalysisViewEntry.FindSet();
        Assert.RecordCount(AnalysisViewEntry, 2);

        Assert.AreEqual(
            ExpectedCO2Amount,
            AnalysisViewEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission CO2"), ExpectedCO2Amount, AnalysisViewEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCH4Amount,
            AnalysisViewEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission CH4"), ExpectedCH4Amount, AnalysisViewEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedN2OAmount,
            AnalysisViewEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Emission N2O"), ExpectedN2OAmount, AnalysisViewEntry.TableCaption()));
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

    local procedure CreateFinancialReportWithAnalysisView(FinancialReportName: Code[10]; AnalysisViewName: Code[10]; TotalingFilter: Text[250])
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleLine: Record "Acc. Schedule Line";
        FinancialReport: Record "Financial Report";
        ColumnLayoutName: Record "Column Layout Name";
    begin
        if FinancialReport.Get(FinancialReportName) then
            FinancialReport.Delete();

        Clear(FinancialReport);
        FinancialReport.Name := FinancialReportName;
        FinancialReport.Description := FinancialReportName;
        FinancialReport.Insert();

        AccScheduleLine.SetRange("Schedule Name", FinancialReportName);
        AccScheduleLine.DeleteAll();

        if AccScheduleName.Get(FinancialReportName) then
            AccScheduleName.Delete();

        AccScheduleName.Name := FinancialReportName;
        AccScheduleName.Description := FinancialReportName;
        AccScheduleName."Analysis View Name" := AnalysisViewName;
        AccScheduleName.Insert();

        AccScheduleLine.Init();
        AccScheduleLine."Schedule Name" := FinancialReportName;
        AccScheduleLine."Line No." := 10000;
        AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Sust. Accounts";
        AccScheduleLine.Totaling := TotalingFilter;
        AccScheduleLine."Row No." := '20';
        AccScheduleLine.Description := FinancialReportName;
        AccScheduleLine."Row Type" := AccScheduleLine."Row Type"::"Net Change";
        AccScheduleLine.Bold := true;
        AccScheduleLine.Insert();

        LibraryERM.CreateColumnLayoutName(ColumnLayoutName);
        CreateColumnLayout(ColumnLayoutName.Name, '10', Format("Account Schedule Amount Type"::CO2e), 10000, "Account Schedule Amount Type"::CO2e);
        CreateColumnLayout(ColumnLayoutName.Name, '20', Format("Account Schedule Amount Type"::"Carbon Fee"), 20000, "Account Schedule Amount Type"::"Carbon Fee");

        FinancialReport.Find();
        FinancialReport."Financial Report Row Group" := AccScheduleName.Name;
        FinancialReport."Financial Report Column Group" := ColumnLayoutName.Name;
        FinancialReport.Modify();
    end;

    local procedure VerifyAnalysisViewEntryForCO2eEmissionAndCarbonFee(AnalysisViewCode: Code[10]; AccountCode: Code[20]; ExpectedCO2eEmission: Decimal; ExpectedCarbonFee: Decimal)
    var
        AnalysisViewEntry: Record "Analysis View Entry";
    begin
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisViewCode);
        AnalysisViewEntry.SetRange("Account No.", AccountCode);
        AnalysisViewEntry.FindSet();
        Assert.RecordCount(AnalysisViewEntry, 1);

        Assert.AreEqual(
            ExpectedCO2eEmission,
            AnalysisViewEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, AnalysisViewEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCarbonFee,
            AnalysisViewEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, AnalysisViewEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, AnalysisViewEntry.TableCaption()));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SustainabilityAccountListPageHandler(var SustainabilityAccountList: TestPage "Sustainability Account List");
    begin
        SustainabilityAccountList."No.".AssertEquals(LibraryVariableStorage.DequeueText());
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SustainabilityLedgEntriesPageHandler(var SustainabilityLedgEntries: TestPage "Sustainability Ledger Entries");
    var
        RecordCount: Integer;
        TotalEmissionCO2: Decimal;
        TotalEmissionCH4: Decimal;
        TotalEmissionN2O: Decimal;
        VerifyRecordCount: Integer;
        VerifyTotalEmissionCO2: Decimal;
        VerifyTotalEmissionCH4: Decimal;
        VerifyTotalEmissionN2O: Decimal;
    begin
        SustainabilityLedgEntries.First();
        repeat
            RecordCount += 1;
            TotalEmissionCO2 += SustainabilityLedgEntries."Emission CO2".AsDecimal();
            TotalEmissionCH4 += SustainabilityLedgEntries."Emission CH4".AsDecimal();
            TotalEmissionN2O += SustainabilityLedgEntries."Emission N2O".AsDecimal();
        until not SustainabilityLedgEntries.Next();

        VerifyRecordCount := LibraryVariableStorage.DequeueInteger();
        VerifyTotalEmissionCO2 := LibraryVariableStorage.DequeueDecimal();
        VerifyTotalEmissionCH4 := LibraryVariableStorage.DequeueDecimal();
        VerifyTotalEmissionN2O := LibraryVariableStorage.DequeueDecimal();

        Assert.AreEqual(
            VerifyRecordCount,
            RecordCount,
            StrSubstNo(RecordCountMustBeEqualErr, VerifyRecordCount, SustainabilityLedgEntries.Caption()));
        Assert.AreEqual(
            VerifyTotalEmissionCO2,
            TotalEmissionCO2,
            StrSubstNo(EmissionAmountMustBeEqualErr, SustainabilityLedgEntries."Emission CO2".Caption(), VerifyTotalEmissionCO2, SustainabilityLedgEntries.Caption()));
        Assert.AreEqual(
            VerifyTotalEmissionCH4,
            TotalEmissionCH4,
            StrSubstNo(EmissionAmountMustBeEqualErr, SustainabilityLedgEntries."Emission CH4".Caption(), VerifyTotalEmissionCH4, SustainabilityLedgEntries.Caption()));
        Assert.AreEqual(
            VerifyTotalEmissionN2O,
            TotalEmissionN2O,
            StrSubstNo(EmissionAmountMustBeEqualErr, SustainabilityLedgEntries."Emission N2O".Caption(), VerifyTotalEmissionN2O, SustainabilityLedgEntries.Caption()));
    end;
}
