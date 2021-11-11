codeunit 135085 "Bank Name Conv Serv Lookup"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [Bank List]
    end;

    var
        Assert: Codeunit Assert;
        LibraryAMCWebService: Codeunit "Library - Amc Web Service";
        IsInitialized: Boolean;
        MissingElementMsg: Label 'There is no element in the list. The service did not provide any elements.';
        NotEmptyListMsg: Label 'There should be no elemets in the list.';
        IncorrectBankMsg: Label 'The bank name is not the same as the expected one.';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryAMCWebService.SetupDefaultService();
        LibraryAMCWebService.SetServiceUrlToTest();
        LibraryAMCWebService.SetServiceCredentialsToTest();

        IsInitialized := true;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetBankNameList()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankBankNameList: TestPage "AMC Bank Bank Name List";
    begin
        // [SCENARIO] Open the AMC Banking Bank List page and see the list of bank names retrieved from the conversion service.
        // [GIVEN] The list of AMC Banking banks is empty.
        // [WHEN] Opening the AMC Banking Bank List page.
        // [THEN] The banks supported by the conversion service are listed.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();

        // Exercise
        AMCBankBankNameList.OpenEdit();

        // Verify
        Assert.IsTrue(AMCBankBankNameList.First(), MissingElementMsg);

        // Teardown
        AMCBankBankNameList.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FilterBankNameList()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankBankNameList: TestPage "AMC Bank Bank Name List";
    begin
        // [SCENARIO] Open the AMC Banking Bank List page and see Country/Region Code filter hides the banks.
        // [GIVEN] The list of AMC Banking banks is empty.
        // [WHEN] Opening the AMC Banking Bank List page and changing the Country/Region Code filter.
        // [THEN] There are no banks listed because the conversion service does not support banks for that country/region.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        AMCBankBankNameList.OpenEdit();

        // Pre-Verify
        Assert.IsTrue(AMCBankBankNameList.First(), MissingElementMsg);

        // Exercise
        AMCBankBankNameList.FILTER.SetFilter("Country/Region Code", 'XX');

        // Verify
        Assert.IsFalse(AMCBankBankNameList.First(), NotEmptyListMsg);

        // Teardown
        AMCBankBankNameList.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FilterThenClearFilterBankNameList()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankBankNameList: TestPage "AMC Bank Bank Name List";
    begin
        // [SCENARIO] Open the AMC Banking Bank List page and see Country/Region Code filter hides/shows the banks.
        // [GIVEN] The list of AMC Banking banks is empty.
        // [WHEN] Opening the AMC Banking Bank List page and changing the Country/Region Code filter.
        // [THEN] The list of banks is populated againg after removing the filter.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        AMCBankBankNameList.OpenEdit();

        // Pre-Verify
        Assert.IsTrue(AMCBankBankNameList.First(), MissingElementMsg);

        // Exercise
        AMCBankBankNameList.FILTER.SetFilter("Country/Region Code", 'XX');
        Assert.IsFalse(AMCBankBankNameList.First(), NotEmptyListMsg);
        AMCBankBankNameList.FILTER.SetFilter("Country/Region Code", '');

        // Verify
        Assert.IsTrue(AMCBankBankNameList.First(), MissingElementMsg);

        // Teardown
        AMCBankBankNameList.Close();
    end;

    [Test]
    [HandlerFunctions('RPHBankNameConvList')]
    [Scope('OnPrem')]
    procedure SelectBankNameFilteredByCompanyCountryRegionCode()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        CompanyInformation: Record "Company Information";
        BankAccount: Record "Bank Account";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [SCENARIO] From the bank account card select the first bank name filtered by the company country/region code.
        // [GIVEN] The Bank Account Card does not contain a value for the Country/Region Code.
        // [WHEN] Opening the Bank Data Coanversion Bank List page and selecting the first bank in the list.
        // [THEN] The Bank Name - Data Conversion field is populated with the first bank in the list filtered by the
        // companies Country/Region Code.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        CompanyInformation.Get();
        CompanyInformation.Validate("Country/Region Code", 'GB');
        CompanyInformation.Modify();
        BankAccount.FindFirst();
        Clear(BankAccount."Bank Account No.");
        BankAccount.Modify();
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".SetValue('');

        // Exercise
        BankAccountCard."Bank Name format".SetValue('B');
        BankAccountCard."Bank Name format".Lookup();

        // Verify
        Assert.IsTrue(StrPos(BankAccountCard."Bank Name format".Value(), 'GB') > 0, IncorrectBankMsg);

        // Teardown
        BankAccountCard.Close();
    end;

    [Test]
    [HandlerFunctions('RPHBankNameConvList')]
    [Scope('OnPrem')]
    procedure SelectBankNameFilteredByBankAccountCountryRegionCode()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [SCENARIO] From the bank account card select the first bank name filtered by the bank account country/region code.
        // [GIVEN] The Bank Account Card does contain a value for the Country/Region Code.
        // [WHEN] Opening the Bank Data Coanversion Bank List page and selecting the first bank in the list.
        // [THEN] The Bank Name - Data Conversion field is populated with the first bank in the list filtered by the
        // bank account Country/Region Code.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".SetValue('DK');

        // Exercise
        BankAccountCard."Bank Name format".SetValue('N');
        BankAccountCard."Bank Name format".Lookup();

        // Verify
        Assert.IsTrue(StrPos(BankAccountCard."Bank Name format".Value(), 'DK') > 0, IncorrectBankMsg);

        // Tear down
        BankAccountCard.Close();
    end;

    [Test]
    [HandlerFunctions('RPHBankNameConvList')]
    [Scope('OnPrem')]
    procedure SelectBankNameFilteredByBankAccountCountryRegionCodeTwice()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [BUG] Bug 159834:Bank Name - Data Conversion has an empty lookup.
        Initialize();

        // Setup DK
        AMCBankBanks.DeleteAll();
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".SetValue('DK');

        // Exercise
        BankAccountCard."Bank Name format".SetValue('N');
        BankAccountCard."Bank Name format".Lookup();

        // Verify
        Assert.IsTrue(StrPos(BankAccountCard."Bank Name format".Value(), 'DK') > 0, IncorrectBankMsg);

        // Setup GB
        BankAccountCard."Country/Region Code".SetValue('GB');

        // Exercise
        BankAccountCard."Bank Name format".SetValue('N');
        BankAccountCard."Bank Name format".Lookup();

        // Verify
        Assert.IsTrue(StrPos(BankAccountCard."Bank Name format".Value(), 'GB') > 0, IncorrectBankMsg);

        // Tear down
        BankAccountCard.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure OpenBankListPageAndDoNotRefreshCurrentData()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankBankNameList: TestPage "AMC Bank Bank Name List";
    begin
        // [SCENARIO] Open the AMC Banking Bank List page and see that the banks are the same as before because they are current.
        // [GIVEN] The list of AMC Banking banks contains a bank that was retrieved today.
        // [WHEN] Opening the AMC Banking Bank List page.
        // [THEN] The bank that was already there is still present and no new banks have been added.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        InsertAMCBankBanks(Today());

        // Exercise
        AMCBankBankNameList.OpenEdit();

        // Verify
        AMCBankBanks.FindFirst();
        AMCBankBanks.TestField("Bank Name", 'Today Bank DK');

        // Teardown
        AMCBankBankNameList.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure OpenBankListPageAndRefreshListBecauseDataIsOld()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankBankNameList: TestPage "AMC Bank Bank Name List";
    begin
        // [SCENARIO] Open the AMC Banking Bank List page and see that the banks have been updated.
        // [GIVEN] The list of AMC Banking banks contains a bank that was updated yesterday.
        // [WHEN] Opening the AMC Banking Bank List page.
        // [THEN] The banks supported by the conversion service are listed.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();
        InsertAMCBankBanks(Today() - 1);

        // Exercise
        AMCBankBankNameList.OpenEdit();

        // Verify
        AMCBankBanks.FindFirst();
        Assert.AreNotEqual('Today Bank DK', AMCBankBanks."Bank Name", IncorrectBankMsg);

        // Teardown
        AMCBankBankNameList.Close();
        // Setup
    end;

    local procedure InsertAMCBankBanks(LastUpdateDate: Date)
    var
        AMCBankBanks: Record "AMC Bank Banks";
    begin
        AMCBankBanks.Init();
        AMCBankBanks.Bank := 'Today Bank';
        AMCBankBanks."Bank Name" := 'Today Bank DK';
        AMCBankBanks."Country/Region Code" := 'DK';
        AMCBankBanks."Last Update Date" := LastUpdateDate;
        AMCBankBanks.Insert();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure RPHBankNameConvList(var AMCBankBankNameList: TestPage "AMC Bank Bank Name List")
    begin
        AMCBankBankNameList.OK().Invoke();
    end;
}

