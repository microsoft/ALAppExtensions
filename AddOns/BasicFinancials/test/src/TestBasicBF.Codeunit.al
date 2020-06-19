// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139502 "Test Basic BF"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        AllProfileFilterTxt: Label 'MANUFACTURING|PROJECTS|SERVICES|WAREHOUSE|SHIPPING AND RECEIVING - WMS|SHIPPING AND RECEIVING|WAREHOUSE WORKER - WMS|PRODUCTION PLANNER|PROJECT MANAGER|DISPATCHER', Locked = true, Comment = 'As default the profile "SALES AND RELATIONSHIP MANAGER" cannot disable because it is set up as a default profile for one or more users or user groups.';
        NotSupportedLicensesErr: Label 'Validation error for Field: IsSupportedLicenses,  Message = ''At least one user must have the Basic license.''', Locked = true;
        NotSupportedCompaniesErr: Label 'Validation error for Field: IsSupportedCompanies,  Message = ''Exactly one company must exists in the environment.''', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [Basic] [User Experience]
    end;

    [Test]
    procedure TestBasicExperienceTierAfterInstall();
    var
    begin
        // [Scenario] Check the Basic Experience Tier After Install of Basic Extension 
        // [Given] Application Area
        // [WHEN]

        // [THEN] Basic Experience Tier is Enabled
        TestEnabledBasicExperienceTier();
    end;

    [Test]
    procedure TestBasicApplicationAreaAfterInstall();
    var
    begin
        // [Scenario] Check the Basic Application Area After Install of Basic Extension 
        // [Given] Application Area
        // [WHEN]

        // [THEN] Basic Application Area is Enabled
        TestEnabledBasicApplicationArea();
    end;

    [Test]
    procedure TestDisableRoleCenterAfterInstall();
    var
    begin
        // [Scenario] Check disable Role Center After Install of Basic Extension 
        // [Given] Role Center
        // [WHEN]

        // [THEN] Role Center is disable
        TestDisableRoleCenter();
    end;

    [Test]
    procedure TestSetExperienceTierToEssential();
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        // [Scenario] Check that Basic Application Area are disabled, after Experience Tier is set to Essential 
        // [Given] Experience Tier

        // [WHEN] Experience Tier is saved as Essential
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup.Essential));

        // [THEN] Basic Application Area is Disabled
        TestDisabledBasicApplicationArea();
    end;

    [Test]
    procedure TestSetExperienceTierToBasicExt();
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        // [Scenario] Check that Basic Application Area are Enabled, after Experience Tier is set to BF Basic 
        // [Given] Experience Tier

        // [WHEN] Experience Tier is saved as BF Basic 
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic"));

        // [THEN] Basic Application Area is Enabled
        TestEnabledBasicApplicationArea();
    end;

    [Test]
    procedure TestOpenCloseBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario] Check that the Basic Assisted Setup Page can be Opened and Closed
        // [Given] Basic Assisted Setup Page

        // [When] The Basic Assisted Setup is opened 
        AssistedSetupBFTestPage.OpenView();

        // [Then] The Basic Assisted Setup is closed
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestAcceptConsentIsDisabledBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario] Check Accept Consent on Assisted Setup 
        // [Given] Basic Assisted Setup Page

        // [When] The Assisted Setup is opened 
        AssistedSetupBFTestPage.OpenView();

        // [Then] Accept Consent and Finish should be disabled 
        Assert.IsFalse(AssistedSetupBFTestPage.AcceptConsent.AsBoolean(), 'Accept Consent should be disabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestSupportedLicensesIsDisabledBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario] Check Supported Licenses on Assisted Setup 
        // [Given] Basic Assisted Setup Page

        // [When] The Assisted Setup is opened 
        AssistedSetupBFTestPage.OpenView();

        // [Then] Supported Licenses and Finish should be disabled
        Assert.IsFalse(AssistedSetupBFTestPage.IsSupportedLicenses.AsBoolean(), 'Is Supported Licenses should be disabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestSupportedCompaniesIsDisabledBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario] Check Supported Companies on Assisted Setup 
        // [Given] Basic Assisted Setup Page

        // [When] The Assisted Setup is opened
        AssistedSetupBFTestPage.OpenView();

        // [Then] Supported Companies and Finish should be disabled
        Assert.IsFalse(AssistedSetupBFTestPage.IsSupportedCompanies.AsBoolean(), 'Is Supported Companies should be disabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestEnableAcceptConsentBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario]
        // [Given] Basic Assisted Setup Page

        // [When] Set Accept Consent to true
        AssistedSetupBFTestPage.OpenView();
        AssistedSetupBFTestPage.AcceptConsent.SetValue(true);

        // [Then]
        Assert.IsTrue(AssistedSetupBFTestPage.AcceptConsent.AsBoolean(), 'Accept Consent should be Enabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestEnableLicensesBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
        ERRORTEXT: Text;
    begin
        // [Scenario]
        // [Given] Basic Assisted Setup Page

        // [When] Set Supported Licenses to true
        AssistedSetupBFTestPage.OpenView();
        asserterror AssistedSetupBFTestPage.IsSupportedLicenses.SetValue(true);

        // [Then] Error message displayed 
        Assert.AreEqual(GETLASTERRORTEXT, NotSupportedLicensesErr, 'Invalid error message.');
        Assert.IsFalse(AssistedSetupBFTestPage.IsSupportedLicenses.AsBoolean(), 'Is Supported Licenses should be disabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    [Test]
    procedure TestEnableSupportedCompaniesBasicAssistedSetupPage();
    var
        AssistedSetupBFTestPage: TestPage "Assisted Setup BF";
    begin
        // [Scenario]
        // [Given] Basic Assisted Setup Page

        // [When] Set Supported Companies to true
        AssistedSetupBFTestPage.OpenView();
        asserterror AssistedSetupBFTestPage.IsSupportedCompanies.SetValue(true);

        // [Then]
        Assert.AreEqual(GETLASTERRORTEXT, NotSupportedCompaniesErr, 'Invalid error message.');
        Assert.IsFalse(AssistedSetupBFTestPage.IsSupportedCompanies.AsBoolean(), 'Is Supported Companies should be disabled');
        Assert.IsFalse(AssistedSetupBFTestPage.Finish.Enabled(), 'Finish should be disabled');
        AssistedSetupBFTestPage.Close();
    end;

    internal procedure TestDisabledBasicApplicationArea();
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.Get(CompanyName, '', '');
        //>> Application Area must be false
        ApplicationAreaSetup.TestField("BF Basic", false);
        ApplicationAreaSetup.TestField("BF Orders", false);
    end;

    internal procedure TestEnabledBasicExperienceTier();
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
    begin
        ExperienceTierSetup.Get(CompanyName);
        //>> Experience Tier must be true
        ExperienceTierSetup.TestField("BF Basic", true);
    end;


    internal procedure TestEnabledBasicApplicationArea();
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        Field: Record Field;
        ApplicationAreaSetupRecordRef: RecordRef;
        ApplicationAreaSetupFieldRef: FieldRef;
        IsBasicCountryTested: Boolean;
    begin
        ApplicationAreaSetup.Get(CompanyName, '', '');
        CLEAR(ApplicationAreaSetupRecordRef);
        CLEAR(ApplicationAreaSetupFieldRef);
        ApplicationAreaSetupRecordRef.Get(ApplicationAreaSetup.RecordId);

        Field.SETRANGE(TableNo, ApplicationAreaSetupRecordRef.Number);
        Field.SETRANGE(Type, Field.Type::Boolean);
        if Field.FINDSET(FALSE, FALSE) then
            repeat
                ApplicationAreaSetupFieldRef := ApplicationAreaSetupRecordRef.FIELD(Field."No.");
                case ApplicationAreaSetupFieldRef.Name() of
                    //>> Application Area must be true
                    ApplicationAreaSetup.FieldName("BF Basic"),
                    ApplicationAreaSetup.FieldName(Basic),
                    ApplicationAreaSetup.FieldName(Suite),
                    ApplicationAreaSetup.FieldName(Jobs),
                    ApplicationAreaSetup.FieldName("Fixed Assets"),
                    ApplicationAreaSetup.FieldName(Location),
                    ApplicationAreaSetup.FieldName(BasicHR),
                    ApplicationAreaSetup.FieldName(Warehouse),
                    ApplicationAreaSetup.FieldName(Planning),
                    ApplicationAreaSetup.FieldName(Dimensions),
                    ApplicationAreaSetup.FieldName(Prepayments),
                    ApplicationAreaSetup.FieldName(XBRL),
                    ApplicationAreaSetup.FieldName(Comments),
                    ApplicationAreaSetup.FieldName("Record Links"),
                    ApplicationAreaSetup.FieldName(Notes),
                    ApplicationAreaSetup.FieldName(VAT),
                    ApplicationAreaSetup.FieldName("Basic EU"):
                        ApplicationAreaSetupFieldRef.TestField(true);

                    //>> Only one Microsoft Basic Country Application Area must be true the others must be false         
                    ApplicationAreaSetup.FieldName("Basic DK"),
                    ApplicationAreaSetup.FieldName("Basic IS"):
                        if IsBasicCountryTested then
                            ApplicationAreaSetupFieldRef.TestField(false)
                        else begin
                            ApplicationAreaSetupFieldRef.TestField(true);
                            IsBasicCountryTested := true;
                        end;

                    //>> Remainder Application Area must be false, even when new ones are added                
                    else
                        ApplicationAreaSetupFieldRef.TestField(false);
                end;
            until Field.NEXT() = 0;
    end;

    internal procedure TestDisableRoleCenter();
    var
        AllProfile: Record "All Profile";
    begin
        Clear(AllProfile);
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter("Profile ID", AllProfileFilterTxt);
        if AllProfile.FindSet(false, false) then
            repeat
                AllProfile.TestField(Enabled, false);
            until AllProfile.Next() = 0;
    end;
}