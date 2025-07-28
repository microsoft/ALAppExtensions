namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using System.TestLibraries.Environment;
using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.Foundation.Company;

codeunit 148204 "Continia Reg. Integr. Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestHttpRequestPolicy = AllowOutboundFromHandler;
    Access = Internal;

    /// <summary>
    /// Scenario: This test verifies the complete advanced registration flow in the e-Document service.
    /// It ensures that the onboarding wizard navigates through all steps, validates mandatory fields,
    /// handles invalid credentials, and successfully registers a new participation with various document types.
    /// Additionally, it checks for the correct handling of external errors such as duplicate registrations in
    /// the Peppol network.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure Registration_AdvancedFlow()
    var
        EDocServicePage: TestPage "E-Document Service";
        OnboardingGuide: TestPage "Continia Onboarding Guide";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
        ParticipationAlreadyRegisteredPeppolErr: Label 'There is already a registration in Peppol network with the identifier type';
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
        OnboardingGuide.Trap();
        ExtConnectionSetup.RegisterNewParticipation.Invoke();
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] not set credentials and try click Next
        asserterror OnboardingGuide.ActionNext.Invoke();
        Assert.ExpectedError('Partner credentials for Continia PartnerZone are invalid or missing.');

        // [When] set Credential Click Next and expect Credentials are not correct
        OnboardingGuide.PartnerUserName.SetValue('PartnerUserName@contoso.com');
        OnboardingGuide.PartnerPassword.SetValue('PartnerPassword');
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.PartnerAccessTokenUrl(),
            200,
            GetMockResponseContent('PartnerZoneLogin200Incorrect.txt')
        );
        asserterror OnboardingGuide.ActionNext.Invoke();

        // [Then] check the error exists
        Assert.ExpectedError('Partner credentials for Continia PartnerZone are invalid or missing.');

        // [When] Click Next and expect Credentials are correct
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.PartnerAccessTokenUrl(),
            200,
            GetMockResponseContent('PartnerZoneLogin200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.ClientEnvironmentInitializeUrl(),
            200,
            GetMockResponseContent('InitializeClient200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.PartnerZoneUrl(),
            200,
            GetMockResponseContent('PartnerZoneConnect200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.NetworkIdentifiersUrl(Enum::"Continia E-Delivery Network"::Peppol, 1, 100),
            200,
            GetMockResponseContent('PeppolNetworkIdTypes200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.NetworkIdentifiersUrl(Enum::"Continia E-Delivery Network"::Nemhandel, 1, 100),
            200,
            GetMockResponseContent('NemhandelNetworkIdTypes200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.NetworkProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, 1, 100),
            200,
            GetMockResponseContent('PeppolNetworkProfiles200.txt')
        );
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.NetworkProfilesUrl(Enum::"Continia E-Delivery Network"::Nemhandel, 1, 100),
            200,
            GetMockResponseContent('NemhandelNetworkProfiles200.txt')
        );

        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingGuide."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreEqual(CompanyInformation.Name, OnboardingGuide."Company Name".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."VAT Registration No.", OnboardingGuide."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation.Address, OnboardingGuide.Address.Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."Post Code", OnboardingGuide."Post Code".Value, IncorrectValueErr);
        Assert.AreEqual(CompanyInformation."Country/Region Code", OnboardingGuide."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingGuide."Signatory Name".SetValue('Signatory Name');
        OnboardingGuide."Signatory Email".SetValue('signatory@email.address');
        OnboardingGuide.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Company contact information step opens and Next is disabled
        Assert.AreEqual(false, OnboardingGuide."Company Name".Visible(), 'Legal company information should not be visible');
        Assert.AreEqual(true, OnboardingGuide.CompanyContactName.Visible(), 'Company company information should be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingGuide.CompanyContactName.SetValue('Company Contact Name');
        OnboardingGuide.CompanyContactVAT.SetValue('123456789');
        OnboardingGuide.CompanyContactAddress.SetValue('CompanyContact Address');
        OnboardingGuide.CompanyContactPostCode.SetValue('111222');
        OnboardingGuide.CompanyContactCounty.SetValue('Company Contact County');
        OnboardingGuide.CompanyContactCountryRegion.SetValue(CompanyInformation."Country/Region Code");
        OnboardingGuide.CompanyContactPersonName.SetValue('Contact Name');
        OnboardingGuide.CompanyContactPersonEmail.SetValue('contact@email.address');
        OnboardingGuide.CompanyContactPersonPhoneNo.SetValue('999888777');

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Participation Network registration details step opens
        Assert.AreEqual(false, OnboardingGuide.CompanyContactName.Visible(), 'Company company information should not be visible');
        Assert.AreEqual(true, OnboardingGuide.Network.Visible(), 'Participation Network registration details should be visible');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Document Types selection step opens
        Assert.AreEqual(false, OnboardingGuide.Network.Visible(), 'Participation Network registration details should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SendInvoiceCreditMemo.Visible(), 'Document Types selection should be visible');

        // [When] Select Document Types and Expect Participation registered externally and click Next
        OnboardingGuide.SendInvoiceCreditMemo.SetValue(true);
        OnboardingGuide.ReceiveInvoiceResponse.SetValue(true);
        OnboardingGuide.ReceiveOrder.SetValue(true);
        OnboardingGuide.SendOrderResponse.SetValue(true);
        OnboardingGuide.ReceiveInvoiceCreditMemo.SetValue(true);
        OnboardingGuide.SendInvoiceResponse.SetValue(true);
        OnboardingGuide.SendOrder.SetValue(true);
        OnboardingGuide.ReceiveOrderResponse.SetValue(true);
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200-external.txt'));

        asserterror OnboardingGuide.ActionNext.Invoke();

        // [Then] check the error thrown
        Assert.ExpectedError(ParticipationAlreadyRegisteredPeppolErr);

        // [When] click Advanced Setup
        OnboardingGuide.ActionAdvancedSetup.Invoke();
        Commit();

        // [Then] Advanced Setup step opens
        Assert.AreEqual(false, OnboardingGuide.SendInvoiceCreditMemo.Visible(), 'Document Types selection should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] assign E-Document Service Code on each record
        OnboardingGuide.SelectProfilesPeppol.First();
        repeat
            if OnboardingGuide.SelectProfilesPeppol."Profile Name".Value <> '' then
                OnboardingGuide.SelectProfilesPeppol."E-Document Service Code".SetValue(EDocumentService.Code);
        until not OnboardingGuide.SelectProfilesPeppol.Next();

        // [When] Participation registered externally and click Next
        asserterror OnboardingGuide.ActionNext.Invoke();

        // [Then] check the error thrown
        Assert.ExpectedError(ParticipationAlreadyRegisteredPeppolErr);

        // [When] Participation is not registered externally and click Next
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200.txt'));
        OnboardingGuide.ActionNext.Invoke();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingGuide.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.UpdateSubscriptionUrl(),
            200,
            GetMockResponseContent('UpdateSubscription200.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.GetAcceptCompanyLicenseUrl(),
            200,
            GetMockResponseContent('AcceptCompanyLicense200.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.ParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol),
            200,
            GetMockResponseContent('Participation200-Draft.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, ConnectorLibrary.ParticipationId(true)),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Patch,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, ConnectorLibrary.ParticipationId(true)),
            200,
            GetMockResponseContent('Participation200-InProcess.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, ConnectorLibrary.ParticipationId(true)),
            200,
            GetMockResponseContent('Participation200-InProcess.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, ConnectorLibrary.ParticipationId(true), 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        OnboardingGuide.ActionFinish.Invoke();
        Commit();

        // [Then] Participation is created in pending state
        Assert.AreEqual('1', ExtConnectionSetup.NoOfParticipations.Value, IncorrectValueErr);
        Participations.Trap();
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Participations.First();
        Assert.AreEqual(Format(ConnectorLibrary.ParticipationId(true)).ToLower(), Participations.Id.Value, IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::InProcess), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [Then] Activated network profiles created
        ValidateActivatedNetworkProfiles();

        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test confirms the correct process for unregistering a connected participation.
    /// It starts with a configured, connected participation and verifies the status change to "Disabled"
    /// upon successful unregistration, ensuring that the process is completed without errors.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure Unregister_Connected()
    var
        Participation: Record "Continia Participation";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
    begin
        Initialize();

        // [Given] Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);
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
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
            200,
            GetMockResponseContent('Participation200-Connected.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Unregister
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Delete,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
            202);
        Participations.DeleteParticipation.Invoke();

        // [Then] Participation status is Disabled
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Disabled), Participations.RegistrationStatus.Value, IncorrectValueErr);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test case validates the behavior of unregistering a participation with the status "InProcess."
    /// The test confirms that the participation is properly deleted upon completion of the unregistering action,
    /// verifying that no residual records are left in the system.
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure Unregister_InProcess()
    var
        Participation: Record "Continia Participation";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
    begin
        Initialize();

        // [Given] Connected Participation
        ConnectorLibrary.PrepareParticipation(Participation);

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
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-InProcess.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with InProcess participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::InProcess), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Unregister
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Delete,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
            200);
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
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure EditParticipation_ChangeProfileDirection()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
        OnboardingGuide: TestPage "Continia Onboarding Guide";
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);

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
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-Connected.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingGuide.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingGuide."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingGuide."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingGuide.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingGuide.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Set participation profile direction to Outgoing and click Next 
        OnboardingGuide.SelectProfilesPeppol.First();
        OnboardingGuide.SelectProfilesPeppol."Profile Direction".SetValue(Enum::"Continia Profile Direction"::Outbound);

        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200.txt'));
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingGuide.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Patch,
            ContiniaApiUrlMgt.UpdateSubscriptionUrl(),
            200,
            GetMockResponseContent('Participation200-InProcess.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Patch,
            ContiniaApiUrlMgt.SingleParticipationProfileUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, ActivatedNetProf.Id),
            200,
            GetMockResponseContent('ParticipationProfile-outgoing.txt'));
        OnboardingGuide.ActionFinish.Invoke();
        Commit();

        // [Then] Profile Direction is Outgoing
        ConnectorLibrary.GetActivatedNetworkProfile(ActivatedNetProf);
        Assert.AreEqual(Enum::"Continia Profile Direction"::Outbound, ActivatedNetProf."Profile Direction", IncorrectValueErr);

        Participations.Close();
        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    /// <summary>
    /// Scenario: This test checks the functionality of adding an additional network profile to an existing participation.
    /// It confirms that the onboarding wizard proceeds through each step and that the newly added profile is correctly
    /// registered in the system, verifying that both activated and required profiles are present after completion.
    /// </summary>
    [Test]
    [HandlerFunctions('HandlePeppolInvoiceProfileSelection,HttpClientHandler')]
    procedure EditParticipation_AddProfile()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
        OnboardingGuide: TestPage "Continia Onboarding Guide";
        NetworkProfileIds: List of [Guid];
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);

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
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-Connected.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingGuide.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingGuide."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingGuide."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingGuide.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingGuide.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Add participation profile and click Next 
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200.txt'));
        OnboardingGuide.SelectProfilesPeppol.New();
        OnboardingGuide.SelectProfilesPeppol."Profile Name".Lookup();
        // HandlePeppolInvoiceProfileSelection()
        OnboardingGuide.SelectProfilesPeppol."Profile Direction".SetValue(Enum::"Continia Profile Direction"::Both);
        OnboardingGuide.SelectProfilesPeppol."E-Document Service Code".SetValue(EDocumentService.Code);
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingGuide.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Post,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        OnboardingGuide.ActionFinish.Invoke();
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
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure EditParticipation_RemoveProfile()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
        OnboardingGuide: TestPage "Continia Onboarding Guide";
        NetworkProfileIds: List of [Guid];
    begin
        Initialize();

        // [Given] Connected Participation with 2 network profiles
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);
        ConnectorLibrary.AddActivatedNetworkProfile(Participation, ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(), CreateGuid(), ActivatedNetProf, EDocumentService.Code);

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
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-Connected.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingGuide.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingGuide."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingGuide."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] fill mandatory information
        OnboardingGuide.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingGuide.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] Delete invoice participation profile and click Next 
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200.txt'));
        ConnectorLibrary.GetActivatedNetworkProfile(ConnectorLibrary.NetworkProfileIdPeppolBis3Invoice(), ActivatedNetProf);
        OnboardingGuide.SelectProfilesPeppol.GoToRecord(ActivatedNetProf);
        OnboardingGuide.SelectProfilesPeppol.DeleteProfile.Invoke();
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingGuide.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Delete,
            ContiniaApiUrlMgt.SingleParticipationProfileUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, ActivatedNetProf.Id),
            200);
        OnboardingGuide.ActionFinish.Invoke();
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
    /// </summary>
    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure EditParticipation_ChangeVat()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        EDocServicePage: TestPage "E-Document Service";
        ExtConnectionSetup: TestPage "Continia Ext. Connection Setup";
        Participations: TestPage "Continia Participations";
        OnboardingGuide: TestPage "Continia Onboarding Guide";
    begin
        Initialize();

        // [Given] Connected Participation with a profile
        ConnectorLibrary.PrepareParticipation(Participation, ActivatedNetProf, EDocumentService);

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
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-Connected.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            200,
            GetMockResponseContent('ParticipationProfile200-randomId.txt'));
        ExtConnectionSetup.NoOfParticipations.Drilldown();
        Commit();

        // [Then] Participations Page opens with Connected participation
        Participations.First();
        Assert.AreEqual(Format(Enum::"Continia Registration Status"::Connected), Participations.RegistrationStatus.Value, IncorrectValueErr);

        // [When] click Edit Participation
        OnboardingGuide.Trap();
        Participations.EditParticipation.Invoke();

        // [Then] Onboarding Wizard Legal company information step opens and values are filled in correctly
        Assert.AreEqual(true, OnboardingGuide."Company Name".Visible(), 'Legal company information should be visible');
        Assert.AreNotEqual('', OnboardingGuide."Company Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."VAT Registration No.".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide.Address.Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Post Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Country/Region Code".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Name".Value, IncorrectValueErr);
        Assert.AreNotEqual('', OnboardingGuide."Signatory Email".Value, IncorrectValueErr);
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next should be disabled');

        // [When] Change VAT number and Accept License terms
        OnboardingGuide."VAT Registration No.".SetValue('111222334');
        OnboardingGuide.LicenseTerms.SetValue(true);

        // [Then] Next is enabled
        Assert.AreEqual(true, OnboardingGuide.ActionNext.Enabled(), 'Next should be enabled');

        // [When] click Next
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Onboarding Wizard Advanced Setup step opens
        Assert.AreEqual(false, OnboardingGuide.PartnerUserName.Visible(), 'Partner Details should not be visible');
        Assert.AreEqual(true, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should be visible');

        // [When] click Next
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationLookupUrl(
                Enum::"Continia E-Delivery Network"::Peppol,
                CopyStr(OnboardingGuide.IdentifierTypeDesc.Value, 1, 4),
                CopyStr(OnboardingGuide.CompanyIdentifierValue.Value, 1, 50)),
            200,
            GetMockResponseContent('ParticipationLookup200.txt'));
        OnboardingGuide.ActionNext.Invoke();
        Commit();

        // [Then] Last step opens
        Assert.AreEqual(false, OnboardingGuide.SelectProfilesPeppol."Profile Name".Visible(), 'Advanced Setup should not be visible');
        Assert.AreEqual(false, OnboardingGuide.ActionNext.Enabled(), 'Next must be disabled');
        Assert.AreEqual(true, OnboardingGuide.ActionFinish.Enabled(), 'Finish must be enabled');

        // [When] click Finish
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Patch,
            ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
            200,
            GetMockResponseContent('Participation200-Suspended.txt'));
        OnboardingGuide.ActionFinish.Invoke();
        Commit();

        // [Then] Participation registration status is In Process
        ConnectorLibrary.GetParticipation(Participation);
        Assert.AreEqual(Enum::"Continia Registration Status"::InProcess, Participation."Registration Status", IncorrectValueErr);

        // [When] Participations Page close and open again
        Participations.Close();
        ContiniaMockHttpHandler.ClearHandler();
        ContiniaMockHttpHandler.AddResponse(
           HttpRequestType::Get,
           ContiniaApiUrlMgt.SingleParticipationUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id),
           200,
           GetMockResponseContent('Participation200-Suspended.txt'));
        ContiniaMockHttpHandler.AddResponse(
            HttpRequestType::Get,
            ContiniaApiUrlMgt.ParticipationProfilesUrl(Enum::"Continia E-Delivery Network"::Peppol, Participation.Id, 1, 100),
            404,
            GetMockResponseContent('Common404.txt'));
        asserterror ExtConnectionSetup.NoOfParticipations.Drilldown();

        // [Then] Error appears, since Participation is not found
        Assert.ExpectedError(Response404ErrorMessageLbl);

        ExtConnectionSetup.Close();
        EDocServicePage.Close();
    end;

    local procedure TestActivatedNetworkProfiles(Participation: Record "Continia Participation"; NetworkProfileIds: List of [Guid]; Disabled: Boolean)
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
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
    internal procedure HandlePeppolInvoiceProfileSelection(var NetworkProfileList: TestPage "Continia Network Profile List")
    var
        NetworkProfile: Record "Continia Network Profile";
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

        if IsInitialized then
            exit;
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        LibraryEDocument.SetupStandardVAT();
        LibraryEDocument.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Continia);
        CompanyInformation.Get();
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify(false);

        IsInitialized := true;
    end;

    local procedure ValidateActivatedNetworkProfiles()
    var
        Participation: Record "Continia Participation";
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        NetworkProfile: Record "Continia Network Profile";
    begin
        Participation.FindFirst();
        ActivatedNetProf.FindSet();
        repeat
            Assert.AreEqual(Participation.Network, ActivatedNetProf.Network, 'Activated Network Profile Network field value is incorrect');
            Assert.AreEqual(Participation."Identifier Type Id", ActivatedNetProf."Identifier Type Id", 'Activated Network Profile "Identifier Type Id" field value is incorrect');
            Assert.AreEqual(Participation."Identifier Value", ActivatedNetProf."Identifier Value", 'Activated Network Profile "Identifier Value" field value is incorrect');
            Assert.AreEqual(Enum::"Continia Profile Direction"::Both, ActivatedNetProf."Profile Direction", 'Activated Network Profile "Profile Direction" field value is incorrect');
            ActivatedNetProf.TestField(Created);
            ActivatedNetProf.TestField(Updated);
            NetworkProfile.Get(ActivatedNetProf."Network Profile Id");
        until ActivatedNetProf.Next() = 0;
    end;

    local procedure GetMockResponseContent(ResourceFileName: Text): Text
    begin
        exit(NavApp.GetResourceAsText(ResourceFileName, TextEncoding::UTF8));
    end;

    [HttpClientHandler]
    internal procedure HttpClientHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        if ContiniaMockHttpHandler.HandleAuthorization(Request, Response) then
            exit;

        Response := ContiniaMockHttpHandler.GetResponse(Request);
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        LibraryEDocument: Codeunit "Library - E-Document";
        LibraryPermission: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        ContiniaMockHttpHandler: Codeunit "Continia Mock Http Handler";
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        ConnectorLibrary: Codeunit "Continia Connector Library";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Wrong value';
        Response404ErrorMessageLbl: Label 'The Continia Delivery Network API returned the following error: Error Code Not Found - Not Found';
}
