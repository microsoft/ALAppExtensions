// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.eServices.EDocument;
using System.Utilities;

codeunit 6394 "Onboarding Helper"
{
    Access = Internal;

    Permissions = tabledata "Network Profile" = rimd,
                  tabledata "Network Identifier" = rimd,
                  tabledata "Participation" = rimd,
                  tabledata "Activated Net. Prof." = rimd;
    internal procedure InitializeGeneralScenario(var TempCompanyContact: Record "Participation" temporary; var TempParticipation: Record "Participation" temporary; var ParticipationCountyVisible: Boolean; var ContactInfoCountyVisible: Boolean; var SkipCompanyInformation: Boolean; var IdentifierTypeDesc: Text)
    var
        ConnectionSetup: Record "Connection Setup";
        FormatAddress: Codeunit "Format Address";
    begin
        TempCompanyContact.Init();
        TempCompanyContact.Insert();

        ParticipationCountyVisible := FormatAddress.UseCounty(TempParticipation."Country/Region Code");
        ContactInfoCountyVisible := FormatAddress.UseCounty(TempCompanyContact."Country/Region Code");

        if AreClientCredentialsValid() then begin
            ShowProgressWindow(UpdatingDataProgressMsg);
            GetNetworkMetadata(false);
            GetContactInformation(TempCompanyContact, false);
            CloseProgressWindow();
        end;

        FillParticipationWithCompanyInfo(TempParticipation, IdentifierTypeDesc);

        if ConnectionSetup.Get() then
            if (TempCompanyContact."Company Name" <> '') and (ConnectionSetup."Subscription Status" = ConnectionSetup."Subscription Status"::Subscription) then
                SkipCompanyInformation := true;
    end;

    internal procedure GetContactInformation(var TempParticipationCompanyContact: Record "Participation" temporary; ShowProgress: Boolean)
    var
        ActivationMgt: Codeunit "Subscription Mgt.";
    begin
        if ShowProgress then
            ShowProgressWindow(UpdatingDataProgressMsg);
        ActivationMgt.GetClientInfoApp(TempParticipationCompanyContact, true);
        if ShowProgress then
            CloseProgressWindow();
    end;

    internal procedure AreClientCredentialsValid(): Boolean
    var
        CredentialManagement: Codeunit "Credential Management";
    begin
        exit(CredentialManagement.IsClientCredentialsValid());
    end;

    internal procedure InitializeClient(PartnerUserName: Text; PartnerPassword: SecretText) PartnerID: Code[20]
    var
        ActivationMgt: Codeunit "Subscription Mgt.";
    begin
        ShowProgressWindow(SendingDataProgressMsg);
        ActivationMgt.InitializeContiniaClient(PartnerUserName, PartnerPassword, PartnerID);
        AreClientCredentialsValid();
        CloseProgressWindow();
    end;

    internal procedure GetNetworkMetadata(ShowProgress: Boolean)
    var
        APIRequests: Codeunit "API Requests";
    begin
        if MetaDataLoaded then
            exit;
        if ShowProgress then
            ShowProgressWindow(UpdatingDataProgressMsg);

        APIRequests.GetNetworkIDTypes(Enum::"Network"::peppol);
        APIRequests.GetNetworkIDTypes(Enum::"Network"::nemhandel);

        APIRequests.GetNetworkProfiles(Enum::"Network"::peppol);
        APIRequests.GetNetworkProfiles(Enum::"Network"::nemhandel);

        if ShowProgress then
            CloseProgressWindow();
        MetaDataLoaded := true;
    end;

    internal procedure FillParticipationWithCompanyInfo(var TempParticipation: Record "Participation" temporary; var IdentifierTypeDesc: Text)
    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInfo.Get();
        TempParticipation.Init();
        if MetaDataLoaded then
            SetDefaultIdentifierData(TempParticipation, IdentifierTypeDesc);
        TempParticipation."Company Name" := CompanyInfo.Name;
        TempParticipation."VAT Registration No." := CompanyInfo."VAT Registration No.";
        TempParticipation.Address := CompanyInfo.Address;
        TempParticipation."Post Code" := CompanyInfo."Post Code";
        TempParticipation."Country/Region Code" := CompanyInfo."Country/Region Code";
        if CountryRegion.Get(CompanyInfo."Country/Region Code") then begin
            TempParticipation."Country/Region Code" := CountryRegion."ISO Code";
            TempParticipation.County := CompanyInfo.County;
        end;

        TempParticipation."Your Name" := 'N/A';
        TempParticipation."Contact Email" := 'N/A';
        TempParticipation."Contact Name" := 'N/A';
        TempParticipation."Contact Phone No." := 'N/A';
    end;

    internal procedure SetDefaultIdentifierData(var TempParticipation: Record "Participation" temporary; var IdentifierTypeDesc: Text)
    var
        CompanyInformation: Record "Company Information";
        NetworkIdentifier: Record "Network Identifier";
        EmptyGUID: Guid;
    begin
        CompanyInformation.Get();

        Clear(NetworkIdentifier);
        NetworkIdentifier.SetRange(Network, TempParticipation.Network);
        if TempParticipation."Country/Region Code" <> '' then
            NetworkIdentifier.SetRange("Default in Country", TempParticipation."Country/Region Code")
        else
            NetworkIdentifier.SetRange(Default, true);

        if NetworkIdentifier.FindFirst() then begin
            TempParticipation."Identifier Type ID" := NetworkIdentifier."CDN GUID";
            TempParticipation."Identifier Value" := CompanyInformation."VAT Registration No.";
            IdentifierTypeDesc := NetworkIdentifier."Scheme ID";
        end else begin
            TempParticipation."Identifier Type ID" := EmptyGUID;
            TempParticipation."Identifier Value" := '';
            IdentifierTypeDesc := '';
        end;
    end;

    internal procedure ValidateIdentifierType(var TempParticipation: Record "Participation" temporary; var IdentifierTypeDesc: Text)
    var
        NetworkIdentifier: Record "Network Identifier";
    begin
        if IdentifierTypeDesc <> '' then begin
            NetworkIdentifier.SetRange(Network, TempParticipation.Network);
            NetworkIdentifier.SetRange(Enabled, true);
            NetworkIdentifier.SetRange("Scheme ID", IdentifierTypeDesc);
            NetworkIdentifier.FindFirst();
            TempParticipation."Identifier Type ID" := NetworkIdentifier."CDN GUID";
            IdentifierTypeDesc := NetworkIdentifier."Scheme ID";
        end;
    end;

    internal procedure LookupIdentifierType(var TempParticipation: Record "Participation" temporary; var IdentifierTypeDesc: Text): Boolean
    var
        NetworkIdentifier: Record "Network Identifier";
        NetworkIdentifierList: Page "Network Id. List";
    begin
        Clear(NetworkIdentifier);
        NetworkIdentifier.SetRange(Network, TempParticipation.Network);
        NetworkIdentifier.SetRange(Enabled, true);
        NetworkIdentifierList.SetTableView(NetworkIdentifier);
        NetworkIdentifierList.LookupMode(true);

        if NetworkIdentifierList.RunModal() = Action::LookupOK then begin
            NetworkIdentifierList.GetRecord(NetworkIdentifier);
            IdentifierTypeDesc := NetworkIdentifier."Scheme ID";
            TempParticipation."Identifier Type ID" := NetworkIdentifier."CDN GUID";
            exit(true);
        end;
    end;

    internal procedure ValidateIdentifierValue(var TempParticipation: Record "Participation" temporary)
    var
        NetworkIdentifier: Record "Network Identifier";
        RegEx: Codeunit Regex;
    begin
        if NetworkIdentifier.Get(TempParticipation."Identifier Type ID") then
            if not RegEx.IsMatch(TempParticipation."Identifier Value", NetworkIdentifier."Validation Rule") then
                Error(InvalidIdentifierValueErr, TempParticipation."Identifier Value", NetworkIdentifier."Validation Rule");
    end;

    internal procedure GetCurrentActivatedProfiles(var TempParticipation: Record "Participation" temporary; var TempActivatedProfiles: Record "Activated Net. Prof." temporary)
    var
        ActivatedProfiles: Record "Activated Net. Prof.";
    begin
        ActivatedProfiles.SetRange(Network, TempParticipation.Network);
        ActivatedProfiles.SetRange("Identifier Type ID", TempParticipation."Identifier Type ID");
        ActivatedProfiles.SetRange("Identifier Value", TempParticipation."Identifier Value");
        if ActivatedProfiles.FindSet() then
            repeat
                TempActivatedProfiles.Init();
                TempActivatedProfiles := ActivatedProfiles;
                TempActivatedProfiles.Insert();
            until ActivatedProfiles.Next() = 0;
    end;

    internal procedure InitializeNetworkProfiles(var TempParticipation: Record "Participation" temporary; var TempActivatedProfiles: Record "Activated Net. Prof." temporary)
    var
        NetworkProfile: Record "Network Profile";
    begin
        NetworkProfile.SetRange(Network, TempParticipation.Network);
        NetworkProfile.SetRange(Mandatory, true);
        NetworkProfile.SetFilter("Mandatory for Country", '%1|%2', '', TempParticipation."Country/Region Code");
        NetworkProfile.SetRange(Enabled, true);
        if NetworkProfile.FindSet() then
            repeat
                TempActivatedProfiles.Init();
                TempActivatedProfiles."Network Profile ID" := NetworkProfile."CDN GUID";
                TempActivatedProfiles.Insert();
            until NetworkProfile.Next() = 0;
    end;

    internal procedure IsCompanyInfoValid(var TempCompanyContact: Record "Participation" temporary): Boolean
    begin
        if TempCompanyContact."Company Name" = '' then
            exit(false);

        if TempCompanyContact."VAT Registration No." = '' then
            exit(false);

        if TempCompanyContact.Address = '' then
            exit(false);

        if TempCompanyContact."Post Code" = '' then
            exit(false);

        if TempCompanyContact."Country/Region Code" = '' then
            exit(false);

        if TempCompanyContact."Contact Name" = '' then
            exit(false);

        if TempCompanyContact."Contact Email" = '' then
            exit(false);

        if TempCompanyContact."Contact Phone No." = '' then
            exit(false);

        exit(true);
    end;

    internal procedure IsParticipationInfoValid(var TempParticipation: Record "Participation" temporary): Boolean
    begin
        if TempParticipation."Company Name" = '' then
            exit(false);

        if TempParticipation."VAT Registration No." = '' then
            exit(false);

        if TempParticipation.Address = '' then
            exit(false);

        if TempParticipation."Post Code" = '' then
            exit(false);

        if TempParticipation."Country/Region Code" = '' then
            exit(false);

        if TempParticipation."Signatory Name" = '' then
            exit(false);

        if TempParticipation."Signatory Email" = '' then
            exit(false);

        exit(true);
    end;

    internal procedure UpdateParticipation(var TempParticipation: Record "Participation" temporary)
    var
        APIRequests: Codeunit "API Requests";
    begin
        if IsParticipationChanged(TempParticipation) then begin
            ShowProgressWindow(SendingDataProgressMsg);
            APIRequests.PatchParticipation(TempParticipation);
            CloseProgressWindow();
        end;
    end;

    internal procedure UpdateProfiles(var TempParticipation: Record "Participation" temporary; var TempActivatedProfiles: Record "Activated Net. Prof." temporary)
    var
        ActivatedProfiles: Record "Activated Net. Prof.";
        APIRequests: Codeunit "API Requests";
    begin
        ShowProgressWindow(SendingDataProgressMsg);
        if TempActivatedProfiles.FindSet() then
            repeat
                if IsNullGuid(TempActivatedProfiles."Identifier Type ID") and (TempActivatedProfiles."Identifier Value" = '') then
                    TempActivatedProfiles.Rename(TempParticipation.Network, TempParticipation."Identifier Type ID", TempParticipation."Identifier Value", TempActivatedProfiles."Network Profile ID");
                if ActivatedProfiles.Get(TempActivatedProfiles.RecordId) then begin
                    if (TempActivatedProfiles."Profile Direction" <> ActivatedProfiles."Profile Direction") or (TempActivatedProfiles.Disabled <> ActivatedProfiles.Disabled) then begin
                        APIRequests.PatchParticipationProfiles(TempActivatedProfiles, TempParticipation."CDN GUID");
                        ActivatedProfiles.TransferFields(TempActivatedProfiles, false);
                        ActivatedProfiles.Modify();
                    end;
                end else begin
                    APIRequests.PostParticipationProfile(TempActivatedProfiles, TempParticipation."CDN GUID");
                    ActivatedProfiles.TransferFields(TempActivatedProfiles, true);
                    ActivatedProfiles.Insert();
                end;

            until TempActivatedProfiles.Next() = 0;

        ActivatedProfiles.SetRange("Identifier Type ID", TempParticipation."Identifier Type ID");
        ActivatedProfiles.SetRange("Identifier Value", TempParticipation."Identifier Value");
        ActivatedProfiles.SetRange(Network, TempParticipation.Network);
        if ActivatedProfiles.FindSet() then
            repeat
                if not TempActivatedProfiles.Get(ActivatedProfiles.RecordId) then
                    APIRequests.DeleteParticipationProfiles(ActivatedProfiles, TempParticipation."CDN GUID");
            until ActivatedProfiles.Next() = 0;
        CloseProgressWindow();
    end;

    internal procedure RegisterParticipation(var TempParticipation: Record "Participation" temporary; var TempActivatedProfiles: Record "Activated Net. Prof." temporary)
    var
        CompanyInfo: Record "Company Information";
        Participation: Record "Participation";
        APIRequests: Codeunit "API Requests";
        ParticipationGUID: Guid;
    begin
        ShowProgressWindow(SendingDataProgressMsg);
        ParticipationGUID := APIRequests.PostParticipation(TempParticipation);
        Participation.SetRange("CDN GUID", ParticipationGUID);
        Participation.FindFirst();

        TempActivatedProfiles.FindSet();
        repeat
            APIRequests.PostParticipationProfile(TempActivatedProfiles, ParticipationGUID);
        until TempActivatedProfiles.Next() = 0;

        Participation.Validate("Registration Status", Participation."Registration Status"::InProcess);
        Participation.Modify();

        APIRequests.PatchParticipation(Participation);

        if Participation.Network = Participation.Network::nemhandel then begin
            CompanyInfo.Get();
            if CompanyInfo."Registration No." = '' then begin
                CompanyInfo."Registration No." := CopyStr(Participation."Identifier Value", 1, 20);
                CompanyInfo.Modify();
            end;
        end;
        CloseProgressWindow();
    end;

    internal procedure IsParticipationChanged(var TempParticipation: Record "Participation" temporary): Boolean
    var
        Participation: Record "Participation";
    begin
        if not Participation.Get(TempParticipation.Network, TempParticipation."Identifier Type ID", TempParticipation."Identifier Value") then
            exit(true);
        if TempParticipation.Address <> Participation.Address then
            exit(true);
        if TempParticipation."Company Name" <> Participation."Company Name" then
            exit(true);
        if TempParticipation."VAT Registration No." <> Participation."VAT Registration No." then
            exit(true);
        if TempParticipation."Country/Region Code" <> Participation."Country/Region Code" then
            exit(true);
        if TempParticipation."Post Code" <> Participation."Post Code" then
            exit(true);
        if TempParticipation.County <> Participation.County then
            exit(true);
        if TempParticipation."Signatory Email" <> Participation."Signatory Email" then
            exit(true);
        if TempParticipation."Signatory Name" <> Participation."Signatory Name" then
            exit(true);
        if TempParticipation."Registration Status" <> Participation."Registration Status" then
            exit(true);
    end;

    internal procedure CreateSubscription(var TempCompanyContact: Record "Participation" temporary)
    var
        ConnectionSetup: Record "Connection Setup";
        SubscriptionMgt: Codeunit "Subscription Mgt.";
        SubscriptionState: Enum "Subscription Status";
    begin
        ShowProgressWindow(SendingDataProgressMsg);
        SubscriptionState := SubscriptionState::Subscription;
        if SubscriptionMgt.UpdateSubscription(SubscriptionState, TempCompanyContact, true) then begin
            SubscriptionMgt.AcceptCompanyLicense(CompanyName);
            ConnectionSetup.Get();
            ConnectionSetup."Subscription Status" := SubscriptionState;
            ConnectionSetup.Modify();
        end;
        CloseProgressWindow();
    end;

    internal procedure UpdateSubscriptionInfo(var TempCompanyContact: Record "Participation" temporary)
    var
        SubscriptionMgt: Codeunit "Subscription Mgt.";
    begin
        ShowProgressWindow(SendingDataProgressMsg);
        if not IsSubscribed() then
            CreateSubscription(TempCompanyContact)
        else
            SubscriptionMgt.UpdateClientInformation(TempCompanyContact);
        CloseProgressWindow();
    end;

    internal procedure IsSubscribed(): Boolean
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();
        exit(ConnectionSetup."Subscription Status" = ConnectionSetup."Subscription Status"::Subscription);
    end;

    #region Simple User Choice functions
    internal procedure AddInvoiceCreditMemoProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof." temporary)
    begin
        case TempParticipation.Network of
            "Network"::peppol:
                AddPeppolInvoiceCreditMemoProfiles(TempParticipation."Country/Region Code", ActivatedProfiles, ProfileDirection);
            "Network"::nemhandel:
                AddNetworkProfileByIdentifiers("Network"::nemhandel, ActivatedProfiles, ProfileDirection,
                    'urn:www.nesubl.eu:profiles:profile5:ver2.0', '');
        end;
    end;

    local procedure AddPeppolInvoiceCreditMemoProfiles(ForCountry: Code[10]; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        case ForCountry of
            'DE':
                PopulateDEInvoiceCreditMemoProfiles("Network"::peppol, ActivatedProfiles, ProfileDirection);
            'NL':
                PopulateNLInvoiceCreditMemoProfiles("Network"::peppol, ActivatedProfiles, ProfileDirection);
        end;

        //PEPPOL Credit Note (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
            'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2::CreditNote##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::2.1');
        //PEPPOL Cross Industry Invoice (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
            'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100::CrossIndustryInvoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::D16B');
        //PEPPOL Invoice (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
            'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2::Invoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::2.1');
    end;

    local procedure PopulateDEInvoiceCreditMemoProfiles(ForNetwork: Enum "Network"; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    var
        NetworkProfile: Record "Network Profile";
    begin
        NetworkProfile.SetRange(Network, ForNetwork);
        NetworkProfile.SetRange("Mandatory for Country", 'DE');
        if NetworkProfile.FindSet() then
            repeat
                AddNetworkProfileByIdentifiers(ForNetwork, ActivatedProfiles, ProfileDirection, NetworkProfile."Process Identifier", NetworkProfile."Document Identifier");
            until NetworkProfile.Next() = 0;
    end;

    local procedure PopulateNLInvoiceCreditMemoProfiles(ForNetwork: Enum "Network"; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        //SI-UBL 2.0 Credit Note
        AddNetworkProfileByIdentifiers(ForNetwork, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
            'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2::CreditNote##urn:cen.eu:en16931:2017#compliant#urn:fdc:nen.nl:nlcius:v1.0::2.1');
        //SI-UBL 2.0 Invoice
        AddNetworkProfileByIdentifiers(ForNetwork, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
            'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2::Invoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:nen.nl:nlcius:v1.0::2.1');
    end;

    internal procedure AddInvoiceResponseProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof.")
    begin
        case TempParticipation.Network of
            "Network"::peppol:
                PopulatePeppolInvoiceResponseProfiles(ActivatedProfiles, ProfileDirection);
            "Network"::nemhandel:
                AddNetworkProfileByIdentifiers("Network"::nemhandel, ActivatedProfiles, ProfileDirection,
                    'Procurement-BilSim-1.0', '');
        end;
    end;

    local procedure PopulatePeppolInvoiceResponseProfiles(var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        //PEPPOL Invoice Response (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:poacc:bis:invoice_response:3',
            'urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2::ApplicationResponse##urn:fdc:peppol.eu:poacc:trns:invoice_response:3::2.1');
    end;

    internal procedure AddOrderOnlyProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof.")
    begin
        case TempParticipation.Network of
            "Network"::peppol:
                PopulatePeppolOrderOnlyProfiles(TempParticipation."Country/Region Code", ActivatedProfiles, ProfileDirection);
            "Network"::nemhandel:
                AddNetworkProfileByIdentifiers("Network"::nemhandel, ActivatedProfiles, ProfileDirection,
                    'urn:www.nesubl.eu:profiles:profile3:ver2.0', '');
        end;
    end;

    local procedure PopulatePeppolOrderOnlyProfiles(ForCountry: Code[10]; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        case ForCountry of
            'NO':
                //EHF Advanced Order Initiation 3.0
                AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
                    'urn:fdc:anskaffelser.no:2019:ehf:postaward:g3:02:1.0',
                    'urn:oasis:names:specification:ubl:schema:xsd:Order-2::Order##urn:fdc:peppol.eu:poacc:trns:order:3:extended:urn:fdc:anskaffelser.no:2019:ehf:spec:3.0::2.2');
        end;

        //PEPPOL Order Only (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:poacc:bis:order_only:3',
            'urn:oasis:names:specification:ubl:schema:xsd:Order-2::Order##urn:fdc:peppol.eu:poacc:trns:order:3::2.1');
    end;

    internal procedure AddOrderProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof.")
    begin
        case TempParticipation.Network of
            "Network"::peppol:
                PopulatePeppolOrderProfiles(TempParticipation."Country/Region Code", ActivatedProfiles, ProfileDirection);
            "Network"::nemhandel:
                AddNetworkProfileByIdentifiers("Network"::nemhandel, ActivatedProfiles, ProfileDirection,
                    'Procurement-OrdSim-1.0', '');
        end;
    end;

    local procedure PopulatePeppolOrderProfiles(ForCountry: Code[10]; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        case ForCountry of
            'NO':
                //EHF Advanced Order Initiation 3.0
                AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
                    'urn:fdc:anskaffelser.no:2019:ehf:postaward:g3:02:1.0',
                    'urn:oasis:names:specification:ubl:schema:xsd:Order-2::Order##urn:fdc:peppol.eu:poacc:trns:order:3:extended:urn:fdc:anskaffelser.no:2019:ehf:spec:3.0::2.2');
        end;

        //PEPPOL Order (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:poacc:bis:ordering:3',
            'urn:oasis:names:specification:ubl:schema:xsd:Order-2::Order##urn:fdc:peppol.eu:poacc:trns:order:3::2.1');
    end;

    internal procedure AddOrderResponseProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof.")
    begin
        if TempParticipation.Network = "Network"::peppol then
            PopulatePeppolOrderResponseProfiles(TempParticipation."Country/Region Code", ActivatedProfiles, ProfileDirection);
    end;

    local procedure PopulatePeppolOrderResponseProfiles(ForCountry: Code[10]; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction")
    begin
        case ForCountry of
            'NO':
                //EHF Advanced Order Response 3.0
                AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
                    'urn:fdc:anskaffelser.no:2019:ehf:postaward:g3:02:1.0',
                    'urn:oasis:names:specification:ubl:schema:xsd:OrderResponse-2::OrderResponse##urn:fdc:peppol.eu:poacc:trns:order_response:3:extended:urn:fdc:anskaffelser.no:2019:ehf:spec:3.0::2.2');
        end;

        //PEPPOL Order Response (BIS 3.0)
        AddNetworkProfileByIdentifiers("Network"::peppol, ActivatedProfiles, ProfileDirection,
            'urn:fdc:peppol.eu:poacc:bis:ordering:3',
            'urn:oasis:names:specification:ubl:schema:xsd:OrderResponse-2::OrderResponse##urn:fdc:peppol.eu:poacc:trns:order_response:3::2.1');
    end;

    internal procedure AddInvoiceAndOrderProfiles(var TempParticipation: Record "Participation" temporary; ProfileDirection: Enum "Profile Direction"; var ActivatedProfiles: Record "Activated Net. Prof.")
    begin
        if TempParticipation.Network = "Network"::nemhandel then
            AddNetworkProfileByIdentifiers("Network"::nemhandel, ActivatedProfiles, ProfileDirection,
                'Procurement-OrdSim-BilSim-1.0', '');
    end;

    local procedure AddNetworkProfileByIdentifiers(ForNetwork: Enum "Network"; var ActivatedProfiles: Record "Activated Net. Prof."; ProfileDirection: Enum "Profile Direction"; ProcessIdentifier: Text;
                                                                   DocumentIdenfitier: Text)
    var
        NetworkProfile: Record "Network Profile";
    begin
        NetworkProfile.SetRange(Network, ForNetwork);
        NetworkProfile.SetRange("Process Identifier", ProcessIdentifier);
        if DocumentIdenfitier <> '' then
            NetworkProfile.SetRange("Document Identifier", DocumentIdenfitier);
        if NetworkProfile.FindFirst() then begin
            ActivatedProfiles.Init();
            ActivatedProfiles.Network := NetworkProfile.Network;
            ActivatedProfiles."Network Profile ID" := NetworkProfile."CDN GUID";
            ActivatedProfiles."Profile Direction" := ProfileDirection;
            ActivatedProfiles.Insert();
        end;
    end;

    #endregion

    local procedure ShowProgressWindow(ProgressMsg: Text)
    begin
        ProgressDialogWindow.Open(ProgressMsg);
    end;

    procedure HasModifyPermisionOnParticipation(): Boolean
    var
        EDocService: Record "E-Document Service";
    begin
        exit(EDocService.WritePermission);
    end;

    local procedure CloseProgressWindow()
    begin
        ProgressDialogWindow.Close();
    end;

    var

        ProgressDialogWindow: Dialog;
        MetaDataLoaded: Boolean;
        SendingDataProgressMsg: Label 'Sending data to Continia Online';
        UpdatingDataProgressMsg: Label 'Updating data from Continia Online';
        InvalidIdentifierValueErr: Label 'The %1 of the participation is invalid (Rule: ''%2'').', Comment = '%1 = The current identifier value of the participatio, %2 = The regular expression rule that the identifier value must match';

}