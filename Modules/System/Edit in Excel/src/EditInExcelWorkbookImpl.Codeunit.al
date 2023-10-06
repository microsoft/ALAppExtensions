// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides an interface to create Workbook using the Excel Add-in.
/// </summary>
codeunit 1489 "Edit in Excel Workbook Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        DataEntityExportInfo: DotNet DataEntityExportInfo; // Stateful
        BindingInfo: DotNet BindingInfo; // Stateful
        DataEntityInfo: DotNet DataEntityInfo; // Stateful
        DataEntityExportGenerator: DotNet DataEntityExportGenerator; // Global var used for export, to avoid cleaning up before output is read from returned InputStream
        MemoryStream: DotNet MemoryStream; // Global var used for export, to avoid cleaning up before output is read from returned InputStream
        EditInExcelTelemetryCategoryTxt: Label 'Edit in Excel', Locked = true;
        EditInExcelUsageWithCentralizedDeploymentsTxt: Label 'Edit in Excel invoked with "Use Centralized deployments" = %1', Locked = true;
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';
        CreatingExcelDocumentWithIdTxt: Label 'Creating excel document with id %1.', Locked = true;
        WebServiceDoesNotExistErr: Label 'Cannot initialize Edit in Excel workbook since the web service ''%1'' does not exist.', Comment = '%1 = name of the web service';
        NoColumnsExistErr: Label 'No columns were added to the workbook.';
        ExternalizedServiceName: Text;

    procedure Initialize(ServiceName: Text[250])
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelImpl: Codeunit "Edit in Excel Impl.";
    begin
        // Ensure web service exist and is published
        if (not TenantWebService.Get(TenantWebService."Object Type"::Page, ServiceName)) and
            (not TenantWebService.Get(TenantWebService."Object Type"::Query, ServiceName)) and
            (not TenantWebService.Get(TenantWebService."Object Type"::Codeunit, ServiceName)) then
            Error(WebServiceDoesNotExistErr, ServiceName);

        if not TenantWebService.Published then
            Error(WebServiceHasBeenDisabledErr, TenantWebService."Service Name");

        InitializeDataEntityExportInfo(TenantWebService);

        // Create DataEntityInfo
        DataEntityInfo := DataEntityInfo.DataEntityInfo();
        // Align the entity name to resemble how OData processes the service name
        ExternalizedServiceName := EditInExcelImpl.ExternalizeODataObjectName(ServiceName);
        DataEntityInfo.Name := ExternalizedServiceName;
        DataEntityInfo.PublicName := ExternalizedServiceName;
        DataEntityExportInfo.Entities.Add(DataEntityInfo);

        BindingInfo := BindingInfo.BindingInfo();
        BindingInfo.EntityName := DataEntityInfo.Name;

        DataEntityExportInfo.Bindings.Add(BindingInfo);
    end;

    procedure SetFilters(EditInExcelFilters: Codeunit "Edit in Excel Filters")
    var
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        ChildFilterCollectionNode: DotNet FilterCollectionNode;
        FieldFilters: DotNet GenericDictionary2;
    begin
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();  // One filter collection node for entire entity
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
        EditinExcelFilters.GetFilters(FieldFilters);

        if not IsNull(FieldFilters) then
            foreach ChildFilterCollectionNode in FieldFilters.Values do
                if ChildFilterCollectionNode.Collection.Count() > 0 then
                    EntityFilterCollectionNode.Collection.Add(ChildFilterCollectionNode);

        ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);
        DataEntityInfo.Filter(EntityFilterCollectionNode);
    end;

    procedure SetSearchText(SearchText: Text)
    begin
        if SearchText <> '' then
            DataEntityExportInfo.Headers.Add('pageSearchString', DelChr(SearchText, '=', '@*'));
    end;

    procedure AddColumn(FieldCaption: Text; OdataFieldName: Text)
    var
        FieldInfo: DotNet "Office.FieldInfo";
    begin
        FieldInfo := FieldInfo.FieldInfo();
        FieldInfo.Name := OdataFieldName;
        FieldInfo.Label := FieldCaption;
        BindingInfo.Fields.Add(FieldInfo);
    end;

    procedure InsertColumn(Index: Integer; FieldCaption: Text; OdataFieldName: Text)
    var
        FieldInfo: DotNet "Office.FieldInfo";
    begin
        FieldInfo := FieldInfo.FieldInfo();
        FieldInfo.Name := OdataFieldName;
        FieldInfo.Label := FieldCaption;
        BindingInfo.Fields.Insert(Index, FieldInfo);
    end;

    procedure ImposeExcelOnlineRestrictions()
    begin
        while BindingInfo.Fields.Count() > GetExcelOnlineColumnLimit() do
            BindingInfo.Fields.RemoveAt(BindingInfo.Fields.Count() - 1); // If we use excel online, only include supported number of columns
    end;

    procedure ExportToStream(): InStream
    begin
        if BindingInfo.Fields.Count() = 0 then
            Error(NoColumnsExistErr);
        DataEntityExportGenerator := DataEntityExportGenerator.DataEntityExportGenerator();
        MemoryStream := MemoryStream.MemoryStream();
        DataEntityExportGenerator.GenerateWorkbook(DataEntityExportInfo, MemoryStream);

        exit(MemoryStream);
    end;

    internal procedure ReduceRedundantFilterCollectionNodes(var EntityFilterCollectionNode: DotNet FilterCollectionNode)
    var
        Type: DotNet FilterCollectionNode;
    begin
        Type := Type.FilterCollectionNode(); // In order to only iterate over CollectionNode and not BinaryNode when reducing the nodes
        while (EntityFilterCollectionNode.Collection.Count() = 1)
        do begin
            if not EntityFilterCollectionNode.Collection.Item(0).GetType().Equals(Type.GetType()) then
                break;
            EntityFilterCollectionNode := EntityFilterCollectionNode.Collection.Item(0); // No need to keep collections with just one entry
        end;
    end;

    local procedure InitializeDataEntityExportInfo(TenantWebService: Record "Tenant Web Service")
    var
        Company: Record Company;
        AzureADTenant: Codeunit "Azure AD Tenant";
        AuthenticationOverrides: DotNet AuthenticationOverrides;
        ConnectionInfo: DotNet ConnectionInfo;
        OfficeAppInfo: DotNet OfficeAppInfo;
        HostName: Text;
        DocumentId: Text;
    begin
        CreateOfficeAppInfo(OfficeAppInfo);

        AuthenticationOverrides := AuthenticationOverrides.AuthenticationOverrides();
        AuthenticationOverrides.Tenant := AzureADTenant.GetAadTenantId();

        DataEntityExportInfo := DataEntityExportInfo.DataEntityExportInfo();
        DataEntityExportInfo.AppReference := OfficeAppInfo;
        DataEntityExportInfo.Authentication := AuthenticationOverrides;

        ConnectionInfo := ConnectionInfo.ConnectionInfo();
        HostName := GetHostName();
        if StrPos(HostName, '?') <> 0 then
            HostName := CopyStr(HostName, 1, StrPos(HostName, '?') - 1);
        ConnectionInfo.HostName := HostName;

        DataEntityExportInfo.Connection := ConnectionInfo;
        DataEntityExportInfo.Language := LanguageIDToCultureName(WindowsLanguage);
        DataEntityExportInfo.EnableDesign := true;
        DataEntityExportInfo.RefreshOnOpen := true;
        DataEntityExportInfo.DateCreated := CurrentDateTime();
        DataEntityExportInfo.GenerationActivityId := format(SessionId());

        DocumentId := format(CreateGuid(), 0, 4);
        DataEntityExportInfo.DocumentId := DocumentId;
        Session.LogMessage('0000GYB', StrSubstNo(CreatingExcelDocumentWithIdTxt, DocumentId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);

        if EnvironmentInformation.IsSaaS() then
            DataEntityExportInfo.Headers.Add('BCEnvironment', EnvironmentInformation.GetEnvironmentName());
        if Company.Get(TenantWebService.CurrentCompany) then
            DataEntityExportInfo.Headers.Add('Company', Format(Company.Id, 0, 4))
        else
            DataEntityExportInfo.Headers.Add('Company', TenantWebService.CurrentCompany);
    end;

    local procedure CreateOfficeAppInfo(var OfficeAppInfo: DotNet OfficeAppInfo)  // Note: Keep this in sync with BaseApp - ODataUtility
    var
        EditinExcelSettings: record "Edit in Excel Settings";
    begin
        OfficeAppInfo := OfficeAppInfo.OfficeAppInfo();
        if EditinExcelSettings.Get() and EditinExcelSettings."Use Centralized deployments" then begin
            OfficeAppInfo.Id := '61bcc63f-b860-4280-8280-3e4fb5ea7726';
            OfficeAppInfo.Store := 'EXCatalog';
            OfficeAppInfo.StoreType := 'EXCatalog';
            OfficeAppInfo.Version := '1.3.0.0';
        end else begin
            OfficeAppInfo.Id := 'WA104379629';
            OfficeAppInfo.Store := 'en-US';
            OfficeAppInfo.StoreType := 'OMEX';
            OfficeAppInfo.Version := '1.3.0.0';
        end;
        Session.LogMessage('0000F7M', StrSubstNo(EditInExcelUsageWithCentralizedDeploymentsTxt, EditinExcelSettings."Use Centralized deployments"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
    end;

    local procedure IsPPE(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(ClientType::Web));
        exit(
          (StrPos(Url, 'projectmadeira-test') <> 0) or (StrPos(Url, 'projectmadeira-ppe') <> 0) or
          (StrPos(Url, 'financials.dynamics-tie.com') <> 0) or (StrPos(Url, 'financials.dynamics-ppe.com') <> 0) or
          (StrPos(Url, 'invoicing.officeppe.com') <> 0) or (StrPos(Url, 'businesscentral.dynamics-tie.com') <> 0) or
          (StrPos(Url, 'businesscentral.dynamics-ppe.com') <> 0));
    end;

    local procedure GetExcelAddinProviderServiceUrl(): Text
    begin
        if IsPPE() then
            exit('https://exceladdinprovider.smb.dynamics-tie.com');
        exit('https://exceladdinprovider.smb.dynamics.com');
    end;

    local procedure GetHostName(): Text
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(GetExcelAddinProviderServiceUrl());
        exit(GetUrl(ClientType::Web));
    end;

    local procedure GetExcelOnlineColumnLimit(): Integer
    begin
        exit(99);
    end;

    local procedure LanguageIDToCultureName(LanguageID: Integer): Text
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.GetCultureInfo(LanguageID);
        exit(CultureInfo.Name);
    end;

}