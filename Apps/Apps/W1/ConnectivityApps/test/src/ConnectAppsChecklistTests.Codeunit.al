// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139533 "Connect. Apps Checklist Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        IsInitialized: Boolean;


    [Test]
    [Scope('OnPrem')]
    procedure TestChecklistInitializationForEval()
    var
        CompanyInformation: Record "Company Information";
        GuidedExperienceTestLibrary: Codeunit "Guided Experience Test Library";
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        ChecklistSetupTestLibrary: Codeunit "Checklist Setup Test Library";
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
        CompanyTriggers: Codeunit "Company Triggers";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
    begin
        // [GIVEN] The client type is set to Web
        TestClientTypeSubscriber.SetClientType(ClientType::Web);

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        LibraryLowerPermissions.SetOutsideO365Scope();

        // [GIVEN] Banking Apps Exist
        LoadTestData();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Calling OnCompanyOpen
        CompanyTriggers.OnCompanyOpen();
        Commit(); // Need to commit before calling isolated event OnCompanyOpenCompleted
        CompanyTriggers.OnCompanyOpenCompleted();

        // [THEN] The checklist item table should contain the correct number of entries
        Assert.AreEqual(17, ChecklistTestLibrary.GetCount(), 'The Checklist Item table contains the wrong number of entries.');

        // [THEN] Verify that the checklist items were created for the right objects
        VerifyBusinessManagerEvalChecklistItems();
    end;

    local procedure SetEvaluationPropertyForCompany(IsEvaluationCompany: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());

        Company."Evaluation Company" := IsEvaluationCompany;
        Company.Modify();
    end;

    local procedure VerifyBusinessManagerEvalChecklistItems()
    var
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        GuidedExperienceType: Enum "Guided Experience Type";
        BusinessManagerEvalProfileID: Code[30];
    begin
        BusinessManagerEvalProfileID := 'Business Manager Evaluation';

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Application Feature", ObjectType::Page, Page::"Banking Apps", BusinessManagerEvalProfileID), 'The checklist item for Banking Apps was not created.');
    end;

    local procedure LoadTestData()
    var
        ConnectivityAppsTests: Codeunit "Connectivity Apps Tests";
    begin
        if IsInitialized then
            exit;

        ConnectivityAppsTests.SetupTestData();
        IsInitialized := true;
    end;
}