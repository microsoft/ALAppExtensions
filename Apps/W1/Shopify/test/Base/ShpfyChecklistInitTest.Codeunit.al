codeunit 135620 "Shpfy Checklist Init. Test"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibrarySignupContext: Codeunit "Library - Signup Context";
        TakeTheNextStepLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198403', Locked = true;
        BusinessCentralLovesShopifyVideoLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2198401', Locked = true;
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

        LibraryLowerPermissions.SetOutsideO365Scope();

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        // Given the signup context is Shopify
        MockShopifySignupContext();

        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // [THEN] The checklist setup should be marked as done
        Assert.IsTrue(ChecklistSetupTestLibrary.IsChecklistSetupDone(),
            'The checklist setup should be done.');

        // [THEN] The guided experience item table should be populated
        Assert.AreNotEqual(0, GuidedExperienceTestLibrary.GetCount(),
            'The Guided Experience Item table should no longer be empty.');

        // [THEN] The checklist item table should contain the correct number of entries
        Assert.AreEqual(3, ChecklistTestLibrary.GetCount(),
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

        LibraryLowerPermissions.SetOutsideO365Scope();

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        // Given the signup context is Shopify
        MockShopifySignupContext();

        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // [THEN] The checklist setup should be marked as done
        Assert.IsTrue(ChecklistSetupTestLibrary.IsChecklistSetupDone(),
            'The checklist setup should be done.');

        // [THEN] The guided experience item table should be populated
        Assert.AreNotEqual(0, GuidedExperienceTestLibrary.GetCount(),
            'The Guided Experience Item table should no longer be empty.');

        // [THEN] The checklist item table should contain the correct number of entries
        Assert.AreEqual(3, ChecklistTestLibrary.GetCount(),
            'The Checklist Item table contains the wrong number of entries.');

        // [THEN] Verify that the checklist items were created for the right objects
        VerifyBusinessManagerEvalChecklistItems();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSignupContextChecklistInitialization()
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

        LibraryLowerPermissions.SetOutsideO365Scope();

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetupTestLibrary.DeleteAll();

        // [GIVEN] The Guided Experience Item and Checklist Item tables are empty
        GuidedExperienceTestLibrary.DeleteAll();
        ChecklistTestLibrary.DeleteAll();

        // [GIVEN] The Signup Context is an unknown value to BaseApp
        LibrarySignupContext.SetTestValueSignupContext();

        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] Calling OnCompanyOpen
        TriggerOnCompanyOpen();

        // [THEN] The checklist setup should be marked as done
        Assert.IsFalse(ChecklistSetupTestLibrary.IsChecklistSetupDone(),
            'The checklist setup should not be completed as this is not a context known to us.');

        // [THEN] The guided experience item table should be empty
        Assert.AreEqual(0, GuidedExperienceTestLibrary.GetCount(),
            'The Guided Experience Item table should be empty when an unknown context is provided.');
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

        //Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Assisted Setup",
        //    ObjectType::Page, Page::"Shpfy Connector Wizard", BusinessManagerProfileID),
        //    'The checklist item for the Assisted Company Setup Wizard was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Assisted Setup",
            ObjectType::Page, Page::"Company Details", BusinessManagerProfileID),
            'The checklist item for the Azure AD User Update Wizard was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Learn,
            TakeTheNextStepLinkTxt, BusinessManagerProfileID),
            'The checklist item for the Users page was not created.');
    end;

    local procedure VerifyBusinessManagerEvalChecklistItems()
    var
        ChecklistTestLibrary: Codeunit "Checklist Test Library";
        GuidedExperienceType: Enum "Guided Experience Type";
        BusinessManagerEvalProfileID: Code[30];
    begin
        BusinessManagerEvalProfileID := 'Business Manager Evaluation';

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Video,
            BusinessCentralLovesShopifyVideoLinkTxt, BusinessManagerEvalProfileID),
            'The checklist item for the Business Manager Role Center was not created.');

        //Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Assisted Setup",
        //    ObjectType::Page, Page::"Shpfy Connector Wizard", BusinessManagerEvalProfileID),
        //    'The checklist item for the Assisted Company Setup Wizard was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::Learn,
            ReadyToGoLinkTxt, BusinessManagerEvalProfileID),
            'The checklist item for the Azure AD User Update Wizard was not created.');

        Assert.IsTrue(ChecklistTestLibrary.ChecklistItemExists(GuidedExperienceType::"Application Feature",
            ObjectType::Codeunit, Codeunit::"Start Trial", BusinessManagerEvalProfileID),
            'The checklist item for the Users page was not created.');
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
#if not CLEAN20
#pragma warning disable AL0432        
#endif
        CompanyTriggers.OnCompanyOpen();
#if not CLEAN20
#pragma warning restore AL0432        
#endif
        Commit(); // Need to commit before calling isolated event OnCompanyOpenCompleted
        CompanyTriggers.OnCompanyOpenCompleted();
    end;

    local procedure MockShopifySignupContext()
    begin
        LibrarySignupContext.SetSignupContext('name', 'shopify');
        LibrarySignupContext.SetSignupContext('shop', 'https://shop.url');
    end;
}