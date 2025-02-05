// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Environment;
using System.Azure.Identity;
using Microsoft.Foundation.Company;
using System.Security.AccessControl;
using Microsoft.CRM.Team;
using System.Email;
using System.Security.User;

codeunit 6397 "Subscription Mgt."
{
    Access = Internal;

    var
        ApiUrlMgt: Codeunit "Api Url Mgt.";
        ClientCredentialsMissingErr: Label 'Client credentials missing.';
        CreateClientErrTitleErr: Label 'Failed to create client credentials';
        ExpectedStatusOKErr: Label 'Could not connect to Continia Online.\Invalid response, expected Status = OK';
        InvalidClientCredErr: Label 'Client credentials for Continia Online are invalid or missing.';
        InvalidPartnerCredErr: Label 'Partner credentials for Continia PartnerZone are invalid or missing.';
        RequestFailedErr: Label 'Request sent to Continia Online failed: %1', Comment = '%1 - Error Message from Continia Online';

    [NonDebuggable]
    internal procedure GetClientAccessToken(): SecretText
    var
        SessionManager: Codeunit "Session Manager";
    begin
        exit(SessionManager.GetAccessToken());
    end;

    [NonDebuggable]
    internal procedure InitializeContiniaClient(PartnerUserName: Text; PartnerPassword: SecretText; var PartnerId: Code[20]) Updated: Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        PartnerAccessToken: SecretText;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        // Validate input
        if (PartnerUserName = '') or (PartnerPassword.Unwrap() = '') then
            Error(InvalidPartnerCredErr);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.PartnerAccessTokenUrl());
        HttpContent.WriteFrom(GetPartnerZoneConnectRequestBody(PartnerUserName, PartnerPassword));
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;
        PartnerAccessToken := HandlePartnerZoneAccessTokenResponse(ResponseXmlDoc);

        if InitializeContiniaClient(PartnerAccessToken) then
            exit(CheckPartnerAndGetPartnerId(PartnerUserName, PartnerPassword, PartnerId));
    end;

    [NonDebuggable]
    internal procedure CheckPartnerAndGetPartnerId(PartnerUserName: Text; PartnerPassword: SecretText; var PartnerId: Code[20]): Boolean
    var
        SessionManager: Codeunit "Session Manager";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        PartnerIdNode: XmlNode;
        ErrorNode: XmlNode;
    begin
        // Validate input
        if (PartnerUserName = '') or (PartnerPassword.Unwrap() = '') then
            Error(InvalidPartnerCredErr);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.PartnerZoneUrl());
        HttpContent.WriteFrom(GetPartnerZoneConnectRequestBody(PartnerUserName, PartnerPassword));

        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken()));

        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;

        if ResponseXmlDoc.SelectSingleNode('Error/@Message', ErrorNode) then
            if ErrorNode.AsXmlAttribute().Value <> '' then
                Error(InvalidPartnerCredErr);

        if ResponseXmlDoc.SelectSingleNode('PartnerZoneConnectResponse/@Msid', PartnerIdNode) then begin
            PartnerId := CopyStr(PartnerIdNode.AsXmlAttribute().Value, 1, MaxStrLen(PartnerId));
            exit(true);
        end;
    end;

    [NonDebuggable]
    local procedure InitializeContiniaClient(PartnerAccessToken: SecretText): Boolean
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        CredentialManagement: Codeunit "Credential Management";
        SessionManager: Codeunit "Session Manager";
        EnvironmentInformation: Codeunit "Environment Information";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ClientId: SecretText;
        ClientSecret: SecretText;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        if CredentialManagement.IsClientCredentialsValid() then
            exit(false);

        SessionManager.ClearAccessToken();
        SessionManager.RefreshClientIdentifier();

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('PartnerZone', PartnerAccessToken);
        if EnvironmentInformation.IsSaaSInfrastructure() then
            HttpHeaders.Add('x-AzureTenantId', AzureADTenant.GetAadTenantId());
        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.ClientEnvironmentInitializeUrl());
        HttpContent.WriteFrom(GetInitializeCredentialRequestBody());
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;
        HandleInitializeCredentialResponse(ResponseXmlDoc, ClientId, ClientSecret);
        CredentialManagement.InsertClientCredentials(ClientId, ClientSecret, GetTenantSubscriptionId());
        Commit(); // Requires commit to store the credentials
        SessionManager.RefreshClientIdentifier();
        exit(true);
    end;

    [NonDebuggable]
    local procedure HandlePartnerZoneAccessTokenResponse(ResponseXmlDoc: XmlDocument): Text
    var
        TempXmlNode: XmlNode;
    begin
        if ResponseXmlDoc.SelectSingleNode('Error/@Message', TempXmlNode) then
            if TempXmlNode.AsXmlAttribute().Value <> '' then
                Error(InvalidPartnerCredErr);
        if not ResponseXmlDoc.SelectSingleNode('PartnerZoneToken/@Value', TempXmlNode) then
            Error(InvalidPartnerCredErr);
        exit(TempXmlNode.AsXmlAttribute().Value);
    end;

    [NonDebuggable]
    local procedure GetPartnerZoneConnectRequestBody(PartnerUserName: Text; PartnerPassword: SecretText) RequestBody: Text
    var
        PartnerRequestElement: XmlElement;
    begin
        PartnerRequestElement := XmlElement.Create('PartnerZoneConnectRequest');
        PartnerRequestElement.SetAttribute('Email', PartnerUserName);
        PartnerRequestElement.SetAttribute('Password', PartnerPassword.Unwrap());
        PartnerRequestElement.WriteTo(RequestBody);
    end;

    [NonDebuggable]
    local procedure GetInitializeCredentialRequestBody() RequestBody: Text
    var
        CompanyInfo: Record "Company Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        TenantSubscriptionId: Code[50];
        ClientName: Text;
        EnvironmentName: Text;
        OwnerAzureId: Text;
        InitializeCredentialsElement: XmlElement;
    begin
        TenantSubscriptionId := GetTenantSubscriptionId();

        CompanyInfo.Get();
        CompanyInfo.TestField(Name);
        ClientName := CompanyInfo.Name;

        OwnerAzureId := AzureADTenant.GetAadTenantId();
        if OwnerAzureId = '' then
            OwnerAzureId := 'Common';

        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        if EnvironmentName = '' then
            EnvironmentName := 'Production';

        InitializeCredentialsElement := XmlElement.Create('InitializeCredentialsV3');
        InitializeCredentialsElement.SetAttribute('AzureId', TenantSubscriptionId);
        InitializeCredentialsElement.SetAttribute('OwnerAzureId', OwnerAzureId);
        InitializeCredentialsElement.SetAttribute('Name', ClientName);
        InitializeCredentialsElement.SetAttribute('UserName', UserId());
        InitializeCredentialsElement.SetAttribute('EnvironmentName', EnvironmentName);
        InitializeCredentialsElement.WriteTo(RequestBody);
    end;

    [NonDebuggable]
    internal procedure GetClientInfoApp(var ClientInfo: Record Participation temporary; ShowError: Boolean) Success: Boolean
    var
        CredentialMgt: Codeunit "Credential Management";
        ContactPerson: XmlNode;
        SubscriptionNode: XmlNode;
        SubscriptionResponse: XmlNode;
        TempXMLNode: XmlNode;
        InvoiceDetailsXMLPathLbl: Label 'Subscriptions/Subscription[@AppCode=''%1'']/InvoicingDetails', Locked = true, Comment = '%1 - App Code';
        ContactPersonXMLPathLbl: Label 'Subscriptions/Subscription[@AppCode=''%1'']/ContactPerson', Locked = true, Comment = '%1 - App Code';
        SubscriptionDetailsXMLPathLbl: Label 'Subscriptions/Subscription[@AppCode=''%1'']', Locked = true, Comment = '%1 - App Code';
    begin
        GetSubscription(SubscriptionResponse, ShowError);

        if SubscriptionResponse.SelectSingleNode(StrSubstNo(SubscriptionDetailsXMLPathLbl, CredentialMgt.GetAppCode()), SubscriptionNode) then begin
            SubscriptionNode.SelectSingleNode('@PartnerId', TempXMLNode);
            ClientInfo."Partner Id" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Partner Id"));

            if SubscriptionResponse.SelectSingleNode(StrSubstNo(InvoiceDetailsXMLPathLbl, CredentialMgt.GetAppCode()), SubscriptionNode) then begin

                SubscriptionNode.SelectSingleNode('@CompanyName', TempXMLNode);
                ClientInfo."Company Name" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Company Name"));

                SubscriptionNode.SelectSingleNode('@CompanyAddress', TempXMLNode);
                ClientInfo.Address := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo.Address));

                SubscriptionNode.SelectSingleNode('@PostalCode', TempXMLNode);
                ClientInfo."Post Code" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Post Code"));

                SubscriptionNode.SelectSingleNode('@Country', TempXMLNode);
                ClientInfo.County := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo.County));

                SubscriptionNode.SelectSingleNode('@CountryIsoCode', TempXMLNode);
                ClientInfo."Country/Region Code" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Country/Region Code"));

                SubscriptionNode.SelectSingleNode('@VatRegNo', TempXMLNode);
                ClientInfo."VAT Registration No." := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."VAT Registration No."));

                SubscriptionNode.SelectSingleNode('@Email', TempXMLNode);
                ClientInfo."Contact Email" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Contact Email"));

                SubscriptionNode.SelectSingleNode('@PhoneNo', TempXMLNode);
                ClientInfo."Contact Phone No." := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Contact Phone No."));



            end;
            if SubscriptionResponse.SelectSingleNode(StrSubstNo(ContactPersonXMLPathLbl, CredentialMgt.GetAppCode()), ContactPerson) then begin
                ContactPerson.SelectSingleNode('@Name', TempXMLNode);
                ClientInfo."Contact Name" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Contact Name"));

                ContactPerson.SelectSingleNode('@Email', TempXMLNode);
                ClientInfo."Contact Email" := CopyStr(TempXMLNode.AsXmlAttribute().Value, 1, MaxStrLen(ClientInfo."Contact Email"));
            end;
            if not ClientInfo.Modify() then
                ClientInfo.Insert();

            Success := true;
        end;
    end;


    [NonDebuggable]
    internal procedure HasOtherAppsInSubscription(): Boolean
    var
        CredentialMgt: Codeunit "Credential Management";
        SubscriptionNode: XmlNode;
        SubscriptionResponse: XmlNode;
        AppCodeSubscriptionXMLPathLbl: Label 'Subscriptions/Subscription[@AppCode!=''%1'']', Locked = true, Comment = '%1 - App Code';
    begin
        GetSubscription(SubscriptionResponse, true);

        exit(SubscriptionResponse.SelectSingleNode(StrSubstNo(AppCodeSubscriptionXMLPathLbl, CredentialMgt.GetAppCode()), SubscriptionNode));
    end;

    [NonDebuggable]
    internal procedure GetSubscription(var SubscriptionResponse: XmlNode; ShowError: Boolean) Success: Boolean
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        CredentialMgt: Codeunit "Credential Management";
        SessionManager: Codeunit "Session Manager";
        EnvironmentInformation: Codeunit "Environment Information";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        if not CredentialMgt.IsClientCredentialsValid() then
            exit(false);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken()));
        HttpHeaders.Add('x-continia-companyguid', CredentialMgt.GetCompanyGuidAsText());
        HttpHeaders.Add('x-continia-version', '1500');
        if EnvironmentInformation.IsSaaSInfrastructure() then
            HttpHeaders.Add('x-AzureTenantId', AzureADTenant.GetAadTenantId());

        HttpRequest.Method('GET');
        HttpRequest.SetRequestUri(ApiUrlMgt.GetSubscriptionUrl());

        HttpClient.Timeout := 6000;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);

            if ResponseXmlDoc.SelectSingleNode('/SubscriptionResponse', SubscriptionResponse) then
                exit(true);
        end;

        exit(VerifyResponse(ResponseXmlDoc, ShowError));
    end;

    [NonDebuggable]
    internal procedure Unsubscribe(ShowError: Boolean) Success: Boolean
    var
        ConnectionSetup: Record "Connection Setup";
        TempCompanyInfo: Record Participation temporary;
        SubscriptionStatus: Enum "Subscription Status";
    begin
        SubscriptionStatus := SubscriptionStatus::Unsubscribed;
        if not GetClientInfoApp(TempCompanyInfo, ShowError) then
            exit;
        if not UpdateSubscription(SubscriptionStatus, TempCompanyInfo, ShowError) then
            exit;

        ConnectionSetup.Get();
        ConnectionSetup."Subscription Status" := SubscriptionStatus;
        ConnectionSetup.Modify();
    end;

    [NonDebuggable]
    internal procedure UpdateSubscription(SubscriptionState: Enum "Subscription Status"; var ClientInfo: Record Participation temporary; ShowError: Boolean) Success: Boolean
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        CredentialManagement: Codeunit "Credential Management";
        SessionManager: Codeunit "Session Manager";
        EnvironmentInformation: Codeunit "Environment Information";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        if not CredentialManagement.IsClientCredentialsValid() then
            exit(false);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken()));
        HttpHeaders.Add('x-continia-companyguid', CredentialManagement.GetCompanyGuidAsText());
        HttpHeaders.Add('x-continia-version', '1500');
        if EnvironmentInformation.IsSaaSInfrastructure() then
            HttpHeaders.Add('x-AzureTenantId', AzureADTenant.GetAadTenantId());

        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.UpdateSubscriptionUrl());
        HttpContent.WriteFrom(GetUpdateSubscriptionBody(SubscriptionState, ClientInfo));
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;


        HttpClient.Timeout := 6000;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;

        exit(VerifyResponse(ResponseXmlDoc, ShowError));
    end;

    [NonDebuggable]
    local procedure VerifyResponse(ResponseXmlDoc: XmlDocument; ShowError: Boolean): Boolean
    var
        ErrorMessage: Text;
        ResponseStatus: Text;
        ErrorMessageAttr: XmlAttribute;
        ResponseStatusAttr: XmlAttribute;
        EmptyResponseNode: XmlNode;
        ErrorNode: XmlNode;
    begin
        if ResponseXmlDoc.SelectSingleNode('EmptyResponse', EmptyResponseNode) then
            if EmptyResponseNode.AsXmlElement().Attributes().Get('Status', ResponseStatusAttr) then
                ResponseStatus := ResponseStatusAttr.Value;

        if ResponseXmlDoc.SelectSingleNode('Error', ErrorNode) then
            if ErrorNode.AsXmlElement().Attributes().Get('Message', ErrorMessageAttr) then
                ErrorMessage := ErrorMessageAttr.Value;

        if ErrorMessage <> '' then
            if ShowError then
                Error(ErrorMessage)
            else
                exit(false);

        if ResponseStatus <> 'OK' then
            if ShowError then
                Error(ExpectedStatusOKErr)
            else
                exit(false);

        exit(true);
    end;


    [NonDebuggable]
    local procedure GetUpdateSubscriptionBody(SubscriptionState: Enum "Subscription Status"; var ClientInfo: Record Participation temporary) RequestBody: Text
    var
        AppMgt: Codeunit "Application System Constants";
        CredentialMgt: Codeunit "Credential Management";
        ContactPerson: XmlElement;
        InvoicingDetails: XmlElement;
        Module: XmlElement;
        Modules: XmlElement;
        UpdateSubscriptionRequest: XmlElement;
    begin
        UpdateSubscriptionRequest := XmlElement.Create('UpdateSubscriptionRequest');
        UpdateSubscriptionRequest.SetAttribute('AppCode', CredentialMgt.GetAppCode());
        UpdateSubscriptionRequest.SetAttribute('AppVersion', CredentialMgt.GetAppVersion());
        UpdateSubscriptionRequest.SetAttribute('AppVersionText', CredentialMgt.GetAppFullName());
        UpdateSubscriptionRequest.SetAttribute('CoreVersion', CredentialMgt.GetAppVersion());
        UpdateSubscriptionRequest.SetAttribute('CoreVersionText', CredentialMgt.GetAppFullName());
        UpdateSubscriptionRequest.SetAttribute('NavVersion', GetTenantApplicationVersion());
        UpdateSubscriptionRequest.SetAttribute('NavVersionText', AppMgt.ApplicationVersion());
        UpdateSubscriptionRequest.SetAttribute('State', Format(MapOnlineSubscriptionState(SubscriptionState)));
        UpdateSubscriptionRequest.SetAttribute('UserId', UserId);
        UpdateSubscriptionRequest.SetAttribute('UserEmail', GetUserNotificationEmail());
        UpdateSubscriptionRequest.SetAttribute('PartnerId', ClientInfo."Partner Id");

        if ClientInfo."Company Name" <> '' then begin
            InvoicingDetails := XmlElement.Create('InvoicingDetails');
            InvoicingDetails.SetAttribute('CompanyName', ClientInfo."Company Name");
            InvoicingDetails.SetAttribute('CompanyAddress', ClientInfo.Address);
            InvoicingDetails.SetAttribute('PostalCode', ClientInfo."Post Code");
            InvoicingDetails.SetAttribute('Country', ClientInfo.County);
            InvoicingDetails.SetAttribute('CountryIsoCode', ClientInfo."Country/Region Code");
            InvoicingDetails.SetAttribute('VatRegNo', ClientInfo."VAT Registration No.");
            InvoicingDetails.SetAttribute('Email', ClientInfo."Contact Email");
            InvoicingDetails.SetAttribute('PhoneNo', ClientInfo."Contact Phone No.");
            UpdateSubscriptionRequest.Add(InvoicingDetails);

            ContactPerson := XmlElement.Create('ContactPerson');
            ContactPerson.SetAttribute('Name', ClientInfo."Contact Name");
            ContactPerson.SetAttribute('Email', ClientInfo."Contact Email");
            UpdateSubscriptionRequest.Add(ContactPerson);
        end;

        Modules := XmlElement.Create('Modules');
        Module := XmlElement.Create('Module');
        Module.SetAttribute('Code', 'ESSENTIAL');
        Module.SetAttribute('State', '1');
        Modules.Add(Module);
        UpdateSubscriptionRequest.Add(Modules);

        UpdateSubscriptionRequest.WriteTo(RequestBody);
    end;

    [NonDebuggable]
    internal procedure AcceptCompanyLicense(CompanyName: Text): Boolean
    var
        CredentialManagement: Codeunit "Credential Management";
        SessionManager: Codeunit "Session Manager";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        if not CredentialManagement.IsClientCredentialsValid() then
            exit(false);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken()));
        HttpHeaders.Add('x-continia-companyguid', CredentialManagement.GetCompanyGuidAsText());

        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.GetAcceptCompanyLicenseUrl());
        HttpContent.WriteFrom(GetAcceptCompanyLicenseBody(CompanyName));
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;

        HttpClient.Timeout := 6000;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;

        exit(VerifyResponse(ResponseXmlDoc, true));
    end;

    [NonDebuggable]
    local procedure GetAcceptCompanyLicenseBody(CompanyName: Text) RequestBody: Text
    var
        CredentialMgt: Codeunit "Credential Management";
        AcceptCompanyLicenseRequest: XmlElement;
    begin
        AcceptCompanyLicenseRequest := XmlElement.Create('AcceptCompanyLicenseRequest');
        AcceptCompanyLicenseRequest.SetAttribute('CompanyName', CompanyName);
        AcceptCompanyLicenseRequest.SetAttribute('AppCode', CredentialMgt.GetAppCode());
        AcceptCompanyLicenseRequest.WriteTo(RequestBody);
    end;

    [NonDebuggable]
    internal procedure UpdateClientInformation(var ClientInfo: Record Participation temporary): Boolean
    var
        CredentialManagement: Codeunit "Credential Management";
        SessionManager: Codeunit "Session Manager";
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        if not CredentialManagement.IsClientCredentialsValid() then
            exit(false);

        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken()));
        HttpHeaders.Add('x-continia-companyguid', CredentialManagement.GetCompanyGuidAsText());
        HttpHeaders.Add('x-continia-version', '1500');
        if EnvironmentInformation.IsSaaSInfrastructure() then
            HttpHeaders.Add('x-AzureTenantId', AzureADTenant.GetAadTenantId());

        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.GetUpdateCompanyInfoUrl());
        HttpContent.WriteFrom(GetClientInfoUpdateRequest(ClientInfo));
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        HttpRequest.Content := HttpContent;

        HttpClient.Timeout := 6000;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;

        exit(VerifyResponse(ResponseXmlDoc, true));
    end;

    [NonDebuggable]
    local procedure GetClientInfoUpdateRequest(var ClientInfo: Record Participation temporary) RequestBody: Text
    var
        CompanyInfoRequest: XmlElement;
        CompanyInfo: XmlElement;
        ContactPerson: XmlElement;
    begin
        CompanyInfoRequest := XmlElement.Create('InvoicingInformationRequest');
        CompanyInfo := XmlElement.Create('InvoicingDetails');
        CompanyInfo.SetAttribute('CompanyName', ClientInfo."Company Name");
        CompanyInfo.SetAttribute('CompanyAddress', ClientInfo.Address);
        CompanyInfo.SetAttribute('PostalCode', ClientInfo."Post Code");
        CompanyInfo.SetAttribute('Country', ClientInfo.County);
        CompanyInfo.SetAttribute('CountryIsoCode', ClientInfo."Country/Region Code");
        CompanyInfo.SetAttribute('VatRegNo', ClientInfo."VAT Registration No.");
        CompanyInfo.SetAttribute('Email', ClientInfo."Contact Email");
        CompanyInfo.SetAttribute('PhoneNo', ClientInfo."Contact Phone No.");
        CompanyInfo.SetAttribute('UserId', UserId);
        CompanyInfoRequest.Add(CompanyInfo);

        ContactPerson := XmlElement.Create('ContactPerson');
        ContactPerson.SetAttribute('Name', ClientInfo."Contact Name");
        ContactPerson.SetAttribute('Email', ClientInfo."Contact Email");
        CompanyInfoRequest.Add(ContactPerson);

        CompanyInfoRequest.WriteTo(RequestBody);
    end;

    [NonDebuggable]
    internal procedure GetUserNotificationEmail(): Text[250]
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        User: Record User;
        UserSetup: Record "User Setup";
        MailManagement: Codeunit "Mail Management";
    begin
        User.SetCurrentKey("User Name");
        User.SetRange("User Name", UserId);
        if User.FindFirst() then begin
            if MailManagement.CheckValidEmailAddress(User."Authentication Email") then
                exit(User."Authentication Email");
            if UserSetup.Get(User."User Name") then begin
                if MailManagement.CheckValidEmailAddress(UserSetup."E-Mail") then
                    exit(UserSetup."E-Mail");
                if SalespersonPurchaser.Get(UserSetup."Salespers./Purch. Code") then
                    if MailManagement.CheckValidEmailAddress(SalespersonPurchaser."E-Mail") then
                        exit(SalespersonPurchaser."E-Mail");
            end;
        end;
    end;

    [NonDebuggable]
    local procedure GetTenantSubscriptionId(): Code[50]
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        AadTenantId: Text;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if EnvironmentInformation.IsProduction() then begin
                AadTenantId := AzureADTenant.GetAadTenantId();
                if (AadTenantId <> '') and (AadTenantId.ToLower() = 'common') then
                    exit(CopyStr(AadTenantId, 1, 50));
            end;
        exit(CopyStr(LowerCase(CopyStr(Format(CreateGuid()), 2, 36)), 1, 50))
    end;

    [NonDebuggable]
    local procedure HandleInitializeCredentialResponse(ResponseXmlDoc: XmlDocument; var ClientId: SecretText; var ClientSecret: SecretText)
    var
        CredentialsAreMissing: Boolean;
        CreateCredentialErrorInfo: ErrorInfo;
        ErrorMessage: Text;
        TempXmlNode: XmlNode;
    begin
        CreateCredentialErrorInfo.Title := CreateClientErrTitleErr;
        CreateCredentialErrorInfo.Verbosity := Verbosity::Error;
        CreateCredentialErrorInfo.DataClassification := DataClassification::SystemMetadata;

        if ResponseXmlDoc.SelectSingleNode('Error/@Message', TempXmlNode) then
            ErrorMessage := TempXmlNode.AsXmlAttribute().Value;
        if ErrorMessage <> '' then begin
            CreateCredentialErrorInfo.Message := StrSubstNo(RequestFailedErr, ErrorMessage);
            Error(CreateCredentialErrorInfo);
        end;

        if ResponseXmlDoc.SelectSingleNode('InitializeCredentialsResponse/@ClientId', TempXmlNode) then
            ClientId := TempXmlNode.AsXmlAttribute().Value
        else
            CredentialsAreMissing := true;

        if ResponseXmlDoc.SelectSingleNode('InitializeCredentialsResponse/@ClientPassword', TempXmlNode) then
            ClientSecret := TempXmlNode.AsXmlAttribute().Value
        else
            CredentialsAreMissing := true;

        if CredentialsAreMissing then begin
            CreateCredentialErrorInfo.Message := ClientCredentialsMissingErr;
            Error(CreateCredentialErrorInfo);
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure TryAcquireClientToken(var AccessTokenValue: Text; var ExpiresInMs: Integer)
    var
        CredentialManagement: Codeunit "Credential Management";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ExpiresIn: Integer;
        Credentials: Text;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        HttpRequest.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpHeaders.Add('x-continia-check', 'true');
        Credentials := CredentialManagement.GetClientCredentialsApiBodyString();
        HttpRequest.Method('POST');
        HttpRequest.SetRequestUri(ApiUrlMgt.ClientAccessTokenUrl());
        HttpContent.WriteFrom(Credentials);
        HttpRequest.Content := HttpContent;
        HttpClient.Send(HttpRequest, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody <> '' then
                XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        end;
        HandleClientAccessTokenResponse(ResponseXmlDoc, AccessTokenValue, ExpiresIn);
        ExpiresInMs := ExpiresIn * 1000;
    end;

    [NonDebuggable]
    local procedure HandleClientAccessTokenResponse(ResponseXmlDoc: XmlDocument; var AccessTokenValue: Text; var ExpiresIn: Integer): Text
    var
        CredentialsAreMissing: Boolean;
        CreateCredentialErrorInfo: ErrorInfo;
        ErrorMessage: Text;
        TempXmlNode: XmlNode;
    begin
        if ResponseXmlDoc.SelectSingleNode('Error/@Message', TempXmlNode) then
            ErrorMessage := TempXmlNode.AsXmlAttribute().Value;
        if ErrorMessage <> '' then begin
            CreateCredentialErrorInfo.Message := StrSubstNo(RequestFailedErr, ErrorMessage);
            Error(CreateCredentialErrorInfo);
        end;

        if ResponseXmlDoc.SelectSingleNode('Token/@AccessToken', TempXmlNode) then
            AccessTokenValue := TempXmlNode.AsXmlAttribute().Value
        else
            CredentialsAreMissing := true;

        if ResponseXmlDoc.SelectSingleNode('Token/@ExpiresIn', TempXmlNode) then
            Evaluate(ExpiresIn, TempXmlNode.AsXmlAttribute().Value);

        if CredentialsAreMissing then begin
            CreateCredentialErrorInfo.Message := InvalidClientCredErr;
            Error(CreateCredentialErrorInfo);
        end;
    end;

    [NonDebuggable]
    local procedure MapOnlineSubscriptionState(SubscriptionStatus: Enum "Subscription Status"): Integer
    begin
        case SubscriptionStatus of
            SubscriptionStatus::Subscription:
                exit(1);
            SubscriptionStatus::Unsubscribed:
                exit(2);
        end;
    end;

    [NonDebuggable]
    internal procedure GetTenantApplicationVersion(): Text
    var
        MajorMinorVersion: Code[100];
        Version: Integer;
    begin
        MajorMinorVersion := GetTenantMajorApplicationVersion() + GetTenantMinorApplicationVersion();
        Evaluate(Version, PadStr(MajorMinorVersion, 6, '0'));
        exit(Format(Version));
    end;

    [NonDebuggable]
    internal procedure GetTenantMajorApplicationVersion(): Code[50]
    var
        thisModule: ModuleInfo;
        BaseAppId: Text;
        completeVersion: Version;
    begin
        BaseAppId := '437dbf0e-84ff-417a-965d-ed2bb9650972';
        // First try to get Microsoft Base App
        if NavApp.GetModuleInfo(BaseAppId, thisModule) then begin
            completeVersion := thisModule.AppVersion;
            exit(Format(completeVersion.Major));
        end;

        // Second try to get Application App
        if GetApplicationModuleInfo(thisModule) then begin
            completeVersion := thisModule.AppVersion;
            exit(Format(completeVersion.Major));
        end;
    end;

    [NonDebuggable]
    internal procedure GetTenantMinorApplicationVersion(): Code[50]
    var
        thisModule: ModuleInfo;
        BaseAppId: Text;
        completeVersion: Version;
    begin
        BaseAppId := '437dbf0e-84ff-417a-965d-ed2bb9650972';
        // First try to get Microsoft Base App
        if NavApp.GetModuleInfo(BaseAppId, thisModule) then begin
            completeVersion := thisModule.AppVersion;
            exit(Format(completeVersion.Minor));
        end;

        // Second try to get Application App
        if GetApplicationModuleInfo(thisModule) then begin
            completeVersion := thisModule.AppVersion;
            exit(Format(completeVersion.Minor));
        end;
    end;

    [NonDebuggable]
    local procedure GetApplicationModuleInfo(var ApplicationModuleInfo: ModuleInfo): Boolean
    var
        AppDependencies: List of [ModuleDependencyInfo];
        AppDependency: ModuleDependencyInfo;
        CurrentModule: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModule);
        AppDependencies := CurrentModule.Dependencies;
        foreach AppDependency in AppDependencies do
            if (AppDependency.Name = 'Application') then
                if NavApp.GetModuleInfo(AppDependency.Id, ApplicationModuleInfo) then
                    exit(true);
    end;

}