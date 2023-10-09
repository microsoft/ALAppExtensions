codeunit 139580 "Shpfy Checklist Init. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySignupContext: Codeunit "Library - Signup Context";
        LearnBusinessCentralLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198400', Locked = true;
        ReadyToGoLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198402', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestChecklistInitializationForNonEval()
    var
        GuidedExperienceTestLibrary: Codeunit "Guided Experience Test Library";
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        ChecklistSetupTestLibrary: Codeunit "Checklist Setup Test Library";
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
    begin
        LibrarySignupContext.DeleteSignupContext();
        LibrarySignupContext.SetDisableSystemUserCheck();

        // [GIVEN] The client type is set to Web
        TestClientTypeSubscriber.SetClientType(ClientType::Web);

        // [GIVEN] The company type is non-evaluation
        SetEvaluationPropertyForCompany(false);

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        // Given the signup context is Shopify
        MockShopifySignupContext();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // [THEN] The checklist setup should be marked as done
        Assert.IsTrue(ChecklistSetupTestLibrary.IsChecklistSetupDone(),
            'The checklist setup should be done.');

        // [THEN] The guided experience item table should be populated
        Assert.AreNotEqual(0, GuidedExperienceTestLibrary.GetCount(),
            'The Guided Experience Item table should no longer be empty.');

        // [THEN] The checklist item table should contain the correct number of entries
        Assert.AreEqual(5, ChecklistTestLibrary.GetCount(),
            'The Checklist Item table contains the wrong number of entries.');

        // [THEN] Verify that the checklist items were created for the right objects
        VerifyBusinessManagerChecklistItems();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestChecklistInitializationForEval()
    var
        GuidedExperienceTestLibrary: Codeunit "Guided Experience Test Library";
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        ChecklistSetupTestLibrary: Codeunit "Checklist Setup Test Library";
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
    begin
        LibrarySignupContext.DeleteSignupContext();
        LibrarySignupContext.SetDisableSystemUserCheck();

        // [GIVEN] The client type is set to Web
        TestClientTypeSubscriber.SetClientType(ClientType::Web);

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        // Given the signup context is Shopify
        MockShopifySignupContext();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // [THEN] The checklist setup should be marked as done
        Assert.IsTrue(ChecklistSetupTestLibrary.IsChecklistSetupDone(),
            'The checklist setup should be done.');

        // [THEN] The guided experience item table should be populated
        Assert.AreNotEqual(0, GuidedExperienceTestLibrary.GetCount(),
            'The Guided Experience Item table should no longer be empty.');

        // [THEN] The checklist item table should contain the correct number of entries
        Assert.AreEqual(4, ChecklistTestLibrary.GetCount(),
            'The Checklist Item table contains the wrong number of entries.');

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

    local procedure VerifyBusinessManagerChecklistItems()
    var
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        GuidedExperienceType: Enum "Guided Experience Type";
        BusinessManagerProfileID: Code[30];
    begin
        BusinessManagerProfileID := GetProfileID(Page::"Business Manager Role Center");

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Tour,
            ObjectType::Page, Page::"Business Manager Role Center", BusinessManagerProfileID),
            'The checklist item for the Business Manager Role Center was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Assisted Setup",
           ObjectType::Page, Page::"Shpfy Connector Guide", BusinessManagerProfileID),
           'The checklist item for the Shpfy Connector Guide was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Application Feature",
            ObjectType::Codeunit, Codeunit::"Company Details Checklist Item", BusinessManagerProfileID),
            'The checklist item for Company Details was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Learn,
                    LearnBusinessCentralLinkTxt, BusinessManagerProfileID),
                    'The checklist item for Learn page was not created.');
    end;

    local procedure VerifyBusinessManagerEvalChecklistItems()
    var
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        GuidedExperienceType: Enum "Guided Experience Type";
        BusinessManagerEvalProfileID: Code[30];
    begin
        BusinessManagerEvalProfileID := 'BUSINESS MANAGER EVALUATION';

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Assisted Setup",
           ObjectType::Page, Page::"Shpfy Connector Guide", BusinessManagerEvalProfileID),
           'The checklist item for the Shpfy Connector Guide was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Application Feature",
            ObjectType::Codeunit, Codeunit::"Shpfy Checklist Item List", BusinessManagerEvalProfileID),
            'The checklist item for Item List page was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Learn,
           ReadyToGoLinkTxt, BusinessManagerEvalProfileID),
            'The checklist item for Ready To Go page was not created.');
    end;

    local procedure GetProfileID(RoleCenterID: Integer): Code[30]
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Role Center ID", RoleCenterID);
        if AllProfile.FindFirst() then
            exit(AllProfile."Profile ID");
    end;

    local procedure TriggerOnCompanyOpen()
    var
        CompanyTriggers: Codeunit "Company Triggers";
    begin
        // [WHEN] Calling OnCompanyOpen
        CompanyTriggers.OnCompanyOpen();
        Commit(); // Need to commit before calling isolated event OnCompanyOpenCompleted
        CompanyTriggers.OnCompanyOpenCompleted();
    end;

    local procedure MockShopifySignupContext()
    begin
        LibrarySignupContext.SetSignupContext('name', 'shopify');
        LibrarySignupContext.SetSignupContext('shop', 'testshop.myshopify.com');
    end;
}