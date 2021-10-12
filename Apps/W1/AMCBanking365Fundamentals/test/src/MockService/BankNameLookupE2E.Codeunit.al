codeunit 135084 "Bank Name Lookup E2E"
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
        CountrCodeErr: Label 'The country code entered does not exist';

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
    procedure RequestBankListFromWebService()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
    begin
        // [SCENARIO] Send a request for the bank list supported by the conversion service
        // [WHEN] Run the Import Bank List Ext. Data Hndl codeunit.
        // [THEN] The banks supported by the conversion service are found in the correct table.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();

        // Exercise
        AMCBankImpBankListHndl.GetBankListFromWebService(true, '', 20000, AMCBankingMgt.GetAppCaller());

        // Verify
        Assert.RecordIsNotEmpty(AMCBankBanks);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RequestBankListFromWebServiceWithCountryFilter()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
    begin
        // [SCENARIO] Send a request for the bank list supported by the conversion service with a country filter
        // [WHEN] Run the Import Bank List Ext. Data Hndl codeunit after setting a country filter
        // [THEN] The banks supported by the conversion service are found in the correct table.

        Initialize();

        // Setup
        AMCBankBanks.SetRange("Country/Region Code", 'GB');
        AMCBankBanks.DeleteAll();

        // Exercise
        AMCBankImpBankListHndl.GetBankListFromWebService(true, 'GB', 20000, AMCBankingMgt.GetAppCaller());

        AMCBankBanks.SetRange("Country/Region Code", 'GB');

        // Verify
        Assert.RecordIsNotEmpty(AMCBankBanks);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RequestBankListFromWebServiceWithWrongCountryFilter()
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
    begin
        // [SCENARIO] Send a request for the bank list supported by the conversion service with a wrong country filter
        // [WHEN] Run the Import Bank List Ext. Data Hndl codeunit after setting a wrong country filter
        // [THEN] There are no banks imported because the service does not support any banks from this country.

        Initialize();

        // Setup
        AMCBankBanks.DeleteAll();

        // Exercise
        asserterror AMCBankImpBankListHndl.GetBankListFromWebService(true, 'XX', 20000, AMCBankingMgt.GetAppCaller());
        Assert.ExpectedError(CountrCodeErr);

        // Verify
        AMCBankBanks.SetRange("Country/Region Code", 'XX');
        Assert.RecordIsEmpty(AMCBankBanks);
    end;
}

