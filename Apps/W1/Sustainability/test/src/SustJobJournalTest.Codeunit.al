namespace Microsoft.Test.Sustainability;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;

codeunit 148211 "Sust. Job Journal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJob: Codeunit "Library - Job";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeResource()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create a Resource.
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource.
        VerifySustainabilityValueEntry("Sust. Value Type"::Resource, ResourceNo, -Quantity, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeItem()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item.
        VerifySustainabilityValueEntry("Sust. Value Type"::Item, Item."No.", -Quantity, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeGL()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account". 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account".
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GLAccount."No.", -Quantity, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeResourceAndNegativeQuantity()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource and Negative Quantity. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create a Resource.
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, -Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource.
        VerifySustainabilityValueEntry("Sust. Value Type"::Resource, ResourceNo, Quantity, TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeItemAndNegativeQuantity()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item and Negative Quantity. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an Item.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, TotalCO2e);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, -Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item.
        VerifySustainabilityValueEntry("Sust. Value Type"::Item, Item."No.", Quantity, TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithTypeGLAndNegativeQuantity()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account" and Negative Quantity. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account" and Item.
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, -Quantity, TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account".
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GLAccount."No.", Quantity, TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithNegativeEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Negative Emission. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryInventory.CreateItem(Item);
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account".
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GLAccount."No.", -Quantity, TotalCO2e);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource.
        VerifySustainabilityValueEntry("Sust. Value Type"::Resource, ResourceNo, -Quantity, TotalCO2e);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item.
        VerifySustainabilityValueEntry("Sust. Value Type"::Item, Item."No.", -Quantity, TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifyCO2eValueInJobStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        JobCard: TestPage "Job Card";
        JobStatistics: TestPage "Job Statistics";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: array[3] of Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify "Total CO2e" in "Job Statistics".
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryInventory.CreateItem(Item);
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[1] := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[2] := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[3] := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, -TotalCO2e[1]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, -TotalCO2e[2]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, -TotalCO2e[3]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Open Job Card.
        JobCard.OpenEdit();
        JobCard.FILTER.SetFilter("No.", JobTask."Job No.");
        JobStatistics.Trap();

        // [WHEN] Invoke "Job Statistics".
        JobCard."&Statistics".Invoke();

        // [THEN] Verify "Resource (Total CO2e)", "Item (Total CO2e)", "G/L Account (Total CO2e)", "Total CO2e" in "Job Statistics".
        JobStatistics."G/L Account (Total CO2e)".AssertEquals(TotalCO2e[1]);
        JobStatistics."Resource (Total CO2e)".AssertEquals(TotalCO2e[2]);
        JobStatistics."Item (Total CO2e)".AssertEquals(TotalCO2e[3]);
        JobStatistics."Total CO2e".AssertEquals(TotalCO2e[1] + TotalCO2e[2] + TotalCO2e[3]);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifyCO2eValueInJobTaskStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        JobTaskLines: TestPage "Job Task Lines";
        JobTaskStatistics: TestPage "Job Task Statistics";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: array[3] of Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify "Total CO2e" in "Job Task Statistics".
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryInventory.CreateItem(Item);
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[1] := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[2] := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e[3] := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, Quantity, -TotalCO2e[1]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, -TotalCO2e[2]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, Quantity, -TotalCO2e[3]);

        // [GIVEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Open Job Task Lines.
        JobTaskLines.OpenEdit();
        JobTaskLines.FILTER.SetFilter("Job No.", JobTask."Job No.");
        JobTaskStatistics.Trap();

        // [WHEN] Invoke "Job Task Statistics".
        JobTaskLines.JobTaskStatistics.Invoke();

        // [THEN] Verify "Resource (Total CO2e)", "Item (Total CO2e)", "G/L Account (Total CO2e)", "Total CO2e" in "Job Task Statistics".
        JobTaskStatistics."G/L Account (Total CO2e)".AssertEquals(TotalCO2e[1]);
        JobTaskStatistics."Resource (Total CO2e)".AssertEquals(TotalCO2e[2]);
        JobTaskStatistics."Item (Total CO2e)".AssertEquals(TotalCO2e[3]);
        JobTaskStatistics."Total CO2e".AssertEquals(TotalCO2e[1] + TotalCO2e[2] + TotalCO2e[3]);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobJournalIsPostedWithNegativeQuantityAndEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        TotalCO2e: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the Job Journal is posted with Negative Quantity and Emission. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create an "G/L Account".
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryInventory.CreateItem(Item);
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::"G/L Account", GLAccount."No.", AccountCode, -Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type "G/L Account".
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GLAccount."No.", Quantity, -TotalCO2e);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, -Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Resource.
        VerifySustainabilityValueEntry("Sust. Value Type"::Resource, ResourceNo, Quantity, -TotalCO2e);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", '', Quantity, 0);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Item, Item."No.", AccountCode, -Quantity, -TotalCO2e);

        // [WHEN] Posting the Job Journal Line.
        LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the Job Journal is posted with Type Item.
        VerifySustainabilityValueEntry("Sust. Value Type"::Item, Item."No.", Quantity, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    procedure VerifyJobJournalCannotBePostWithZeroEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        JobJournalLine: Record "Job Journal Line";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ResourceNo: Code[20];
        Quantity: Decimal;
    begin
        // [SCENARIO 554969] Verify Job Journal cannot be post with zero emission.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create a Resource.
        ResourceNo := LibraryJob.CreateConsumable("Job Planning Line Type"::Resource);

        // [GIVEN] Generate Quantity.
        Quantity := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobJournalLine(JobJournalLine, JobTask, JobJournalLine.Type::Resource, ResourceNo, AccountCode, Quantity, 0);

        // [WHEN] Posting the Job Journal Line.
        asserterror LibraryJob.PostJobJournal(JobJournalLine);

        // [THEN] Verify Job Journal cannot be post with zero emission.
        Assert.ExpectedError(CO2eMustNotBeZeroErr);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobGLJournalIsPosted()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
            Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Post the General Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted.
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GenJournalLine."Account No.", -Quantity, -TotalCO2e);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobGLJournalIsPostedWithNegativeQuantity()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Quantity. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
           -Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Post the General Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Quantity.
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GenJournalLine."Account No.", Quantity, TotalCO2e);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobGLJournalIsPostedWithNegativeEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Emission. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
           Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", -TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Post the General Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Emission.
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GenJournalLine."Account No.", -Quantity, TotalCO2e);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenJobGLJournalIsPostedWithNegativeQuantityAndEmission()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JobTask: Record "Job Task";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Quantity and Emission. 
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
           -Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", -TotalCO2e);
        GenJournalLine.Modify();

        // [WHEN] Post the General Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Sustainability Value entry should be created when the "Job G/L Journal" is posted with Negative Quantity and Emission.
        VerifySustainabilityValueEntry("Sust. Value Type"::"G/L Account", GenJournalLine."Account No.", Quantity, -TotalCO2e);
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfJobGLJournal()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JobTask: Record "Job Task";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quantity: Decimal;
        TotalCO2e: Decimal;
    begin
        // [SCENARIO 554969] Verify Sustainability Value Entry should be created during Preview Posting of Job G/L Journal.
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Job with Job Task.
        CreateJobWithJobTask(JobTask);

        // [GIVEN] Create and Update Job Journal Batch.
        CreateAndUpdateJobJournalBatch(GenJournalBatch);

        // [GIVEN] Generate Quantity, "Total CO2e".
        Quantity := LibraryRandom.RandIntInRange(50, 100);
        TotalCO2e := LibraryRandom.RandIntInRange(50, 100);

        // [GIVEN] Create Job Gen Journal Line with Job Task.
        CreateJobGLJournalLine(
            GenJournalLine,
            GenJournalBatch,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNo(),
            LibraryERM.CreateGLAccountNo(),
            JobTask."Job No.",
            JobTask."Job Task No.",
            '',
           -Quantity);

        GenJournalLine.Validate("Sust. Account No.", AccountCode);
        GenJournalLine.Validate("Total CO2e", -TotalCO2e);
        GenJournalLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Preview General Jnl Line.
        asserterror GenJnlPost.Preview(GenJournalLine);

        // [THEN] No errors occurred - preview mode error only.
        Assert.ExpectedError('');
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sust. Job Journal Test");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sust. Job Journal Test");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sust. Job Journal Test");
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateJobJournalLine(var JobJournalLine: Record "Job Journal Line"; JobTask: Record "Job Task"; JobJournalLineType: Enum "Job Journal Line Type"; No: Code[20]; AccountCode: Code[20]; Quantity: Decimal; TotalCO2e: Decimal)
    begin
        LibraryJob.CreateJobJournalLineForType("Job Line Type"::" ", JobJournalLineType, JobTask, JobJournalLine);
        JobJournalLine.Validate("No.", No);
        JobJournalLine.Validate(Quantity, Quantity);
        JobJournalLine.Validate("Sust. Account No.", AccountCode);
        JobJournalLine.Validate("Total CO2e", TotalCO2e);
        JobJournalLine.Modify(true);
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

    local procedure VerifySustainabilityValueEntry(ValueType: Enum "Sust. Value Type"; No: Code[20]; Quantity: Decimal; ExpectedCO2eEmission: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        FindSustainabilityValueEntry(SustainabilityValueEntry, ValueType, No, Quantity);

        Assert.RecordCount(SustainabilityValueEntry, 1);

        Assert.AreEqual(
            Round(ExpectedCO2eEmission),
            Round(SustainabilityValueEntry."CO2e Amount (Actual)"),
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), Round(ExpectedCO2eEmission), SustainabilityValueEntry.TableCaption()));
    end;

    local procedure FindSustainabilityValueEntry(var SustainabilityValueEntry: Record "Sustainability Value Entry"; ValueType: Enum "Sust. Value Type"; No: Code[20]; ValuedQuantity: Decimal)
    begin
        SustainabilityValueEntry.SetRange(Type, ValueType);
        SustainabilityValueEntry.SetRange("No.", No);
        SustainabilityValueEntry.SetRange("Valued Quantity", ValuedQuantity);
        SustainabilityValueEntry.FindFirst();
    end;

    local procedure CreateAndUpdateJobJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        CreateJobJournalBatch(GenJournalBatch);
        GenJournalBatch.Validate("Copy VAT Setup to Jnl. Lines", false);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateJobJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Jobs);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateJobGLJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountNo: Code[20]; JobNo: Code[20]; JobTaskNo: Code[20]; CurrencyCode: Code[10]; Quantity: Decimal)
    begin
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", AccountNo, LibraryRandom.RandDec(100, 2));

        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Validate("Job Line Type", GenJournalLine."Job Line Type"::"Both Budget and Billable");
        GenJournalLine.Validate("Job No.", JobNo);
        GenJournalLine.Validate("Job Task No.", JobTaskNo);
        GenJournalLine.Validate("Job Quantity", Quantity);
        GenJournalLine.Modify(true);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [PageHandler]
    procedure GLPostingPreviewHandler(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);
        GLPostingPreview.OK().Invoke();
    end;
}