namespace Microsoft.EServices.EDocumentConnector.Continia;
using Microsoft.EServices.EDocumentConnector.Continia;
using Microsoft.eServices.EDocument;
using System.TestLibraries.Environment;
using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Foundation.Company;
codeunit 148204 "Registration Integration Tests"
{
    Subtype = Test;

    /// <summary>
    /// Scenario: This test verifies the complete advanced registration flow in the e-Document service.
    /// It ensures that the onboarding wizard navigates through all steps, validates mandatory fields,
    /// handles invalid credentials, and successfully registers a new participation with various document types.
    /// Additionally, it checks for the correct handling of external errors such as duplicate registrations in
    /// the Peppol network.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure Registration_AdvancedFlow()
    var
        EDocServicePage: TestPage "E-Document Service";
        OnboardingWizard: TestPage "Onboarding Wizard";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
        ParticipationAlreadyRegisteredPeppolErr: Label 'There is already a registration in Peppol network with the identifier type';
        EDocServiceMustBeAssignedErr: Label 'You must assign an E-Document Service Code to each selected network profile in the Advanced Setup';
    begin
        Initialize();

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();

        // [Then] Validate No Of Participations is 0
        Assert.AreEqual('0', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] Click on Register New Participation and on CDN Onboarding Click Next
        OnboardingWizard.Trap();
        ExtConnectionSetup.RegisterNewParticipation.Invoke();
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] not set credentials and try click Next
        asserterror OnboardingWizard.ActionNext.Invoke();
        Assert.ExpectedError('Partner credentials for Continia PartnerZone are invalid or missing.');

        // [When] set Credential Click Next and expect Credentials are not correct
        OnboardingWizard.PartnerUserName.SetValue('PartnerUserName@contoso.com');
        OnboardingWizard.PartnerPassword.SetValue('PartnerPassword');
        ApiUrlMockSubscribers.SetCoApiCaseUrlSegment('200-incorrect');
        asserterror OnboardingWizard.ActionNext.Invoke();

        // [Then] check the error exists
        Assert.ExpectedError('Partner credentials for Continia PartnerZone are invalid or missing.');

        // [When] Click Next and expect Credentials are correct
        ApiUrlMockSubscribers.SetCoApiWith200ResponseCodeCase();
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingWizard."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreEqual(CompanyInformation.Name, OnboardingWizard."Company Name".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."VAT Registration No.", OnboardingWizard."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation.Address, OnboardingWizard.Address.Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."Post Code", OnboardingWizard."Post Code".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."Country/Region Code", OnboardingWizard."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingWizard."Signatory Name".SetValue('Signatory Name');
        OnboardingWizard."Signatory Email".SetValue('signatory@email.address');
        OnboardingWizard.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Company contact information step opens and Next is disabled
        Assert.AreEqual(false, OnboardingWizard."Company Name".Visible(), 'Legal company information should not be visible');
        Assert.AreEqual(true, OnboardingWizard.CompanyContactName.Visible(), 'Company company information should be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingWizard.CompanyContactName.SetValue('Company Contact Name');
        OnboardingWizard.CompanyContactVAT.SetValue('123456789');
        OnboardingWizard.CompanyContactAddress.SetValue('CompanyContact Address');
        OnboardingWizard.CompanyContactPostCode.SetValue('111222');
        OnboardingWizard.CompanyContactCounty.SetValue('Company Contact County');
        OnboardingWizard.CompanyContactCountryRegion.SetValue(CompanyInformation."Country/Region Code");
        OnboardingWizard.CompanyContactPersonName.SetValue('Contact Name');
        OnboardingWizard.CompanyContactPersonEmail.SetValue('contact@email.address');
        OnboardingWizard.CompanyContactPersonPhoneNo.SetValue('999888777');

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Participation Network registration details step opens
        Assert.AreEqual(false, OnboardingWizard.CompanyContactName.Visible(), 'Company company information should not be visible');
        Assert.AreEqual(true, OnboardingWizard.Network.Visible(), 'Participation Network registration details should be visible');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Document Types selection step opens
        Assert.AreEqual(false, OnboardingWizard.Network.Visible(), 'Participation Network registration details should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SendInvoiceCreditMemo.Visible(), 'Document Types selection should be visible');

        // [When] Select Document Types and Expect Participation registered externally and click Next
        OnboardingWizard.SendInvoiceCreditMemo.SetValue(true);
        OnboardingWizard.ReceiveInvoiceResponse.SetValue(true);
        OnboardingWizard.ReceiveOrder.SetValue(true);
        OnboardingWizard.SendOrderResponse.SetValue(true);
        OnboardingWizard.ReceiveInvoiceCreditMemo.SetValue(true);
        OnboardingWizard.SendInvoiceResponse.SetValue(true);
        OnboardingWizard.SendOrder.SetValue(true);
        OnboardingWizard.ReceiveOrderResponse.SetValue(true);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-external');
        asserterror OnboardingWizard.ActionNext.Invoke();

        // [Then] check the error thrown
        Assert.ExpectedError(ParticipationAlreadyRegisteredPeppolErr);

        // [When] click Advanced Setup
        OnboardingWizard.ActionAdvancedSetup.Invoke();
        Commit();

        // [Then] Advanced Setup step opens
        Assert.AreEqual(false, OnboardingWizard.SendInvoiceCreditMemo.Visible(), 'Document Types selection should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] assign E-Document Service Code on each record
        OnboardingWizard.SelectProfilesPeppol.First();
        repeat
            if OnboardingWizard.SelectProfilesPeppol."Profile Name".Value <> '' then
                OnboardingWizard.SelectProfilesPeppol."E-Document Service Code".SetValue(EDocumentService.Code);
        until not OnboardingWizard.SelectProfilesPeppol.Next();

        // [When] Participation registered externally and click Next
        asserterror OnboardingWizard.ActionNext.Invoke();

        // [Then] check the error thrown
        Assert.ExpectedError(ParticipationAlreadyRegisteredPeppolErr);

        // [When] Participation is not registered externally and click Next
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();
        OnboardingWizard.ActionNext.Invoke();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingWizard.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        OnboardingWizard.ActionFinish.Invoke();
        Commit();

        // [Then] Participation is created in pending state
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Participations.First();
        Assert.AreEqual(Format(ConnectorLibrary.ParticipationId(true)).ToLower(), Participations.Id.Value, IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"Registration Status"::InProcess), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [Then] Activated network profiles created
        ValidateActivatedNetworkProfiles();

        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test confirms the correct process for unregistering a connected participation.
    /// It starts with a configured, connected participation and verifies the status change to "Disabled"
    /// upon successful unregistration, ensuring that the process is completed without errors.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure Unregister_Connected()
    var
        Participation: Record Participation;
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
    begin
        Initialize();

        // [Given] Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-connected');

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Unregister
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('202'); // Response code 202 means it was disabled
        Participations.DeleteParticipation.Invoke();

        // [Then] Participation status is Disabled
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Disabled), Participations.RegistrationStatus.Value, IncorrectValueErr);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test case validates the behavior of unregistering a participation with the status "InProcess."
    /// The test confirms that the participation is properly deleted upon completion of the unregistering action,
    /// verifying that no residual records are left in the system.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure Unregister_InProcess()
    var
        Participation: Record Participation;
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
    begin
        Initialize();

        // [Given] Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-inprocess');

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with InProcess participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::InProcess), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Unregister
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200'); // Response code 200 means it was deleted
        Participations.DeleteParticipation.Invoke();

        // [Then] Participation must be deleted
        Assert.AreEqual(false, Participations.First(), 'Participation must not be found');

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test evaluates the process of editing an existing participation to modify its profile direction.
    /// It ensures that changes are successfully applied and that the onboarding wizard navigates through the necessary steps,
    /// ending with a status verification of the updated profile direction.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure EditParticipation_ChangeProfileDirection()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
        OnboardingWizard: TestPage "Onboarding Wizard";
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-connected');

        // [Given] Configured Client Credentials
        ConnectorLibrary.InitiateClientCredentials();

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingWizard.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingWizard."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingWizard."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingWizard.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingWizard.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Set participation profile direction to Outgoing and click Next 
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-outgoing');
        OnboardingWizard.SelectProfilesPeppol.First();
        OnboardingWizard.SelectProfilesPeppol."Profile Direction".SetValue(Enum::"Profile Direction"::Outbound);
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingWizard.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        OnboardingWizard.ActionFinish.Invoke();
        Commit();

        // [Then] Profile Direction is Outgoing
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(Enum::"Profile Direction"::Outbound, ActivatedNetProf."Profile Direction", IncorrectValueErr);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test checks the functionality of adding an additional network profile to an existing participation.
    /// It confirms that the onboarding wizard proceeds through each step and that the newly added profile is correctly
    /// registered in the system, verifying that both activated and required profiles are present after completion.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    [HandlerFunctions('HandlePeppolInvoiceProfileSelection')]
    procedure EditParticipation_AddProfile()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
        OnboardingWizard: TestPage "Onboarding Wizard";
        NetworkProfileIds: List of [Guid];
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-connected');

        // [Given] Configured Client Credentials
        ConnectorLibrary.InitiateClientCredentials();

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingWizard.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingWizard."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingWizard."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingWizard.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingWizard.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Add participation profile and click Next 
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();
        OnboardingWizard.SelectProfilesPeppol.New();
        OnboardingWizard.SelectProfilesPeppol."Profile Name".Lookup();
        // HandlePeppolInvoiceProfileSelection()
        OnboardingWizard.SelectProfilesPeppol."Profile Direction".SetValue(Enum::"Profile Direction"::Both);
        OnboardingWizard.SelectProfilesPeppol."E-Document Service Code".SetValue(EDocumentService.Code);
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingWizard.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        OnboardingWizard.ActionFinish.Invoke();
        Commit();

        // [Then] Make sure all needed activated profiles exist
        NetworkProfileIds.Add(ConnectorLibrary.DefaultNetworkProfileId(true));
        NetworkProfileIds.Add(ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(true));
        TestActivatedNetworkProfiles(Participation, NetworkProfileIds, false);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test verifies the process of removing a network profile from a participation.
    /// It checks that the onboarding wizard accurately reflects the deletion of the profile and that remaining
    /// active and required profiles are correctly identified, with no errors upon completion.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure EditParticipation_RemoveProfile()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
        OnboardingWizard: TestPage "Onboarding Wizard";
        NetworkProfileIds: List of [Guid];
    begin
        Initialize();

        // [Given] Connected Participation with 2 network profiles
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ConnectorLibrary.AddActivatedNetworkProfile(Participation, ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(), CreateGuid(), ActivatedNetProf, EDocumentService.Code);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-connected');

        // [Given] Configured Client Credentials
        ConnectorLibrary.InitiateClientCredentials();

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingWizard.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingWizard."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingWizard."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingWizard.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingWizard.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Delete invoice participation profile and click Next 
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase();
        ConnectorLibrary.GetActivatedNetworkProfile(ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(), ActivatedNetProf);
        OnboardingWizard.SelectProfilesPeppol.GoToRecord(ActivatedNetProf);
        OnboardingWizard.SelectProfilesPeppol.DeleteProfile.Invoke();
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingWizard.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        OnboardingWizard.ActionFinish.Invoke();
        Commit();

        // [Then] Make sure activated and disabled profiles exist
        NetworkProfileIds.Add(ConnectorLibrary.DefaultNetworkProfileId(true));
        TestActivatedNetworkProfiles(Participation, NetworkProfileIds, false);
        Clear(NetworkProfileIds);
        NetworkProfileIds.Add(ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(true));
        TestActivatedNetworkProfiles(Participation, NetworkProfileIds, true);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test assesses the process of updating the VAT number for a registered participation.
    /// It verifies that the VAT change triggers the correct flow through the onboarding wizard and that the
    /// participation status is accurately updated to "In Process." Additionally, it checks for error handling
    /// when a participation is suspended.
    /// Test needs MockService running to work. 
    /// </summary>
    [Test]
    procedure EditParticipation_ChangeVat()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Ext. Connection Setup";
        Participations: TestPage Participations;
        OnboardingWizard: TestPage "Onboarding Wizard";
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-connected');

        // [Given] Configured Client Credentials
        ConnectorLibrary.InitiateClientCredentials();

        // [Given] Team Member + 'E-Doc. Core - Edit' permissions
        LibraryPermission.SetTeamMember();
        LibraryPermission.AddPermissionSet('E-Doc. Core - Edit');

        // [When] Open eDocument Service
        EDocServicePage.OpenView();
        EDocServicePage.GoToRecord(EDocumentService);

        // [When] Open Setup Service Integration
        ExtConnectionSetup.Trap();
        EDocServicePage.SetupServiceIntegration.Invoke();
        Commit();

        // [Then] Validate No Of Participations is 1
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);

        // [When] DrillDown on No of Participations
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingWizard.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingWizard."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingWizard."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingWizard."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next should be disabled');

        // [When] Change VAT number and Accept License terms
        ApiUrlMockSubscribers.SetCdnApiCaseUrlSegment('200-suspended');
        OnboardingWizard."VAT Registration No.".SetValue('111222334');
        OnboardingWizard.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingWizard.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingWizard.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] click Next
        OnboardingWizard.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingWizard.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingWizard.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingWizard.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        OnboardingWizard.ActionFinish.Invoke();
        Commit();

        // [Then] Participation registration status is In Process
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(Enum::"Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);

        // [When] Participations Page close and open again
        Participations.Close();
        asserterror ExtConnectionSetup.NoOfParticipations.Drilldown();

        // [Then] Error appears, since Participation is not found
        Assert.ExpectedError(Response404ErrorMessageLbl);

        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    local procedure TestActivatedNetworkProfiles(Participation: Record Participation; NetworkProfileIds: List of [Guid]; Disabled: Boolean)
    var
        ActivatedNetProf: Record "Activated Net. Prof.";
        UnexpectedProfileFoundErr: Label 'Unexpected Activated Network Profile %1 was found', Comment = '%1 - Network Profile Id';
    begin
        ActivatedNetProf.SetRange(Network, Participation.Network);
        ActivatedNetProf.SetRange("Identifier Type Id", Participation."Identifier Type Id");
        ActivatedNetProf.SetRange("Identifier Value", Participation."Identifier Value");
        if Disabled then
            ActivatedNetProf.SetFilter(Disabled, '<>%1', 0DT)
        else
            ActivatedNetProf.SetRange(Disabled, 0DT);
        Assert.AreEqual(NetworkProfileIds.Count, ActivatedNetProf.Count, IncorrectValueErr);
        if ActivatedNetProf.IsEmpty then
            exit;
        ActivatedNetProf.FindSet();
        repeat
            Assert.AreEqual(true, NetworkProfileIds.Contains(ActivatedNetProf."Network Profile Id"), StrSubstNo(UnexpectedProfileFoundErr, ActivatedNetProf."Network Profile Id"));
        until ActivatedNetProf.Next() = 0;
    end;

    [ModalPageHandler]
    internal procedure HandlePeppolInvoiceProfileSelection(var NetworkProfileList: TestPage "Network Profile List")
    var
        NetworkProfile: Record "Network Profile";
    begin
        NetworkProfile.Get(ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice());
        NetworkProfileList.GoToRecord(NetworkProfile);
        NetworkProfileList.OK().Invoke();
    end;

    local procedure Initialize()
    begin
        LibraryPermission.SetOutsideO365Scope();

        ConnectorLibrary.ClearClientCredentials();
        ConnectorLibrary.CleanParticipations();

        ApiUrlMockSubscribers.SetCoApiWith200ResponseCodeCase(ConnectorLibrary.ApiMockBaseUrl());
        ApiUrlMockSubscribers.SetCdnApiWith200ResponseCodeCase(ConnectorLibrary.ApiMockBaseUrl());

        if IsInitialized then
            exit;
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        ConnectorLibrary.EnableConnectorHttpTraffic();

        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Continia);

        CompanyInformation.Get();

        BindSubscription(ApiUrlMockSubscribers);

        IsInitialized := true;
    end;

    local procedure ValidateActivatedNetworkProfiles()
    var
        Participation: Record Participation;
        ActivatedNetProf: Record "Activated Net. Prof.";
        NetworkProfile: Record "Network Profile";
    begin
        Participation.FindFirst();
        ActivatedNetProf.FindSet();
        repeat
            Assert.AreEqual(Participation.Network, ActivatedNetProf.Network, 'Activated Network Profile Network field value is incorrect');
            Assert.AreEqual(Participation."Identifier Type Id", ActivatedNetProf."Identifier Type Id", 'Activated Network Profile "Identifier Type Id" field value is incorrect');
            Assert.AreEqual(Participation."Identifier Value", ActivatedNetProf."Identifier Value", 'Activated Network Profile "Identifier Value" field value is incorrect');
            Assert.AreEqual(Enum::"Profile Direction"::Both, ActivatedNetProf."Profile Direction", 'Activated Network Profile "Profile Direction" field value is incorrect');
            ActivatedNetProf.TestField(Created);
            ActivatedNetProf.TestField(Updated);
            NetworkProfile.Get(ActivatedNetProf."Network Profile Id");
        until ActivatedNetProf.Next() = 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        ApiUrlMockSubscribers: Codeunit "Api Url Mock Subscribers";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        ConnectorLibrary: Codeunit "Connector Library";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        Response404ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Found - Not Found';
}