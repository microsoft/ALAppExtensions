tableextension 2403 "XS Sync Change Extension" extends "Sync Change"
{
    fields
    {
        field(10; "XS Xero Json Response"; Blob)
        {
            Caption = 'Xero Json Response';
            DataClassification = CustomerContent;
        }
        field(11; "XS NAV Entity ID"; Integer)
        {
            Caption = 'NAV Entity ID';
            DataClassification = SystemMetadata;
        }
        field(12; "XS ReMapped"; Boolean)
        {
            Caption = 'Re-mapped';
            DataClassification = SystemMetadata;
        }
    }

    trigger OnAfterInsert()
    begin
        OnAfterInsertRecord(Rec);
    end;

    procedure GetChangesFromXero(SyncSetup: Record "Sync Setup"; NAVEntityID: Integer; XeroID: Text)
    var
        GetChangesFromXero: Codeunit "XS Get Changes From Xero";
    begin
        GetChangesFromXero.GetChangesFromXero(Rec, SyncSetup, NAVEntityID, XeroID);
    end;

    procedure CreateSyncChangeRecord(NAVEntityID: Integer; EntityDataJsonText: Text)
    var
        CreateSyncChangeRecord: Codeunit "XS Create Sync Change Record";
    begin
        CreateSyncChangeRecord.CreateSyncChangeRecord(Rec, NAVEntityID, EntityDataJsonText);
    end;

    procedure UpdateSyncChangeRecord(EntityDataJsonText: Text; ChangeType: Option Create,Update,Delete," ")
    var
        UpdateSyncChangeRecord: Codeunit "XS Update Sync Change Record";
    begin
        UpdateSyncChangeRecord.UpdateSyncChangeRecord(Rec, EntityDataJsonText, ChangeType);
    end;

    procedure UpdateSyncChangeWithJsonResponseData(NAVEntityID: Integer; var JsonResponse: JsonArray) UpdatedDateUtc: Text
    var
        UpdateSyncChangeWithJsonResponseData: Codeunit "XS Update SC With Response";
    begin
        UpdatedDateUtc := UpdateSyncChangeWithJsonResponseData.UpdateSyncChangeWithJsonResponse(NAVEntityID, Rec, JsonResponse);
    end;

    procedure UpdateSyncChangeWithErrorMessage(ErrorMessage: Text)
    begin
        OnBeforeUpdateSyncChangeWithErrorMessage(ErrorMessage);
        Validate("Error message", CopyStr(ErrorMessage, 1, 250));
        Modify(true);
    end;

    procedure ProcessXeroChange(): Boolean
    var
        ProcessXeroChange: Codeunit "XS Process Xero Change";
    begin
        exit(ProcessXeroChange.ProcessXeroChange(Rec));
    end;

    procedure CreateEntityFromXero(var Success: Boolean) UpdatedDateUTC: Text
    var
        ItemCreateFromXero: Codeunit "XS Item Create From Xero";
        CustomerCreateFromXero: Codeunit "XS Customer Create From Xero";
    begin
        Commit();
        case Rec."XS NAV Entity ID" of
            Database::Item:
                begin
                    Success := ItemCreateFromXero.Run(Rec);
                    if Success then
                        UpdatedDateUTC := ItemCreateFromXero.GetUpdatedDateUTC()
                    else
                        Rec.UpdateSyncChangeWithErrorMessage(GetLastErrorText());
                end;
            Database::Customer:
                begin
                    Success := CustomerCreateFromXero.Run(Rec);
                    if Success then
                        UpdatedDateUTC := CustomerCreateFromXero.GetUpdatedDateUTC()
                    else
                        Rec.UpdateSyncChangeWithErrorMessage(GetLastErrorText());
                end
        end;
    end;

    procedure UpdateEntityFromXero(var Success: Boolean; var FalseIncomingChange: Boolean) UpdatedDateUTC: Text
    var
        ItemUpdateFromXero: Codeunit "XS Item Update From Xero";
        CustomerUpdateFromXero: Codeunit "XS Customer Update From Xero";
    begin
        case Rec."XS NAV Entity ID" of
            Database::Item:
                UpdatedDateUTC := ItemUpdateFromXero.ItemUpdateFromXero(Rec, Success, FalseIncomingChange);
            Database::Customer:
                UpdatedDateUTC := CustomerUpdateFromXero.CustomerUpdateFromXero(Rec, Success, FalseIncomingChange);
        end;
    end;

    procedure CreateIncomingDeleteSyncChangeForEntity(NAVEntityID: Integer)
    var
        CreateIncomingDeleteSyncChangeForEntity: Codeunit "XS Create Incoming Delete SC";
    begin
        CreateIncomingDeleteSyncChangeForEntity.CreateIncomingDeleteSyncChangesForEntity(NAVEntityID);
    end;

    procedure QueueOutgoingChangeForEntity(var RecRef: RecordRef; ChangeType: Option Create,Update,Delete," ")
    var
        QueueOutgoingChange: Codeunit "XS Queue Outgoing Change";
    begin
        QueueOutgoingChange.QueueOutgoingChange(RecRef, Rec, ChangeType);
    end;

    procedure PushSyncChangeToXero(var Success: Boolean) UpdatedDateUTC: Text
    var
        PushItemToXero: Codeunit "XS Push Item To Xero";
        PushCustomerToXero: Codeunit "XS Push Customer To Xero";
        PushSalesInvoiceToXero: Codeunit "XS Push Sales Inv. To Xero";
    begin
        case Rec."XS NAV Entity ID" of
            Database::Item:
                UpdatedDateUTC := PushItemToXero.PushItemToXero(Rec, Success);
            Database::Customer:
                UpdatedDateUTC := PushCustomerToXero.PushCustomerToXero(Rec, Success);
            Database::"Sales Invoice Header":
                UpdatedDateUTC := PushSalesInvoiceToXero.PushSalesInvoiceToXero(Rec, Success);
        end;
    end;

    procedure ProcessDeleteFromXero(var DoDeleteSyncMapping: Boolean) DeletedInNAVDateTime: DateTime
    var
        ProcessDeleteFromXero: Codeunit "XS Process Delete From Xero";
    begin
        DeletedInNAVDateTime := ProcessDeleteFromXero.ProcessDeleteFromXero(Rec, DoDeleteSyncMapping);
    end;

    procedure PushDataToXero(NAVEntityID: Integer; SyncChangeDirection: Option Incoming,Outgoing,Bidirectional; ChangeType: Option Create,Update,Delete," "; XeroID: Text; EntityDataJsonTxt: Text; var JsonEntities: JsonArray) IsSuccessStatusCode: Boolean;
    var
        RestWebService: Record "XS REST Web Service Parameters" temporary;
        DummyDateTime: DateTime;
        DummyAdditionalParameterList: List of [Text];
    begin
        IsSuccessStatusCode := RestWebService.CommunicateWithXero(Rec, NAVEntityID, XeroID, SyncChangeDirection, ChangeType, DummyDateTime, false, EntityDataJsonTxt, JsonEntities, DummyAdditionalParameterList);
    end;

    procedure FetchDataFromXero(NAVEntityID: Integer; SyncChangeDirection: Option Incoming,Outgoing,Bidirectional; XeroID: Text; ModifiedSince: DateTime; UseModifiedSince: Boolean; var JsonEntities: JsonArray) IsSuccessStatusCode: Boolean;
    var
        RestWebService: Record "XS REST Web Service Parameters" temporary;
        DummyAdditionalParameterList: List of [Text];
    begin
        IsSuccessStatusCode := RestWebService.CommunicateWithXero(Rec, NAVEntityID, XeroID, SyncChangeDirection, 0, ModifiedSince, UseModifiedSince, '', JsonEntities, DummyAdditionalParameterList);
    end;

    procedure GetJsonFromSyncChange() JsonDataText: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        JsonDataText := JsonObjectHelper.GetBLOBDataAsText(RecRef, Rec.FieldNo("NAV Data"));
    end;

    procedure UpdateSyncChangeWithInternalID(InternalID: RecordId)
    begin
        "Internal ID" := InternalID;
        Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRecord(SyncChange: Record "Sync Change")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSyncChangeWithErrorMessage(ErrorMessage: Text)
    begin
    end;
}