// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1482 "Edit in Excel Impl."
{
    Access = Internal;
    Permissions = TableData "Tenant Web Service OData" = rimd,
                  TableData "Tenant Web Service Columns" = rimd,
                  TableData "Tenant Web Service Filter" = rimd,
                  TableData "Tenant Web Service" = r;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        EditinExcel: Codeunit "Edit in Excel";
        EditInExcelTelemetryCategoryTxt: Label 'Edit in Excel', Locked = true;
        TenantWebserviceDoesNotExistTxt: Label 'Tenant web service does not exist.', Locked = true;
        TenantWebserviceExistTxt: Label 'Tenant web service exist.', Locked = true;
        CreateEndpointForObjectTxt: Label 'Creating endpoint for %1 %2.', Locked = true;
        EditInExcelHandledTxt: Label 'Edit in excel has been handled.', Locked = true;
        EditInExcelUsageWithCentralizedDeploymentsTxt: Label 'Edit in Excel invoked with "Use Centralized deployments" = %1', Locked = true;
        NoEdmFieldTypeFoundForFieldTypeTxt: Label 'No edm field type could be found for field type %1.', Locked = true;
        CreatingExcelDocumentWithIdTxt: Label 'Creating excel document with id %1.', Locked = true;
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';
        DialogTitleTxt: Label 'Export';
        ExcelFileNameTxt: Text;
        ChildNodesJsonTok: Label 'childNodes', Locked = true;
        TypeJsonTok: Label 'type', Locked = true;
        LeftNodeJsonTok: Label 'leftNode', Locked = true;
        RightNodeJsonTok: Label 'rightNode', Locked = true;
        AlNameJsonTok: Label 'alName', Locked = true;
        NameJsonTok: Label 'name', Locked = true;
        ValueJsonTok: Label 'value', Locked = true;
        TypeNotFoundTxt: Label 'The %1 json token was not found.', Locked = true;
        NodeTypeNotRecognizedTxt: Label 'Node type %1 was not recognized.', Locked = true;
        FilterContainsMultipleOperatorsTxt: Label 'The page filter contains multiple operators, the latter was removed.', Locked = true;

    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text; FileName: Text)
    var
        ServiceName: Text[240];
    begin
        ServiceName := FindOrCreateWorksheetWebService(PageCaption, PageId);
        ExcelFileNameTxt := FileName;
        OnEditInExcelEvent(ServiceName, Filter);
    end;

    procedure EditPageInExcel(PageCaption: Text[240]; PageId: Text; Filter: Text)
    begin
        EditPageInExcel(PageCaption, PageId, Filter, '');
    end;

    procedure GenerateExcelWorkBook(TenantWebService: Record "Tenant Web Service"; SearchFilter: Text)
    var
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
    begin
        if not TenantWebService.Find() then
            exit;

        GenerateExcelWorkBookWithColumns(TenantWebService, TenantWebServiceColumns, SearchFilter, '')
    end;

    #region JSON FILTER SPECIFIC

    procedure GetEndPointAndCreateWorkbookWStructuredFilter(ServiceName: Text[240]; ODataJsonFilter: JsonObject; ODataJsonPayload: JsonObject; SearchFilter: Text)
    var
        TenantWebService: Record "Tenant Web Service";
        DataEntityExportInfo: DotNet DataEntityExportInfo;
    begin
        // Ensure web service exist and is published
        if not TenantWebService.Get(TenantWebService."Object Type"::Page, ServiceName) then
            exit;

        if not TenantWebService.Published then
            Error(WebServiceHasBeenDisabledErr, TenantWebService."Service Name");

        Session.LogMessage('0000DB6', StrSubstNo(CreateEndpointForObjectTxt, TenantWebService."Object Type", TenantWebService."Object ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);

        CreateDataEntityExportInfoStructuredFilter(TenantWebService, DataEntityExportInfo, SearchFilter, ODataJsonFilter, ODataJsonPayload);

        ExportAndDownloadExcelFile(DataEntityExportInfo, TenantWebService);
    end;

    procedure CreateDataEntityExportInfoStructuredFilter(var TenantWebService: Record "Tenant Web Service"; var DataEntityExportInfo: DotNet DataEntityExportInfo; SearchText: Text; ODataJsonFilter: JsonObject; ODataJsonPayload: JsonObject)
    var
        DataEntityInfo: DotNet DataEntityInfo;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        ServiceName: Text;
        PageNumber: Integer;
    begin
        InitializeDataEntityExportInfo(TenantWebService, DataEntityExportInfo, SearchText);

        // Create DataEntityInfo
        DataEntityInfo := DataEntityInfo.DataEntityInfo();
        ServiceName := ExternalizeODataObjectName(TenantWebService."Service Name");
        DataEntityInfo.Name := ServiceName;
        DataEntityInfo.PublicName := ServiceName;
        DataEntityExportInfo.Entities.Add(DataEntityInfo);

        SetupFieldColumnBindings(TenantWebService."Object ID", DataEntityExportInfo, DataEntityInfo);
        PageNumber := TenantWebService."Object ID";

        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();  // One filter collection node for entire entity
        AssembleFilter(EntityFilterCollectionNode, ODataJsonFilter, ODataJsonPayload, PageNumber);

        DataEntityInfo.Filter(EntityFilterCollectionNode);
    end;

    procedure ReduceRedundantFilterCollectionNodes(var EntityFilterCollectionNode: DotNet FilterCollectionNode)
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

    local procedure SetupFieldColumnBindings(PageNo: Integer; var DataEntityExportInfo: DotNet DataEntityExportInfo; var DataEntityInfo: DotNet DataEntityInfo)
    var
        FieldsTable: Record "Field";
        PageControlField: Record "Page Control Field";
        PageMetadata: record "Page Metadata";
        DocumentSharing: Codeunit "Document Sharing";
        RecordRef: RecordRef;
        VarFieldRef: FieldRef;
        VarKeyRef: KeyRef;
        AddedFields: List of [Integer];
        FieldInfo: DotNet "Office.FieldInfo";
        BindingInfo: DotNet BindingInfo;
        KeyFieldNumber: Integer;
        DocumentSharingSource: Enum "Document Sharing Source";
    begin
        BindingInfo := BindingInfo.BindingInfo();
        BindingInfo.EntityName := DataEntityInfo.Name;

        DataEntityExportInfo.Bindings.Add(BindingInfo);

        // Add all fields on the page backed up by a table field
        PageControlField.SetRange(PageNo, PageNo);
        PageControlField.SetCurrentKey(Sequence);
        PageControlField.SetAscending(Sequence, true);
        if PageControlField.FindSet() then
            repeat
                if FieldsTable.Get(PageControlField.TableNo, PageControlField.FieldNo) then
                    if not AddedFields.Contains(PageControlField.FieldNo) then begin // Make sure we don't add the same field twice
                                                                                     // Add field to Excel
                        FieldInfo := FieldInfo.FieldInfo();
                        FieldInfo.Name := ExternalizeODataObjectName(PageControlField.ControlName);
                        FieldInfo.Label := FieldsTable."Field Caption";
                        BindingInfo.Fields.Add(FieldInfo);
                        AddedFields.Add(PageControlField.FieldNo);
                    end;
            until PageControlField.Next() = 0;
        PageMetadata.Get(PageNo);

        RecordRef.Open(PageMetadata.SourceTable);
        VarKeyRef := RecordRef.KeyIndex(1);
        for KeyFieldNumber := 1 to VarKeyRef.FieldCount do begin
            VarFieldRef := VarKeyRef.FieldIndex(KeyFieldNumber);

            if not AddedFields.Contains(VarFieldRef.Number) then begin // Make sure we don't add the same field twice
                FieldInfo := FieldInfo.FieldInfo();
                FieldInfo.Name := ExternalizeODataObjectName(VarFieldRef.Name);
                FieldInfo.Label := VarFieldRef.Caption;
                BindingInfo.Fields.Insert(0, FieldInfo); // Add missing key fields at the beginning
                AddedFields.Add(VarFieldRef.Number);
            end;
        end;

        if DocumentSharing.ShareEnabled(DocumentSharingSource::System) then
            while BindingInfo.Fields.Count() > GetExcelOnlineColumnLimit() do
                BindingInfo.Fields.RemoveAt(BindingInfo.Fields.Count() - 1); // If we use excel online, only include supported number of columns
    end;

    procedure AssembleFilter(var EntityFilterCollectionNode: DotNet FilterCollectionNode; ODataJsonFilter: JsonObject; ODataJsonPayload: JsonObject; PageNumber: Integer)
    var
        ChildFilterCollectionNode: DotNet FilterCollectionNode;
        FieldFilterGroupingOperator: Dictionary of [Text, Text];
        FilterNodes: DotNet GenericDictionary2;
    begin
        FilterNodes := FilterNodes.Dictionary();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
        ConvertStructuredFiltersToEntityFilterCollection(ODataJsonFilter, ODataJsonPayload, FieldFilterGroupingOperator, PageNumber, "Excel Filter Node Type"::"and", FilterNodes);

        if not IsNull(FilterNodes) then
            foreach ChildFilterCollectionNode in FilterNodes.Values do
                if ChildFilterCollectionNode.Collection.Count() > 0 then
                    if ChildFilterCollectionNode.Collection.Count() = 1 then
                        // When we only have 1 value in the filter we should not wrap it in a collection
                        EntityFilterCollectionNode.Collection.Add(ChildFilterCollectionNode.Collection.Item(0))
                    else
                        EntityFilterCollectionNode.Collection.Add(ChildFilterCollectionNode);
        ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);
    end;

    procedure ConvertStructuredFiltersToEntityFilterCollection(StructuredFilterObject: JsonObject; var ODataJsonPayload: JsonObject; var FieldFilterGroupingOperator: Dictionary of [Text, Text]; PageNumber: Integer; ParentGroupingOperator: Enum "Excel Filter Node Type"; var FilterNodes: DotNet GenericDictionary2)
    var
        FieldFilterCollectionNode: DotNet FilterCollectionNode;
        FilterLeftOperand: DotNet FilterLeftOperand;
        FilterBinaryNode: DotNet FilterBinaryNode;
        ChildNodesJsonFilterArray: JsonArray;
        TypeJsonToken: JsonToken;
        ChildNodesJsonToken: JsonToken;
        ExcelFilterNodeType: Enum "Excel Filter Node Type";
        NodeType: Text;
        FieldGroupingOperator: Text;
        RightNodeName: Text;
    begin
        if not StructuredFilterObject.Get(TypeJsonTok, TypeJsonToken) then begin
            Session.LogMessage('0000I3U', StrSubstNo(TypeNotFoundTxt, TypeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        NodeType := TypeJsonToken.AsValue().AsText().ToLower();
        if not Enum::"Excel Filter Node Type".Names().Contains(NodeType) then begin
            Session.LogMessage('0000I3V', StrSubstNo(NodeTypeNotRecognizedTxt, NodeType), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        ExcelFilterNodeType := "Excel Filter Node Type".FromInteger("Excel Filter Node Type".Ordinals().Get("Excel Filter Node Type".Names().IndexOf(NodeType)));
        case ExcelFilterNodeType of
            "Excel Filter Node Type"::"and", "Excel Filter Node Type"::"or":
                begin
                    if not StructuredFilterObject.Get(ChildNodesJsonTok, ChildNodesJsonToken) then begin
                        Session.LogMessage('0000I3W', StrSubstNo(TypeNotFoundTxt, ChildNodesJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
                        exit;
                    end;

                    ChildNodesJsonFilterArray := ChildNodesJsonToken.AsArray();
                    foreach ChildNodesJsonToken in ChildNodesJsonFilterArray do
                        ConvertStructuredFiltersToEntityFilterCollection(ChildNodesJsonToken.AsObject(), ODataJsonPayload, FieldFilterGroupingOperator, PageNumber, ExcelFilterNodeType, FilterNodes);
                end;
            "Excel Filter Node Type"::lt, "Excel Filter Node Type"::le, "Excel Filter Node Type"::eq, "Excel Filter Node Type"::ge, "Excel Filter Node Type"::gt, "Excel Filter Node Type"::ne:
                begin
                    FilterBinaryNode := FilterBinaryNode.FilterBinaryNode();
                    FilterBinaryNode.Operator := NodeType;
                    if not GetLeftNodeValue(StructuredFilterObject, ODataJsonPayload, FilterLeftOperand) and GetRightNodeValue(StructuredFilterObject, RightNodeName) then
                        exit;
                    FilterBinaryNode.Left := FilterLeftOperand;
                    FilterBinaryNode.Right := RightNodeName;

                    if not FieldFilterGroupingOperator.Get(FilterLeftOperand.Field, FieldGroupingOperator) then
                        FieldFilterGroupingOperator.Add(FilterLeftOperand.Field, format(ParentGroupingOperator))
                    else
                        if FieldGroupingOperator <> format(ParentGroupingOperator) then begin
                            Session.LogMessage('0000I3X', FilterContainsMultipleOperatorsTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
                            exit; // OData does not support filtering on a field with both 'and' and 'or' hence if we see both, ignore the second type
                        end;
                    if not FilterNodes.ContainsKey(FilterLeftOperand.Field) then begin // If that field doesnt have a collection node yet, create it
                        FieldFilterCollectionNode := FieldFilterCollectionNode.FilterCollectionNode();
                        FieldFilterCollectionNode.Operator := format(ParentGroupingOperator);
                        FilterNodes.Add(FilterLeftOperand.Field, FieldFilterCollectionNode)
                    end;
                    FieldFilterCollectionNode := FilterNodes.Item(FilterLeftOperand.Field);
                    FieldFilterCollectionNode.Collection.Add(FilterBinaryNode);
                end;
        end;
    end;

    local procedure GetLeftNodeValue(JsonFilterObject: JsonObject; ODataJsonPayload: JsonObject; var FilterLeftOperand: DotNet FilterLeftOperand): Boolean
    var
        NodeJsonToken: JsonToken;
        NameJsonToken: JsonToken;
        TypeJsonToken: JsonToken;
        AlNameJsonToken: JsonToken;
    begin
        if not JsonFilterObject.Get(LeftNodeJsonTok, NodeJsonToken) then begin
            Session.LogMessage('0000I3Y', StrSubstNo(TypeNotFoundTxt, LeftNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        if not NodeJsonToken.AsObject().Get(NameJsonTok, NameJsonToken) then begin
            Session.LogMessage('0000I3Z', StrSubstNo(TypeNotFoundTxt, NameJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        FilterLeftOperand := FilterLeftOperand.FilterLeftOperand();
        FilterLeftOperand.Field := NameJsonToken.AsValue().AsText();

        if not ODataJsonPayload.SelectToken(StrSubstNo('fieldPayload.%1.edmType', FilterLeftOperand.Field), TypeJsonToken) then begin
            Session.LogMessage('0000I40', StrSubstNo(TypeNotFoundTxt, LeftNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;
        FilterLeftOperand.Type := TypeJsonToken.AsValue().AsText();

        if not ODataJsonPayload.SelectToken(StrSubstNo('fieldPayload.%1.alName', FilterLeftOperand.Field), AlNameJsonToken) then begin
            Session.LogMessage('0000I5T', StrSubstNo(TypeNotFoundTxt, AlNameJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetRightNodeValue(JsonFilterObject: JsonObject; var RightNodeName: Text): Boolean
    var
        NodeJsonToken: JsonToken;
        NameJsonToken: JsonToken;
    begin
        if not JsonFilterObject.Get(RightNodeJsonTok, NodeJsonToken) then begin
            Session.LogMessage('0000I41', StrSubstNo(TypeNotFoundTxt, RightNodeJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;
        if not NodeJsonToken.AsObject().Get(ValueJsonTok, NameJsonToken) then begin
            Session.LogMessage('0000I42', StrSubstNo(TypeNotFoundTxt, ValueJsonTok), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit(false);
        end;

        RightNodeName := NameJsonToken.AsValue().AsText();
        exit(true);
    end;

    #endregion JSON FILTER SPECIFIC

    local procedure GenerateExcelWorkBookWithColumns(TenantWebService: Record "Tenant Web Service"; var TenantWebServiceColumns: Record "Tenant Web Service Columns" temporary; SearchFilter: Text; FilterClause: Text)
    var
        DataEntityExportInfo: DotNet DataEntityExportInfo;
    begin
        DataEntityExportInfo := DataEntityExportInfo.DataEntityExportInfo();
        CreateDataEntityExportInfo(TenantWebService, DataEntityExportInfo, TenantWebServiceColumns, SearchFilter, FilterClause);

        ExportAndDownloadExcelFile(DataEntityExportInfo, TenantWebService);
    end;

    local procedure ExportAndDownloadExcelFile(var DataEntityExportInfo: DotNet DataEntityExportInfo; TenantWebService: Record "Tenant Web Service")
    var
        DataEntityExportGenerator: DotNet DataEntityExportGenerator;
        MemoryStream: DotNet MemoryStream;
    begin
        DataEntityExportGenerator := DataEntityExportGenerator.DataEntityExportGenerator();
        MemoryStream := MemoryStream.MemoryStream();
        DataEntityExportGenerator.GenerateWorkbook(DataEntityExportInfo, MemoryStream);
        if ExcelFileNameTxt = '' then
            ExcelFileNameTxt := GenerateExcelFileName(TenantWebService);
        ExcelFileNameTxt := ExcelFileNameTxt + '.xlsx';
        DownloadExcelFile(MemoryStream, ExcelFileNameTxt);
    end;

    local procedure GenerateExcelFileName(TenantWebService: Record "Tenant Web Service") FileName: Text
    var
        PageMetadata: Record "Page Metadata";
        QueryMetadata: Record "Query Metadata";
        CodeunitMetadata: Record "CodeUnit Metadata";
    begin
        case TenantWebService."Object Type" of
            TenantWebService."Object Type"::Page:
                if PageMetadata.Get(TenantWebService."Object ID") then
                    FileName := PageMetadata.Caption;
            TenantWebService."Object Type"::Query:
                if QueryMetadata.Get(TenantWebService."Object ID") then
                    FileName := QueryMetadata.Caption;
            TenantWebService."Object Type"::Codeunit:
                if CodeunitMetadata.Get(TenantWebService."Object ID") then
                    FileName := CodeunitMetadata.Name;
        end;

        if FileName = '' then
            FileName := TenantWebService."Service Name".Replace('_Excel', '');
    end;

    internal procedure CreateDataEntityExportInfo(var TenantWebService: Record "Tenant Web Service"; var DataEntityExportInfoParam: DotNet DataEntityExportInfo; var TenantWebServiceColumns: Record "Tenant Web Service Columns"; SearchText: Text; FilterClause: Text)
    var
        DocumentSharing: Codeunit "Document Sharing";
        DocumentSharingSource: Enum "Document Sharing Source";
        DataEntityInfo: DotNet DataEntityInfo;
        BindingInfo: DotNet BindingInfo;
        FieldInfo: DotNet "Office.FieldInfo";
        FieldFilterCollectionNode: DotNet FilterCollectionNode;
        FieldFilterCollectionNode2: DotNet FilterCollectionNode;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        ServiceName: Text;
        FieldFilterCounter: Integer;
        Inserted: Boolean;
        DocumentSharingEnabled: Boolean;
    begin
        InitializeDataEntityExportInfo(TenantWebService, DataEntityExportInfoParam, SearchText);

        DataEntityInfo := DataEntityInfo.DataEntityInfo();
        ServiceName := ExternalizeODataObjectName(TenantWebService."Service Name");
        DataEntityInfo.Name := ServiceName;
        DataEntityInfo.PublicName := ServiceName;
        DataEntityExportInfoParam.Entities.Add(DataEntityInfo);

        BindingInfo := BindingInfo.BindingInfo();
        BindingInfo.EntityName := DataEntityInfo.Name;

        DataEntityExportInfoParam.Bindings.Add(BindingInfo);

        TenantWebServiceColumns.Init();
        TenantWebServiceColumns.SetRange(TenantWebServiceID, TenantWebService.RecordId);
        TenantWebServiceColumns.SetAutoCalcFields("Field Caption");

        DocumentSharingEnabled := DocumentSharing.ShareEnabled(DocumentSharingSource::System);

        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();  // One filter collection node for entire entity
        if TenantWebServiceColumns.FindSet() then begin
            repeat
                // Add field to Excel
                if (not DocumentSharingEnabled) or (BindingInfo.Fields.Count() < GetExcelOnlineColumnLimit()) then begin // If we use excel online, only include supported number of columns
                    FieldInfo := FieldInfo.FieldInfo();
                    FieldInfo.Name := TenantWebServiceColumns."Field Name";
                    if TenantWebServiceColumns."Field Caption" <> '' then
                        FieldInfo.Label := TenantWebServiceColumns."Field Caption"
                    else
                        FieldInfo.Label := TenantWebServiceColumns."Field Name";
                    BindingInfo.Fields.Add(FieldInfo);
                end;

                // Create filter for field
                Inserted := InsertDataIntoFilterCollectionNode(TenantWebServiceColumns."Field Name", ExternalizeODataObjectName(GetFilterFieldName(TenantWebServiceColumns)), GetFieldType(TenantWebServiceColumns),
                    FilterClause, EntityFilterCollectionNode, FieldFilterCollectionNode, FieldFilterCollectionNode2);

                if Inserted then
                    FieldFilterCounter += 1;

                if FieldFilterCounter > 1 then
                    EntityFilterCollectionNode.Operator('and');  // All fields are anded together

            until TenantWebServiceColumns.Next() = 0;
            AddFieldNodeToEntityNode(FieldFilterCollectionNode, FieldFilterCollectionNode2, EntityFilterCollectionNode);
        end;

        DataEntityInfo.Filter(EntityFilterCollectionNode);
    end;

    local procedure InitializeDataEntityExportInfo(TenantWebService: Record "Tenant Web Service"; var DataEntityExportInfo: DotNet DataEntityExportInfo; SearchText: Text)
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

        if SearchText <> '' then
            DataEntityExportInfo.Headers.Add('pageSearchString', DelChr(SearchText, '=', '@*'));
    end;

    local procedure FindOrCreateWorksheetWebService(PageCaption: Text[240]; PageId: Text): Text[240]
    var
        TenantWebService: Record "Tenant Web Service";
        ObjectId: Integer;
        ServiceName: Text[240];
    begin
        // Aligned with how platform finds and creates web services
        // The function returns the first web service name that matches:
        // 1. Name is PageCaption_Excel (this allows admin to Publish/Unpublish the web service and be in complete control over whether Edit in Excel works)
        // 2. Published flag = true (prefer enabled web services)
        // 3. Any web service for the page
        // 4. Create a new web service called PageCaption_Excel

        Evaluate(ObjectId, CopyStr(PageId, 5));
        if NameBeginsWithADigit(PageCaption) then
            ServiceName := 'WS' + CopyStr(PageCaption, 1, 232) + '_Excel'
        else
            ServiceName := CopyStr(PageCaption, 1, 234) + '_Excel';

        if TenantWebService.Get(TenantWebService."Object Type"::Page, ServiceName) and (TenantWebService."Object ID" = ObjectId) then
            exit(ServiceName);

        TenantWebService."Object Type" := TenantWebService."Object Type"::Page;
        TenantWebService."Object ID" := ObjectId;
        TenantWebService."Service Name" := ServiceName;
        TenantWebService.ExcludeFieldsOutsideRepeater := true;
        TenantWebService.ExcludeNonEditableFlowFields := true;
        TenantWebService.Published := true;
        TenantWebService.Insert(true);
        exit(ServiceName);
    end;

    local procedure NameBeginsWithADigit(Name: text[240]): Boolean
    begin
        if Name[1] in ['0' .. '9'] then
            exit(true);
        exit(false);
    end;

    local procedure DownloadExcelFile(MemoryStream: DotNet MemoryStream; FileName: Text)
    var
        DocumentSharing: Codeunit "Document Sharing";
        DocumentSharingIntent: Enum "Document Sharing Intent";
        DocumentSharingSource: Enum "Document Sharing Source";
    begin
        if DocumentSharing.ShareEnabled(DocumentSharingSource::System) then begin
            DocumentSharing.Share(FileName, '.xlsx', MemoryStream, DocumentSharingIntent::Open, DocumentSharingSource::System);
            exit;
        end;

        DownloadFromStream(MemoryStream, DialogTitleTxt, '', '*.*', FileName);
    end;

    local procedure GetConjunctionString(var localFilterSegments: DotNet Array; var ConjunctionStringParam: Text; var IndexParam: Integer)
    begin
        if IndexParam < localFilterSegments.Length then begin
            ConjunctionStringParam := localFilterSegments.GetValue(IndexParam);
            IndexParam += 1;
        end else
            ConjunctionStringParam := '';
    end;

    local procedure GetNextFieldString(var localFilterSegments: DotNet Array; var NextFieldStringParam: Text; var IndexParam: Integer)
    begin
        if IndexParam < localFilterSegments.Length then begin
            NextFieldStringParam := localFilterSegments.GetValue(IndexParam);
            IndexParam += 1;
        end else
            NextFieldStringParam := '';
    end;

    local procedure TrimFilterClause(var FilterClauseParam: Text)
    begin
        if StrPos(FilterClauseParam, 'filter=') <> 0 then
            FilterClauseParam := DelStr(FilterClauseParam, 1, StrPos(FilterClauseParam, 'filter=') + 6);

        // becomes  ((No ge '01121212' and No le '01445544') or No eq '10000') and ((Name eq 'bob') and Name eq 'frank')
        FilterClauseParam := DelChr(FilterClauseParam, '<', '(');
        FilterClauseParam := DelChr(FilterClauseParam, '>', ')');
        // becomes  (No ge '01121212' and No le '01445544') or No eq '10000') and ((Name eq 'bob') and Name eq 'frank'
    end;

    local procedure GetEndPointAndCreateWorkbook(ServiceName: Text[240]; ODataFilter: Text; SearchFilter: Text)
    var
        TenantWebService: Record "Tenant Web Service";
        TenantWebServiceOData: Record "Tenant Web Service OData";
        TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary;
        WebServiceManagement: Codeunit "Web Service Management";
        FieldIdToFieldName: DotNet GenericDictionary2;
        TableNo: Integer;
    begin
        FieldIdToFieldName := FieldIdToFieldName.Dictionary();

        if not TenantWebService.Get(TenantWebService."Object Type"::Page, ServiceName) then
            exit;

        if not TenantWebService.Published then
            Error(WebServiceHasBeenDisabledErr, TenantWebService."Service Name");

        Session.LogMessage('0000DB6', StrSubstNo(CreateEndpointForObjectTxt, TenantWebService."Object Type", TenantWebService."Object ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);

        // Find columns to show in Excel
        InitColumnsForPage(TenantWebService, FieldIdToFieldName, TableNo);

        // If we don't have an endpoint - we need a new endpoint
        TenantWebServiceOData.SetRange(TenantWebServiceID, TenantWebService.RecordId);
        if TenantWebServiceOData.IsEmpty() then begin
            Session.LogMessage('0000DB3', TenantWebserviceDoesNotExistTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            InsertODataRecord(TenantWebService);
        end else
            Session.LogMessage('0000DB4', TenantWebserviceExistTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);

        WebServiceManagement.InsertSelectedColumns(TenantWebService, FieldIdToFieldName, TempTenantWebServiceColumns, TableNo);
        GenerateExcelWorkBookWithColumns(TenantWebService, TempTenantWebServiceColumns, SearchFilter, ODataFilter);
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

    local procedure InsertDataIntoFilterCollectionNode(ControlFieldName: Text; FilterFieldName: Text; FieldType: Text; FilterClause: Text; var EntityFilterCollectionNode: DotNet FilterCollectionNode; var FieldFilterCollectionNode: DotNet FilterCollectionNode; var FieldFilterCollectionNode2: DotNet FilterCollectionNode): Boolean
    var
        FilterBinaryNode: DotNet FilterBinaryNode;
        FilterLeftOperand: DotNet FilterLeftOperand;
        ValueString: DotNet String;
        Regex: DotNet Regex;
        FilterSegments: DotNet Array;
        ConjunctionString: Text;
        OldConjunctionString: Text;
        NextFieldString: Text;
        Index: Integer;
        NumberOfCharsTrimmed: Integer;
        TrimPos: Integer;
        FilterCreated: Boolean;
    begin
        // New column, if the previous row had data, add it entity filter collection
        AddFieldNodeToEntityNode(FieldFilterCollectionNode, FieldFilterCollectionNode2, EntityFilterCollectionNode);

        TrimPos := 0;
        Index := 1;
        OldConjunctionString := '';
        // $filter=((No ge '01121212' and No le '01445544') or No eq '10000') and ((Name eq 'bo b') and Name eq 'fra nk')
        if FilterClause <> '' then begin
            TrimFilterClause(FilterClause);

#pragma warning disable AA0217
            if Regex.IsMatch(FilterClause, StrSubstNo('\b%1 \b', FilterFieldName)) then begin
#pragma warning restore
                FilterClause := CopyStr(FilterClause, StrPos(FilterClause, FilterFieldName + ' '));

                while FilterClause <> '' do begin
                    FilterCreated := true;
                    FilterBinaryNode := FilterBinaryNode.FilterBinaryNode();
                    FilterLeftOperand := FilterLeftOperand.FilterLeftOperand();

                    FilterLeftOperand.Field(ControlFieldName);
                    FilterLeftOperand.Type(FieldType);

                    FilterBinaryNode.Left := FilterLeftOperand;
                    FilterSegments := Regex.Split(FilterClause, ' ');

                    FilterBinaryNode.Operator(FilterSegments.GetValue(1));
                    ValueString := FilterSegments.GetValue(2);
                    Index := 3;

                    NumberOfCharsTrimmed := ConcatValueStringPortions(ValueString, FilterSegments, Index);

                    FilterBinaryNode.Right(ValueString);

                    TrimPos := StrPos(FilterClause, ValueString) + StrLen(ValueString) + NumberOfCharsTrimmed;

                    GetConjunctionString(FilterSegments, ConjunctionString, Index);

                    GetNextFieldString(FilterSegments, NextFieldString, Index);

                    TrimPos := TrimPos + StrLen(ConjunctionString) + StrLen(NextFieldString);

                    if (NextFieldString = '') or (NextFieldString = ControlFieldName) then begin
                        if (OldConjunctionString <> '') and (OldConjunctionString <> ConjunctionString) then begin
                            if IsNull(FieldFilterCollectionNode2) then begin
                                FieldFilterCollectionNode2 := FieldFilterCollectionNode2.FilterCollectionNode();
                                FieldFilterCollectionNode2.Operator(ConjunctionString);
                            end;

                            FieldFilterCollectionNode.Collection.Add(FilterBinaryNode);
                            if OldConjunctionString <> '' then
                                FieldFilterCollectionNode.Operator(OldConjunctionString);

                            FieldFilterCollectionNode2.Collection.Add(FieldFilterCollectionNode);

                            Clear(FieldFilterCollectionNode);
                        end else begin
                            if IsNull(FieldFilterCollectionNode) then
                                FieldFilterCollectionNode := FieldFilterCollectionNode.FilterCollectionNode();

                            FieldFilterCollectionNode.Collection.Add(FilterBinaryNode);
                            FieldFilterCollectionNode.Operator(OldConjunctionString)
                        end
                    end else begin
                        if IsNull(FieldFilterCollectionNode2) then
                            FieldFilterCollectionNode2 := FieldFilterCollectionNode2.FilterCollectionNode();

                        if IsNull(FieldFilterCollectionNode) then
                            FieldFilterCollectionNode := FieldFilterCollectionNode.FilterCollectionNode();

                        FieldFilterCollectionNode.Collection.Add(FilterBinaryNode);
                        FieldFilterCollectionNode.Operator(OldConjunctionString);

                        FieldFilterCollectionNode2.Collection.Add(FieldFilterCollectionNode);

                        Clear(FieldFilterCollectionNode);

                        FilterClause := ''; // the FilterClause is exhausted for this field
                    end;

                    OldConjunctionString := ConjunctionString;

                    FilterClause := CopyStr(FilterClause, TrimPos); // remove that portion that has been processed.
                end;
            end;
        end;
        exit(FilterCreated);
    end;

    local procedure IsFilteringForEmptyString(FilterStringParam: DotNet String): Boolean
    begin
        exit(FilterStringParam = '''''');
    end;

    local procedure ConcatValueStringPortions(var FilterStringParam: DotNet String; var FilterSegmentsParam: DotNet Array; var Index: Integer): Integer
    var
        ValueStringPortion: Text;
        LastPosition: Integer;
        FirstPosition: Integer;
        SingleTick: Char;
        StrLenAfterTrim: Integer;
        StrLenBeforeTrim: Integer;
    begin
        SingleTick := 39;
        if IsFilteringForEmptyString(FilterStringParam) then
            exit(0); // In this case we did not concatenate or trim anything

        FirstPosition := FilterStringParam.IndexOf(SingleTick);
        LastPosition := FilterStringParam.LastIndexOf(SingleTick);

        // The valueString might have been spit earlier if it had an embedded ' ', stick it back together
        if (FirstPosition = 0) and (FirstPosition = LastPosition) then
            repeat
                ValueStringPortion := FilterSegmentsParam.GetValue(Index);
                FilterStringParam := FilterStringParam.Concat(FilterStringParam, ' ');
                FilterStringParam := FilterStringParam.Concat(FilterStringParam, ValueStringPortion);
                ValueStringPortion := FilterSegmentsParam.GetValue(Index);
                Index += 1;
            until ValueStringPortion.LastIndexOf(SingleTick) > 0;

        // Now that the string has been put back together if needed, remove leading and trailing SingleTick
        // as the excel addin will apply them.
        FirstPosition := FilterStringParam.IndexOf(SingleTick);

        StrLenBeforeTrim := StrLen(FilterStringParam);
        if FirstPosition = 0 then begin
            FilterStringParam := DelStr(FilterStringParam, 1, 1);
            LastPosition := FilterStringParam.LastIndexOf(SingleTick);
            if LastPosition > 0 then begin
                FilterStringParam := DelChr(FilterStringParam, '>', ')'); // Remove any trailing ')'
                FilterStringParam := DelStr(FilterStringParam, FilterStringParam.Length, 1);
            end;
        end;

        StrLenAfterTrim := StrLen(FilterStringParam);
        exit(StrLenBeforeTrim - StrLenAfterTrim);
    end;

    local procedure GetFilterFieldName(TenantWebServiceColumnsParam: Record "Tenant Web Service Columns"): Text
    var
        FieldTable: Record Field;
    begin
        if FieldTable.Get(TenantWebServiceColumnsParam."Data Item", TenantWebServiceColumnsParam."Field Number") then
            exit(FieldTable.FieldName);
        exit(TenantWebServiceColumnsParam."Field Name");
    end;

    local procedure GetFieldType(TenantWebServiceColumnsParam: Record "Tenant Web Service Columns"): Text
    var
        FieldTable: Record Field;
    begin
        FieldTable.SetRange(TableNo, TenantWebServiceColumnsParam."Data Item");
        FieldTable.SetRange("No.", TenantWebServiceColumnsParam."Field Number");
        if FieldTable.FindFirst() then
            case FieldTable.Type of
                FieldTable.Type::Text, FieldTable.Type::Code, FieldTable.Type::OemCode, FieldTable.Type::OemText, FieldTable.Type::Option:
                    exit('Edm.String');
                FieldTable.Type::BigInteger, FieldTable.Type::Integer:
                    exit('Edm.Int32');
                FieldTable.Type::Decimal:
                    exit('Edm.Decimal');
                FieldTable.Type::Date, FieldTable.Type::DateTime, FieldTable.Type::Time:
                    exit('Edm.DateTimeOffset');
                FieldTable.Type::Boolean:
                    exit('Edm.Boolean');
            end;

        Session.LogMessage('0000FEW', StrSubstNo(NoEdmFieldTypeFoundForFieldTypeTxt, FieldTable.Type), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
    end;

    local procedure AddFieldNodeToEntityNode(var FieldFilterCollectionNodeParam: DotNet FilterCollectionNode; var FieldFilterCollectionNode2Param: DotNet FilterCollectionNode; var EntityFilterCollectionNodeParam: DotNet FilterCollectionNode)
    begin
        if not IsNull(FieldFilterCollectionNode2Param) then begin
            EntityFilterCollectionNodeParam.Collection.Add(FieldFilterCollectionNode2Param);
            Clear(FieldFilterCollectionNode2Param);
        end;

        if not IsNull(FieldFilterCollectionNodeParam) then begin
            EntityFilterCollectionNodeParam.Collection.Add(FieldFilterCollectionNodeParam);
            Clear(FieldFilterCollectionNodeParam);
        end;
    end;

    local procedure InitColumnsForPage(TenantWebService: Record "Tenant Web Service"; ColumnDictionary: DotNet GenericDictionary2; var SourceTableNo: Integer)
    var
        FieldsTable: Record "Field";
        PageControlField: Record "Page Control Field";
        FieldNameText: Text;
    begin
        PageControlField.SetRange(PageNo, TenantWebService."Object ID");
        PageControlField.SetCurrentKey(Sequence);
        PageControlField.SetAscending(Sequence, true);
        if PageControlField.FindSet() then
            repeat
                SourceTableNo := PageControlField.TableNo;

                if FieldsTable.Get(PageControlField.TableNo, PageControlField.FieldNo) then
                    if not ColumnDictionary.ContainsKey(FieldsTable."No.") then begin
                        // Convert to OData compatible name.
                        FieldNameText := ExternalizeODataObjectName(PageControlField.ControlName);
                        ColumnDictionary.Add(FieldsTable."No.", FieldNameText);
                    end;
            until PageControlField.Next() = 0;

        EnsureKeysInSelect(SourceTableNo, ColumnDictionary);
    end;

    local procedure EnsureKeysInSelect(SourceTableNo: Integer; ColumnDictionary: DotNet GenericDictionary2)
    var
        RecordRef: RecordRef;
        VarFieldRef: FieldRef;
        VarKeyRef: KeyRef;
        KeysText: DotNet String;
        i: Integer;
    begin
        RecordRef.Open(SourceTableNo);
        VarKeyRef := RecordRef.KeyIndex(1);
        for i := 1 to VarKeyRef.FieldCount do begin
            VarFieldRef := VarKeyRef.FieldIndex(i);
            KeysText := ExternalizeODataObjectName(VarFieldRef.Name);

            if not ColumnDictionary.ContainsKey(VarFieldRef.Number) then
                ColumnDictionary.Add(VarFieldRef.Number, KeysText);
        end;
    end;

    local procedure InsertODataRecord(var TenantWebService: Record "Tenant Web Service")
    var
        TenantWebServiceOData: Record "Tenant Web Service OData";
    begin
        TenantWebServiceOData.Init();
        TenantWebServiceOData.Validate(TenantWebServiceID, TenantWebService.RecordId);
        TenantWebServiceOData.Insert(true);
    end;

    procedure ExternalizeODataObjectName(Name: Text) ConvertedName: Text
    var
        CurrentPosition: Integer;
        Convert: DotNet Convert;
        ByteValue: DotNet Byte;
    begin
        ConvertedName := Name;

        if NameBeginsWithADigit(ConvertedName[1]) then begin
            ByteValue := Convert.ToByte(ConvertedName[1]);
            ConvertedName := CopyStr(ConvertedName, 2);
            ConvertedName := StrSubstNo('_x00%1_%2', Convert.ToString(ByteValue, 16), ConvertedName);
        end;

        // Mimics the behavior of the compiler when converting a field or web service name to OData.
        CurrentPosition := StrPos(ConvertedName, '%');
        while CurrentPosition > 0 do begin
            ConvertedName := DelStr(ConvertedName, CurrentPosition, 1);
            ConvertedName := InsStr(ConvertedName, 'Percent', CurrentPosition);
            CurrentPosition := StrPos(ConvertedName, '%');
        end;

        CurrentPosition := 1;

        while CurrentPosition <= StrLen(ConvertedName) do begin
            if ConvertedName[CurrentPosition] in [' ', '\', '/', '''', '"', '.', '(', ')', '-', ':'] then
                if CurrentPosition > 1 then begin
                    if ConvertedName[CurrentPosition - 1] = '_' then begin
                        ConvertedName := DelStr(ConvertedName, CurrentPosition, 1);
                        CurrentPosition -= 1;
                    end else
                        ConvertedName[CurrentPosition] := '_';
                end else
                    ConvertedName[CurrentPosition] := '_';

            CurrentPosition += 1;
        end;

        ConvertedName := DelChr(ConvertedName, '>', '_'); // remove trailing underscore
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OnEditInExcel', '', false, false)]
    local procedure LegacyOnEditInExcelEvent(ServiceName: Text[240]; ODataFilter: Text)
    var
        Handled: Boolean;
    begin
        if StrPos(ODataFilter, '$filter=') = 0 then
#pragma warning disable AA0217
            ODataFilter := StrSubstNo('%1%2', '$filter=', ODataFilter);
#pragma warning restore
        EditinExcel.OnEditInExcel(ServiceName, ODataFilter, '', Handled);
        if Handled then begin
            Session.LogMessage('0000F7M', EditInExcelHandledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;
    end;

    local procedure OnEditInExcelEvent(ServiceName: Text[240]; ODataFilter: Text)
    var
        Handled: Boolean;
    begin
        if StrPos(ODataFilter, '$filter=') = 0 then
#pragma warning disable AA0217
            ODataFilter := StrSubstNo('%1%2', '$filter=', ODataFilter);
#pragma warning restore
        EditinExcel.OnEditInExcel(ServiceName, ODataFilter, '', Handled);
        if Handled then begin
            Session.LogMessage('0000F7M', EditInExcelHandledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        GetEndPointAndCreateWorkbook(ServiceName, ODataFilter, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OnEditInExcelWithSearchString', '', false, false)]
    local procedure OnEditInExcelWithSearchStringEvent(ServiceName: Text[240]; ODataFilter: Text; SearchString: Text)
    var
        Handled: Boolean;
    begin
        if StrPos(ODataFilter, '$filter=') = 0 then
#pragma warning disable AA0217
            ODataFilter := StrSubstNo('%1%2', '$filter=', ODataFilter);
#pragma warning restore
        EditinExcel.OnEditInExcel(ServiceName, ODataFilter, SearchString, Handled);
        if Handled then begin
            Session.LogMessage('0000F7N', EditInExcelHandledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'OnEditInExcelWithStructuredFilter', '', false, false)]
    local procedure OnEditInExcelWithStructuredFilterEvent(ServiceName: Text[240]; SearchString: Text; Filter: JsonObject; Payload: JsonObject)
    var
        Handled: Boolean;
    begin
        EditinExcel.OnEditInExcelWithStructuredFilter(ServiceName, Filter, Payload, SearchString, Handled);
        if Handled then begin
            Session.LogMessage('0000I43', EditInExcelHandledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EditInExcelTelemetryCategoryTxt);
            exit;
        end;

        GetEndPointAndCreateWorkbookWStructuredFilter(ServiceName, Filter, Payload, SearchString);
    end;
}
