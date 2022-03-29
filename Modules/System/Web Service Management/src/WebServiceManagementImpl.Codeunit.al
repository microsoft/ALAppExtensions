// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9751 "Web Service Management Impl."
{
    Access = Internal;
    Permissions = tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
                  tabledata Field = r,
                  tabledata "Tenant Web Service" = rimd,
                  tabledata "Web Service" = rimd,
                  tabledata "Tenant Web Service Columns" = imd,
                  tabledata "Tenant Web Service Filter" = imd,
                  tabledata "Tenant Web Service OData" = imd,
                  tabledata "Web Service Aggregate" = imd;


    var
        ODataProtocolVersion: Enum "OData Protocol Version";
        NotApplicableTxt: Label 'Not applicable';
        WebServiceNameNotValidErr: Label 'The service name is not valid.';
        StartCharacterExpTxt: Label '[\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Lm}\p{Nl}]', Locked = true;
        OtherCharacterExpTxt: Label '[\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Lm}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}\p{Cf}]', Locked = true;
        WebServiceAlreadyPublishedErr: Label 'The web service name %1 already exists.  Enter a different service name.', Comment = '%1 = Web Service name';
        WebServiceNotAllowedErr: Label 'The web service cannot be added because it conflicts with an unpublished system web service for the object.';
        WebServiceModNotAllowedErr: Label 'The web service cannot be modified because it conflicts with an unpublished system web service for the object.';
        WebServiceDeleteAttemptTxt: Label 'Attempt to delete a web service', Locked = true;
        WebServiceDeletedTxt: Label 'Web Service Deleted', Locked = true;
        TenantWebServiceDeletedTxt: Label 'Tenant Web Service Deleted', Locked = true;
        ODataUnboundActionHelpUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2138827', Locked = true;

    procedure CreateWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
    var
        AllObj: Record AllObj;
        WebService: Record "Web Service";
        WebServiceName: Text;
    begin
        AllObj.Get(ObjectType, ObjectId);
        WebServiceName := GetWebServiceName(ObjectName, AllObj."Object Name");

        if WebService.Get(ObjectType, WebServiceName) then begin
            ModifyWebService(WebService, AllObj, WebServiceName, Published);
            WebService.Modify();
        end else begin
            WebService.Init();
            ModifyWebService(WebService, AllObj, WebServiceName, Published);
            WebService.Insert();
        end
    end;

    procedure CreateTenantWebService(ObjectType: Option; ObjectId: Integer; ObjectName: Text; Published: Boolean)
    var
        AllObj: Record AllObj;
        TenantWebService: Record "Tenant Web Service";
        WebServiceName: Text;
    begin
        AllObj.Get(ObjectType, ObjectId);
        WebServiceName := GetWebServiceName(ObjectName, AllObj."Object Name");

        if TenantWebService.Get(ObjectType, WebServiceName) then begin
            ModifyTenantWebService(TenantWebService, AllObj, WebServiceName, Published);
            TenantWebService.Modify();
        end else begin
            TenantWebService.Init();
            ModifyTenantWebService(TenantWebService, AllObj, WebServiceName, Published);
            TenantWebService.Insert();
        end
    end;

    procedure GetWebServiceUrl(WebServiceAggregate: Record "Web Service Aggregate"; ClientTypeParam: Enum "Client Type"): Text
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        ODataServiceRootUrl: Text;
    begin
        if WebServiceAggregate."All Tenants" then begin
            WebService.Init();
            WebService.TransferFields(WebServiceAggregate);

            case WebServiceAggregate."Object Type" of
                WebServiceAggregate."Object Type"::Page:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(GetUrl(CLIENTTYPE::SOAP, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", WebService));
                        ClientTypeParam::ODataV3:
                            exit(GetUrl(CLIENTTYPE::OData, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", WebService));
                        ClientTypeParam::ODataV4:
                            exit(GetUrl(CLIENTTYPE::ODataV4, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", WebService));
                    end;
                WebServiceAggregate."Object Type"::Query:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(NotApplicableTxt);
                        ClientTypeParam::ODataV3:
                            exit(GetUrl(CLIENTTYPE::OData, CompanyName(), OBJECTTYPE::Query, WebServiceAggregate."Object ID", WebService));
                        ClientTypeParam::ODataV4:
                            exit(GetUrl(CLIENTTYPE::ODataV4, CompanyName(), OBJECTTYPE::Query, WebServiceAggregate."Object ID", WebService));
                    end;
                WebServiceAggregate."Object Type"::Codeunit:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(GetUrl(CLIENTTYPE::SOAP, CompanyName(), OBJECTTYPE::Codeunit, WebServiceAggregate."Object ID", WebService));
                        ClientTypeParam::ODataV3:
                            exit(NotApplicableTxt);
                        ClientTypeParam::ODataV4:
                            exit(ODataUnboundActionHelpUrlLbl);
                    end;
            end;
        end else begin
            TenantWebService.Init();
            TenantWebService.TransferFields(WebServiceAggregate);

            case WebServiceAggregate."Object Type" of
                WebServiceAggregate."Object Type"::Page:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(GetUrl(CLIENTTYPE::SOAP, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", TenantWebService));
                        ClientTypeParam::ODataV3:
                            begin
                                ODataServiceRootUrl := GetUrl(CLIENTTYPE::OData, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", TenantWebService);
                                exit(GenerateODataV3Url(ODataServiceRootUrl, TenantWebService."Service Name", TenantWebService."Object Type"));
                            end;
                        ClientTypeParam::ODataV4:
                            begin
                                ODataServiceRootUrl := GetUrl(CLIENTTYPE::ODataV4, CompanyName(), OBJECTTYPE::Page, WebServiceAggregate."Object ID", TenantWebService);
                                exit(GenerateODataV4Url(ODataServiceRootUrl, TenantWebService."Service Name", TenantWebService."Object Type"));
                            end;
                    end;
                WebServiceAggregate."Object Type"::Query:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(NotApplicableTxt);
                        ClientTypeParam::ODataV3:
                            begin
                                ODataServiceRootUrl := GetUrl(CLIENTTYPE::OData, CompanyName(), OBJECTTYPE::Query, WebServiceAggregate."Object ID", TenantWebService);
                                exit(GenerateODataV3Url(ODataServiceRootUrl, TenantWebService."Service Name", TenantWebService."Object Type"));
                            end;
                        ClientTypeParam::ODataV4:
                            begin
                                ODataServiceRootUrl := GetUrl(CLIENTTYPE::ODataV4, CompanyName(), OBJECTTYPE::Query, WebServiceAggregate."Object ID", TenantWebService);
                                exit(GenerateODataV4Url(ODataServiceRootUrl, TenantWebService."Service Name", TenantWebService."Object Type"));
                            end;
                    end;
                WebServiceAggregate."Object Type"::Codeunit:
                    case ClientTypeParam of
                        ClientTypeParam::SOAP:
                            exit(GetUrl(CLIENTTYPE::SOAP, CompanyName(), OBJECTTYPE::Codeunit, WebServiceAggregate."Object ID", TenantWebService));
                        ClientTypeParam::ODataV3:
                            exit(NotApplicableTxt);
                        ClientTypeParam::ODataV4:
                            exit(ODataUnboundActionHelpUrlLbl);
                    end;
            end;
        end;
    end;

    procedure CreateTenantWebServiceColumnsFromTemp(var TenantWebServiceColumns: Record "Tenant Web Service Columns"; var TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary; TenantWebServiceRecordId: RecordID)
    begin
        if TempTenantWebServiceColumns.FindSet() then begin
            TenantWebServiceColumns.SetRange(TenantWebServiceID, TenantWebServiceRecordId);
            TenantWebServiceColumns.DeleteAll();

            repeat
                TenantWebServiceColumns.Init();
                TenantWebServiceColumns.TransferFields(TempTenantWebServiceColumns, true);
                TenantWebServiceColumns."Entry ID" := 0;
                TenantWebServiceColumns.TenantWebServiceID := TenantWebServiceRecordId;
                TenantWebServiceColumns.Insert();
            until TempTenantWebServiceColumns.Next() = 0;
        end;
    end;

    procedure CreateTenantWebServiceFilterFromRecordRef(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; var RecordRef: RecordRef; TenantWebServiceRecordId: RecordID)
    begin
        TenantWebServiceFilter.SetRange(TenantWebServiceID, TenantWebServiceRecordId);
        TenantWebServiceFilter.DeleteAll();

        TenantWebServiceFilter.Init();
        TenantWebServiceFilter."Entry ID" := 0;
        TenantWebServiceFilter."Data Item" := RecordRef.Number();
        TenantWebServiceFilter.TenantWebServiceID := TenantWebServiceRecordId;
        SetTenantWebServiceFilter(TenantWebServiceFilter, RecordRef.GetView());
        TenantWebServiceFilter.Insert();
    end;

    procedure GetTenantWebServiceFilter(TenantWebServiceFilter: Record "Tenant Web Service Filter"): Text
    var
        ReadInStream: InStream;
        FilterText: Text;
    begin
        TenantWebServiceFilter.CalcFields(TenantWebServiceFilter.Filter);
        TenantWebServiceFilter.Filter.CreateInStream(ReadInStream);
        ReadInStream.ReadText(FilterText);
        exit(FilterText);
    end;

    procedure SetTenantWebServiceFilter(var TenantWebServiceFilter: Record "Tenant Web Service Filter"; FilterText: Text)
    var
        WriteOutStream: OutStream;
    begin
        Clear(TenantWebServiceFilter.Filter);
        TenantWebServiceFilter.Filter.CreateOutStream(WriteOutStream);
        WriteOutStream.WriteText(FilterText);
    end;

    procedure GetODataSelectClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    var
        ReadInStream: InStream;
        ODataText: Text;
    begin
        TenantWebServiceOData.CalcFields(TenantWebServiceOData.ODataSelectClause);
        TenantWebServiceOData.ODataSelectClause.CreateInStream(ReadInStream);
        ReadInStream.ReadText(ODataText);
        exit(ODataText);
    end;

    procedure SetODataSelectClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(TenantWebServiceOData.ODataSelectClause);
        TenantWebServiceOData.ODataSelectClause.CreateOutStream(WriteStream);
        WriteStream.WriteText(ODataText);
    end;

    procedure GetODataFilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    var
        InStream: InStream;
        ODataText: Text;
    begin
        TenantWebServiceOData.CalcFields(TenantWebServiceOData.ODataFilterClause);
        TenantWebServiceOData.ODataFilterClause.CreateInStream(InStream);
        InStream.ReadText(ODataText);
        exit(ODataText);
    end;

    procedure SetODataFilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(TenantWebServiceOData.ODataFilterClause);
        TenantWebServiceOData.ODataFilterClause.CreateOutStream(OutStream);
        OutStream.WriteText(ODataText);
    end;

    procedure GetODataV4FilterClause(TenantWebServiceOData: Record "Tenant Web Service OData"): Text
    var
        InStream: InStream;
        ODataText: Text;
    begin
        TenantWebServiceOData.CalcFields(TenantWebServiceOData.ODataV4FilterClause);
        TenantWebServiceOData.ODataV4FilterClause.CreateInStream(InStream);
        InStream.ReadText(ODataText);
        exit(ODataText);
    end;

    procedure SetODataV4FilterClause(var TenantWebServiceOData: Record "Tenant Web Service OData"; ODataText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(TenantWebServiceOData.ODataV4FilterClause);
        TenantWebServiceOData.ODataV4FilterClause.CreateOutStream(OutStream);
        OutStream.WriteText(ODataText);
    end;

    procedure GetObjectCaption(WebServiceAggregate: Record "Web Service Aggregate"): Text[80]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(WebServiceAggregate."Object Type", WebServiceAggregate."Object ID") then
            exit(CopyStr(AllObjWithCaption."Object Caption", 1, 80));
        exit('');
    end;

    procedure VerifyRecord(WebServiceAggregate: Record "Web Service Aggregate")
    var
        AllObj: Record AllObj;
    begin
        WebServiceAggregate.TestField("Object ID");
        WebServiceAggregate.TestField("Service Name");
        if not (WebServiceAggregate."Object Type" in [WebServiceAggregate."Object Type"::Codeunit, WebServiceAggregate."Object Type"::Page, WebServiceAggregate."Object Type"::Query]) then
            WebServiceAggregate.FieldError("Object Type");
        AllObj.Get(WebServiceAggregate."Object Type", WebServiceAggregate."Object ID");
    end;

    procedure LoadRecords(var Rec: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        Rec.Reset();
        Rec.DeleteAll();

        if WebService.FindSet() then
            repeat
                Rec.Init();
                Rec.TransferFields(WebService);
                Rec."All Tenants" := true;
                Rec.Insert();
            until WebService.Next() = 0;

        Rec."All Tenants" := false;
        Clear(TenantWebService);

        if TenantWebService.FindSet() then
            repeat
                Clear(WebService);
                if not WebService.Get(TenantWebService."Object Type", TenantWebService."Service Name") then begin
                    WebService.SetRange("Object Type", TenantWebService."Object Type");
                    WebService.SetRange("Object ID", TenantWebService."Object ID");
                    WebService.SetRange(Published, false);

                    if WebService.IsEmpty() then begin
                        Rec.Init();
                        Rec.TransferFields(TenantWebService);
                        Rec.Insert();
                    end
                end
            until TenantWebService.Next() = 0;
    end;

    procedure LoadRecordsFromTenantWebServiceColumns(var Rec: Record "Tenant Web Service")
    var
        TenantWebService: Record "Tenant Web Service";
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
    begin
        if TenantWebService.Find('-') then
            repeat
                TenantWebServiceColumns.SetRange(TenantWebServiceID, TenantWebService.RecordId());
                if NOT TenantWebServiceColumns.IsEmpty() then begin
                    Rec := TenantWebService;
                    Rec.Insert();
                end;
            until TenantWebService.Next() = 0;
    end;

    procedure ModifyWebService(Rec: Record "Web Service Aggregate"; xRec: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if Rec."All Tenants" then
            if xRec."All Tenants" then begin
                if WebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    WebService."Object ID" := Rec."Object ID";
                    WebService.Published := Rec.Published;
                    WebService.ExcludeFieldsOutsideRepeater := Rec.ExcludeFieldsOutsideRepeater;
                    WebService.ExcludeNonEditableFlowFields := Rec.ExcludeNonEditableFlowFields;
                    WebService.Modify();
                end else begin
                    Clear(WebService);
                    WebService.TransferFields(Rec);
                    WebService.Insert();
                end;
            end else begin
                Clear(WebService);
                WebService.TransferFields(Rec);
                WebService.Insert();
            end
        else
            if xRec."All Tenants" then begin
                if WebService.Get(xRec."Object Type", xRec."Service Name") then
                    WebService.Delete();

                if not TenantWebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    Clear(TenantWebService);
                    TenantWebService.TransferFields(Rec);
                    TenantWebService.Insert();
                end;
            end else begin
                AssertModAllowed(Rec);

                if TenantWebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    TenantWebService."Object ID" := Rec."Object ID";
                    TenantWebService.Published := Rec.Published;
                    TenantWebService.ExcludeFieldsOutsideRepeater := Rec.ExcludeFieldsOutsideRepeater;
                    TenantWebService.ExcludeNonEditableFlowFields := Rec.ExcludeNonEditableFlowFields;
                    TenantWebService.Modify();
                end else begin
                    TenantWebService.TransferFields(Rec);
                    TenantWebService.Insert();
                end;
            end;
    end;

    procedure RenameWebService(Rec: Record "Web Service Aggregate"; xRec: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if Rec."All Tenants" then
            if xRec."All Tenants" then begin
                if WebService.Get(xRec."Object Type", xRec."Service Name") then
                    WebService.Rename(Rec."Object Type", Rec."Service Name");

                if WebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    WebService."Object ID" := Rec."Object ID";
                    WebService.ExcludeFieldsOutsideRepeater := Rec.ExcludeFieldsOutsideRepeater;
                    WebService.ExcludeNonEditableFlowFields := Rec.ExcludeNonEditableFlowFields;
                    WebService.Published := Rec.Published;
                    WebService.Modify();
                end else begin
                    Clear(WebService);
                    WebService.TransferFields(Rec);
                    WebService.Insert();
                end
            end else begin
                Clear(WebService);
                WebService.TransferFields(Rec);
                WebService.Insert();
            end
        else
            if xRec."All Tenants" then begin
                if WebService.Get(xRec."Object Type", xRec."Service Name") then
                    WebService.Delete();

                if not TenantWebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    Clear(TenantWebService);
                    TenantWebService.TransferFields(Rec);
                    TenantWebService.Insert();
                end
            end else begin
                AssertModAllowed(Rec);

                if TenantWebService.Get(xRec."Object Type", xRec."Service Name") then
                    TenantWebService.Rename(Rec."Object Type", Rec."Service Name");

                if TenantWebService.Get(Rec."Object Type", Rec."Service Name") then begin
                    TenantWebService."Object ID" := Rec."Object ID";
                    TenantWebService.ExcludeFieldsOutsideRepeater := Rec.ExcludeFieldsOutsideRepeater;
                    TenantWebService.ExcludeNonEditableFlowFields := Rec.ExcludeNonEditableFlowFields;
                    TenantWebService.Published := Rec.Published;
                    TenantWebService.Modify();
                end else begin
                    TenantWebService.TransferFields(Rec);
                    TenantWebService.Insert();
                end
            end;
    end;

    procedure IsServiceNameValid(value: Text): Boolean
    var
        RegEx: DotNet Regex;
        RegexOptions: DotNet RegexOptions;
        NameExp: Text;
    begin
        NameExp := '^' + StartCharacterExpTxt + OtherCharacterExpTxt + '{0,}' + '$';
        exit(RegEx.IsMatch(value, NameExp, RegexOptions.Singleline));
    end;

    procedure AssertServiceNameIsValid(value: Text)
    begin
        if not IsServiceNameValid(value) then
            Error(WebServiceNameNotValidErr);
    end;

    procedure AssertUniquePublishedServiceName(WebServiceAggregate: Record "Web Service Aggregate"; xRec: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if (((WebServiceAggregate."Service Name" <> xRec."Service Name") or (WebServiceAggregate.Published <> xRec.Published)) and
            (WebServiceAggregate.Published = true) and (WebServiceAggregate."Object Type" <> WebServiceAggregate."Object Type"::Codeunit))
        then begin
            WebService.SetRange(Published, true);
            WebService.SetRange("Service Name", WebServiceAggregate."Service Name");
            WebService.SetRange("Object Type", WebServiceAggregate."Object Type"::Page, WebServiceAggregate."Object Type"::Query);

            TenantWebService.SetRange(Published, true);
            TenantWebService.SetRange("Service Name", WebServiceAggregate."Service Name");
            TenantWebService.SetRange("Object Type", WebServiceAggregate."Object Type"::Page, WebServiceAggregate."Object Type"::Query);

            if (not WebService.IsEmpty()) or (not TenantWebService.IsEmpty()) then
                Error(WebServiceAlreadyPublishedErr, WebServiceAggregate."Service Name");
        end;
    end;

    procedure AssertUniqueUnpublishedObject(WebServiceAggregate: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
    begin
        WebService.SetRange("Object Type", WebServiceAggregate."Object Type");
        WebService.SetRange("Object ID", WebServiceAggregate."Object ID");
        WebService.SetRange(Published, false);

        if not WebService.IsEmpty() then
            Error(WebServiceNotAllowedErr);
    end;

    local procedure AssertModAllowed(WebServiceAggregate: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
    begin
        WebService.SetRange("Object Type", WebServiceAggregate."Object Type");
        WebService.SetRange("Object ID", WebServiceAggregate."Object ID");
        WebService.SetRange(Published, false);

        if not WebService.IsEmpty() then
            Error(WebServiceModNotAllowedErr);
    end;

    local procedure GetWebServiceName(ServiceName: Text; ObjectName: Text): Text
    begin
        if ServiceName <> '' then
            exit(ServiceName);

        exit(DelChr(ObjectName, '=', ' '));
    end;

    local procedure ModifyWebService(var WebService: Record "Web Service"; AllObj: Record AllObj; WebServiceName: Text; Published: Boolean)
    begin
        WebService."Object Type" := AllObj."Object Type";
        WebService."Object ID" := AllObj."Object ID";
        WebService."Service Name" := CopyStr(WebServiceName, 1, MaxStrLen(WebService."Service Name"));
        WebService.Published := Published;
    end;

    local procedure ModifyTenantWebService(var TenantWebService: Record "Tenant Web Service"; AllObj: Record AllObj; WebServiceName: Text; Published: Boolean)
    begin
        TenantWebService."Object Type" := AllObj."Object Type";
        TenantWebService."Object ID" := AllObj."Object ID";
        TenantWebService."Service Name" := CopyStr(WebServiceName, 1, MaxStrLen(TenantWebService."Service Name"));
        TenantWebService.Published := Published;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Web Service", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteODataOnDeleteTenantWebService(var Rec: Record "Tenant Web Service"; RunTrigger: Boolean)
    var
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
        TenantWebServiceFilter: Record "Tenant Web Service Filter";
        TenantWebServiceOData: Record "Tenant Web Service OData";
    begin
        if Rec.IsTemporary() then
            exit;

        TenantWebServiceFilter.SetRange(TenantWebServiceID, Rec.RecordId());
        TenantWebServiceColumns.SetRange(TenantWebServiceID, Rec.RecordId());
        TenantWebServiceOData.SetRange(TenantWebServiceID, Rec.RecordId());
        TenantWebServiceFilter.DeleteAll();
        TenantWebServiceColumns.DeleteAll();
        TenantWebServiceOData.DeleteAll();
    end;

    procedure CreateTenantWebServiceColumnForPage(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer)
    var
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
        FieldTable: Record "Field";
        FieldNameConverted: Text;
    begin
        TenantWebServiceColumns.Init();
        TenantWebServiceColumns."Entry ID" := 0;
        TenantWebServiceColumns."Data Item" := DataItem;
        TenantWebServiceColumns."Field Number" := FieldNumber;
        TenantWebServiceColumns.TenantWebServiceID := TenantWebServiceRecordId;
        TenantWebServiceColumns.Include := true;

        if FieldTable.Get(DataItem, FieldNumber) then
            FieldNameConverted := ConvertFieldNameToODataName(FieldTable.FieldName);

        TenantWebServiceColumns."Field Name" := CopyStr(FieldNameConverted, 1, 250);
        TenantWebServiceColumns.Insert();
    end;

    procedure InsertSelectedColumns(var TenantWebService: Record "Tenant Web Service"; var ColumnDictionary: DotNet GenericDictionary2; var TargetTenantWebServiceColumns: Record "Tenant Web Service Columns"; DataItem: Integer)
    var
        keyValuePair: DotNet GenericKeyValuePair2;
        EntryId: Integer;
    begin
        foreach keyValuePair in ColumnDictionary do begin
            Clear(TargetTenantWebServiceColumns);

            TargetTenantWebServiceColumns.Init();
            TargetTenantWebServiceColumns.Validate(TenantWebServiceID, TenantWebService.RecordId());
            TargetTenantWebServiceColumns.Validate("Data Item", DataItem);
            TargetTenantWebServiceColumns.Validate(Include, true);
            TargetTenantWebServiceColumns.Validate("Field Number", keyValuePair.Key());
            TargetTenantWebServiceColumns.Validate("Field Name", CopyStr(keyValuePair.Value(), 1));
            if TargetTenantWebServiceColumns.IsTemporary() then begin
                EntryId := EntryId + 1;
                TargetTenantWebServiceColumns."Entry ID" := EntryId;
            end;
            TargetTenantWebServiceColumns.Insert(true);
        end;
    end;

    procedure CreateTenantWebServiceColumnForQuery(TenantWebServiceRecordId: RecordID; FieldNumber: Integer; DataItem: Integer; MetaData: DotNet QueryMetadataReader)
    var
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
        queryField: DotNet QueryFields;
        FieldNameConverted: Text;
        i: Integer;
    begin
        TenantWebServiceColumns.Init();
        TenantWebServiceColumns."Entry ID" := 0;
        TenantWebServiceColumns."Data Item" := DataItem;
        TenantWebServiceColumns."Field Number" := FieldNumber;
        TenantWebServiceColumns.TenantWebServiceID := TenantWebServiceRecordId;
        TenantWebServiceColumns.Include := true;

        if not IsNull(MetaData) then
            for i := 0 to MetaData.Fields().Count() - 1 do begin
                queryField := MetaData.Fields().Item(i);
                if (queryField.FieldNo() = FieldNumber) and (queryField.TableNo() = DataItem) then
                    FieldNameConverted := queryField.FieldName();
            end;

        TenantWebServiceColumns."Field Name" := CopyStr(FieldNameConverted, 1, 250);
        TenantWebServiceColumns.Insert();
    end;

    local procedure ConvertFieldNameToODataName(NavFieldName: Text): Text
    begin
        exit(ExternalizeODataObjectName(NavFieldName));
    end;

    local procedure ExternalizeODataObjectName(Name: Text) ConvertedName: Text
    var
        CurrentPosition: Integer;
    begin
        ConvertedName := Name;

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

        ConvertedName := RemoveTrailingUnderscore(ConvertedName);
    end;

    local procedure RemoveTrailingUnderscore(Input: Text): Text
    begin
        Input := DelChr(Input, '>', '_');
        exit(Input);
    end;

    procedure DeleteWebService(var WebServiceAggregate: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        Session.LogMessage('0000GRJ', WebServiceDeleteAttemptTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, GetTelemetryDimensions(WebServiceAggregate));

        if WebServiceAggregate."All Tenants" then begin
            if WebService.Get(WebServiceAggregate."Object Type", WebServiceAggregate."Service Name") then
                if WebService.Delete() then
                    Session.LogMessage('0000GRK', WebServiceDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, GetTelemetryDimensions(WebServiceAggregate));
            ;
        end else
            if TenantWebService.Get(WebServiceAggregate."Object Type", WebServiceAggregate."Service Name") then
                if TenantWebService.Delete() then
                    Session.LogMessage('0000GRL', TenantWebServiceDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, GetTelemetryDimensions(WebServiceAggregate));
    end;

    procedure InsertWebService(var WebServiceAggregate: Record "Web Service Aggregate")
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if WebServiceAggregate."All Tenants" then begin
            Clear(WebService);
            WebService.TransferFields(WebServiceAggregate);
            WebService.Insert();
        end else begin
            Clear(TenantWebService);
            TenantWebService.TransferFields(WebServiceAggregate);
            TenantWebService.Insert();
        end
    end;

    procedure RemoveUnselectedColumnsFromFilter(var TenantWebService: Record "Tenant Web Service"; DataItemNumber: Integer; DataItemView: Text): Text
    var
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
        BaseRecordRef: RecordRef;
        UpdatedRecordRef: RecordRef;
        BaseFieldRef: FieldRef;
        UpdatedFieldRef: FieldRef;
    begin
        BaseRecordRef.Open(DataItemNumber);
        BaseRecordRef.SetView(DataItemView);
        UpdatedRecordRef.Open(DataItemNumber);

        TenantWebServiceColumns.SetRange(TenantWebServiceID, TenantWebService.RecordId());
        TenantWebServiceColumns.SetRange("Data Item", DataItemNumber);
        if TenantWebServiceColumns.FindSet() then
            repeat
                if BaseRecordRef.FieldExist(TenantWebServiceColumns."Field Number") then begin
                    BaseFieldRef := BaseRecordRef.Field(TenantWebServiceColumns."Field Number");
                    UpdatedFieldRef := UpdatedRecordRef.Field(TenantWebServiceColumns."Field Number");
                    UpdatedFieldRef.SetFilter(BaseFieldRef.GetFilter());
                end;
            until TenantWebServiceColumns.Next() = 0;

        exit(UpdatedRecordRef.GetView());
    end;

    local procedure GenerateODataV3Url(ServiceRootUrlParam: Text; ServiceNameParam: Text; ObjectTypeParam: Option ,,,,,,,,"Page","Query"): Text
    begin
        exit(GenerateUrl(ServiceRootUrlParam, ServiceNameParam, ObjectTypeParam, ODataProtocolVersion::V3));
    end;

    local procedure GenerateODataV4Url(ServiceRootUrlParam: Text; ServiceNameParam: Text; ObjectTypeParam: Option ,,,,,,,,"Page","Query"): Text
    begin
        exit(GenerateUrl(ServiceRootUrlParam, ServiceNameParam, ObjectTypeParam, ODataProtocolVersion::V4));
    end;

    local procedure GenerateUrl(ServiceRootUrlParam: Text; ServiceNameParam: Text; ObjectTypeParam: Option ,,,,,,,,"Page","Query"; ODataProtocolVersion: Enum "OData Protocol Version"): Text
    var
        TenantWebService: Record "Tenant Web Service";
        TenantWebServiceOData: Record "Tenant Web Service OData";
        ODataUrl: Text;
        SelectText: Text;
        FilterText: Text;
    begin
        if TenantWebService.Get(ObjectTypeParam, ServiceNameParam) then begin
            TenantWebServiceOData.SetRange(TenantWebServiceID, TenantWebService.RecordId());

            if TenantWebServiceOData.FindFirst() then begin
                SelectText := GetODataSelectClause(TenantWebServiceOData);
                if ODataProtocolVersion = ODataProtocolVersion::V3 then
                    FilterText := GetODataFilterClause(TenantWebServiceOData)
                else
                    FilterText := GetODataV4FilterClause(TenantWebServiceOData);
            end;
        end;

        ODataUrl := BuildUrl(ServiceRootUrlParam, SelectText, FilterText);
        exit(ODataUrl);
    end;

    local procedure BuildUrl(ServiceRootUrlParam: Text; SelectTextParam: Text; FilterTextParam: Text): Text
    var
        ODataUrl: Text;
        PreSelectTextConjunction: Text;
    begin
        if StrPos(ServiceRootUrlParam, '?tenant=') > 0 then
            PreSelectTextConjunction := '&'
        else
            PreSelectTextConjunction := '?';

        if (StrLen(SelectTextParam) > 0) and (StrLen(FilterTextParam) > 0) then
            ODataUrl := ServiceRootUrlParam + PreSelectTextConjunction + SelectTextParam + '&' + FilterTextParam
        else
            if StrLen(SelectTextParam) > 0 then
                ODataUrl := ServiceRootUrlParam + PreSelectTextConjunction + SelectTextParam
            else
                ODataUrl := ServiceRootUrlParam;

        exit(ODataUrl);
    end;

    local procedure GetTelemetryDimensions(WebServiceAggregate: Record "Web Service Aggregate") Dimensions: Dictionary of [Text, Text]
    begin
        Dimensions.Add('Category', 'WebServiceManagement');
        Dimensions.Add('IsTenantWebService', Format(not WebServiceAggregate."All Tenants"));
        Dimensions.Add('ObjectID', Format(WebServiceAggregate."Object ID"));
        Dimensions.Add('ObjectType', Format(WebServiceAggregate."Object Type"));
        Dimensions.Add('IsPublished', Format(WebServiceAggregate.Published));
        Dimensions.Add('ServiceName', Format(WebServiceAggregate."Service Name"));
    end;
}
