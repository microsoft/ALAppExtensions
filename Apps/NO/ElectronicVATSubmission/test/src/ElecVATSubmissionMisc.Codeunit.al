codeunit 148133 "Elec. VAT Submission Misc."
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryElecVATSubmission: Codeunit "Library - Elec. VAT Submission";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        ServiceConnectionSetupLbl: Label 'Elec. VAT Return Submission Setup';

    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission]
    end;

    [Test]
    [HandlerFunctions('OAuth20Setup_MPH')]
    [Scope('OnPrem')]
    procedure ElecVATSubmissionFeatureInServiceConnections()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ElectronicVATInstallation: Codeunit "Electronic VAT Installation";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 422655] Service Connection list contains the "Elec. VAT Submission" feature
        Initialize();

        ElectronicVATInstallation.RunExtensionSetup();
        LibraryElecVATSubmission.GetOAuthSetup(OAuth20Setup);

        OpenServiceConnectionSetup(ServiceConnectionSetupLbl);

        Assert.ExpectedMessage(OAuth20Setup."Service URL", LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ElecVATSubmissionFeatureNotInServiceConnectionsWhenElecVATSetupDoesNotExist()
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 422655] Service Connection list does not contain the "Elec. VAT Submission" feature when "Elec. VAT Setup" does not exist
        Initialize();

        ElecVATSetup.DeleteAll();
        LibraryElecVATSubmission.GetOAuthSetup(OAuth20Setup);
        VerifyServiceConnectionDoesNotExist(ServiceConnectionSetupLbl);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Elec. VAT Submission Misc.");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission Misc.");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission Misc.");
    end;

    local procedure OpenServiceConnectionSetup(NameFilter: Text)
    var
        ServiceConnectionsPage: TestPage "Service Connections";
    begin
        ServiceConnectionsPage.OpenEdit();
        ServiceConnectionsPage.Filter.SetFilter(Name, NameFilter);
        ServiceConnectionsPage.Name.AssertEquals(NameFilter);
        ServiceConnectionsPage.Setup.Invoke();
        ServiceConnectionsPage.Close();
    end;

    local procedure VerifyServiceConnectionDoesNotExist(NameFilter: Text)
    var
        ServiceConnectionsPage: TestPage "Service Connections";
    begin
        ServiceConnectionsPage.OpenEdit();
        ServiceConnectionsPage.Filter.SetFilter(Name, NameFilter);
        ServiceConnectionsPage.Name.AssertEquals('');
        ServiceConnectionsPage.Close();
    end;

    [ModalPageHandler]
    procedure OAuth20Setup_MPH(var OAuth20SetupPage: TestPage "OAuth 2.0 Setup")
    begin
        LibraryVariableStorage.Enqueue(OAuth20SetupPage."Service URL".Value());
        OAuth20SetupPage.OK().Invoke();
    end;

}