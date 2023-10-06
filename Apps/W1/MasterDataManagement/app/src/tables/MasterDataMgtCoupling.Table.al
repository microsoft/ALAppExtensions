namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;

table 7231 "Master Data Mgt. Coupling"
{
    Caption = 'Master Data Mgt. Coupling';
    Permissions = tabledata "Integration Table Mapping" = r,
                  tabledata "Integration Synch. Job" = r,
                  tabledata "Integration Synch. Job Errors" = r,
                  tabledata "Master Data Management Setup" = r;

    DataClassification = SystemMetadata;

    fields
    {
        field(2; "Integration System ID"; Guid)
        {
            Caption = 'Integration System ID';
            Description = 'An ID of a record in another Business Central company';

            trigger OnValidate()
            begin
                Clear("Last Synch. Int. Job ID");
                "Last Synch. Int. Modified On" := 0DT;
                "Last Synch. Int. Result" := 0;
                Skipped := false;
            end;
        }
        field(3; "Local System ID"; Guid)
        {
            Caption = 'Local System ID';

            trigger OnValidate()
            begin
                Clear("Last Synch. Job ID");
                "Last Synch. Modified On" := 0DT;
                "Last Synch. Result" := 0;
                Skipped := false;
            end;
        }
        field(4; "Last Synch. Modified On"; DateTime)
        {
            Caption = 'Last Synch. Modified On';
        }
        field(5; "Last Synch. Int. Modified On"; DateTime)
        {
            Caption = 'Last Synch. Int. Modified On';
        }
        field(6; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            FieldClass = Normal;

            trigger OnValidate()
            begin
                CheckTableID();
            end;
        }
        field(7; "Last Synch. Result"; Option)
        {
            Caption = 'Last Synch. Result';
            OptionCaption = ',Success,Failure';
            OptionMembers = ,Success,Failure;
        }
        field(8; "Last Synch. Int. Result"; Option)
        {
            Caption = 'Last Synch. Int. Result';
            OptionCaption = ',Success,Failure';
            OptionMembers = ,Success,Failure;
        }
        field(9; "Last Synch. Job ID"; Guid)
        {
            Caption = 'Last Synch. Job ID';
        }
        field(10; "Last Synch. Int. Job ID"; Guid)
        {
            Caption = 'Last Synch. Int. Job ID';
        }
        field(11; Skipped; Boolean)
        {
            Caption = 'Skipped';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Integration System ID", "Local System ID")
        {
            Clustered = true;
        }
        key(Key2; "Local System ID")
        {
        }
        key(Key3; "Last Synch. Modified On", "Local System ID")
        {
        }
        key(Key4; "Last Synch. Int. Modified On", "Integration System ID")
        {
        }
        key(Key5; Skipped, "Table ID")
        {
        }
        key(Key6; "Table ID")
        {
        }
        key(Key7; "Local System ID", Skipped, "Table ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        CheckTableID();
    end;

    var
        IntegrationRecordNotFoundErr: Label 'The integration record for entity %1 was not found.', Comment = '%1 - entity name';
        ZeroTableIdErr: Label 'Table ID must be specified.';
        ZeroTableIdTxt: Label 'Table ID is zero in Data Synch. Coupling record. System ID: %1, Integration System ID: %2', Locked = true;
        FixedTableIdTxt: Label 'Table ID has been fixed in Data Synch. Coupling record. New Table ID: %1, System ID: %2, Integration System ID: %3', Locked = true;

    local procedure CheckTableID()
    begin
        if "Table ID" = 0 then
            if not IsNullGuid("Local System ID") then
                if not IsTemporary() then
                    Error(ZeroTableIdErr);
    end;

    internal procedure GetTableID(): Integer
    var
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        if "Table ID" <> 0 then
            exit("Table ID");

        if IsNullGuid("Local System ID") then
            exit(0);

        if RepairTableIdByLocalRecord() then
            exit("Table ID");

        Session.LogMessage('0000J8U', StrSubstNo(ZeroTableIdTxt, "Local System ID", "Integration System ID"), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
        exit(0);
    end;

    internal procedure RepairTableIdByLocalRecord(): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        if "Table ID" <> 0 then
            exit(true);

        if IsNullGuid("Local System ID") then
            exit(true);

        if FindMappingByLocalRecordId(IntegrationTableMapping) then begin
            "Table ID" := IntegrationTableMapping."Table ID";
            Modify();
            Session.LogMessage('0000J8V', StrSubstNo(FixedTableIdTxt, "Table ID", "Local System ID", "Integration System ID"), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
            exit(true);
        end;

        exit(false);
    end;

    internal procedure RepairTableIdByIntegrationRecord(): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: COdeunit "Master Data Management";
    begin
        if "Table ID" <> 0 then
            exit(true);

        if IsNullGuid("Local System ID") then
            exit(true);

        if MasterDataManagement.FindMappingByIntegrationRecordId(IntegrationTableMapping, Rec) then
            if IntegrationTableMapping."Table ID" <> 0 then begin
                "Table ID" := IntegrationTableMapping."Table ID";
                Modify();
                Session.LogMessage('0000J8W', StrSubstNo(FixedTableIdTxt, "Table ID", "Local System ID", "Integration System ID"), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                exit(true);
            end;

        exit(false);
    end;

    local procedure FindMappingByLocalRecordId(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    var
        LocalRecordRef: RecordRef;
    begin
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetFilter("Table ID", '<>0');
        if IntegrationTableMapping.FindSet() then
            repeat
                LocalRecordRef.Close();
                LocalRecordRef.Open(IntegrationTableMapping."Table ID");
                if LocalRecordRef.GetBySystemId("Local System ID") then
                    exit(true);
            until IntegrationTableMapping.Next() = 0;
        exit(false);
    end;

    internal procedure InsertRecord(IntegrationSysID: Guid; SysId: Guid; TableId: Integer)
    var
        LocalRecordRef: RecordRef;
        EmptyGuid: Guid;
    begin
        if IntegrationSysID = EmptyGuid then
            Error('Empty Integration Record System ID');

        if IntegrationSysID <> SysId then begin
            LocalRecordRef.Open(TableId);
            LocalRecordRef.ReadIsolation := LocalRecordRef.ReadIsolation::ReadUncommitted;
            if not LocalRecordRef.GetBySystemId(SysId) then
                exit;
        end;

        Reset();
        Init();
        "Integration System ID" := IntegrationSysID;
        "Local System ID" := SysId;
        "Table ID" := TableId;
        "Last Synch. Int. Modified On" := CurrentDateTime();
        "Last Synch. Modified On" := "Last Synch. Int. Modified On";
        Insert(true);
    end;

    internal procedure IsIntegrationRecordRefCoupled(IntegrationRecordRef: RecordRef): Boolean
    var
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        exit(FindByIntegrationSystemID(MasterDataManagement.GetIntegrationSystemIdFromRecRef(IntegrationRecordRef)));
    end;

    internal procedure IsLocalSystemIdCoupled(LocalSystemId: Guid): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        exit(FindRowFromLocalSystemID(LocalSystemId, MasterDataMgtCoupling));
    end;

    internal procedure IsIntegrationSystemIdCoupled(IntegrationSystemId: Guid; IntegrationTableID: Integer): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        exit(FindRowFromIntegrationSystemID(IntegrationSystemId, IntegrationTableID, MasterDataMgtCoupling));
    end;

    internal procedure FindByIntegrationSystemID(IntegrationSystemID: Guid): Boolean
    begin
        Reset();
        SetRange("Integration System ID", IntegrationSystemID);
        exit(FindFirst());
    end;

    internal procedure FindRecordId(var RecId: RecordId): Boolean
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        EmptyRecId: RecordId;
        FoundRecId: RecordId;
        TableId: Integer;
    begin
        TableId := GetTableID();
        if TableId = 0 then
            exit(false);

        RecRef.Open(TableId);
        FldRef := RecRef.FIELD(RecRef.SystemIdNo());
        FldRef.SetRange("Local System ID");
        if RecRef.FindFirst() then
            FoundRecId := RecRef.RecordId();

        if FoundRecId <> EmptyRecId then
            RecId := FoundRecId;

        exit(FoundRecId <> EmptyRecId);
    end;

    internal procedure FindSystemIdByRecordId(var SysId: Guid; RecId: RecordId): Boolean
    var
        RecRef: RecordRef;
    begin
        if not RecRef.Get(RecId) then
            exit(false);

        exit(FindSystemIdByRecordRef(SysId, RecRef));
    end;

    internal procedure FindSystemIdByRecordRef(var SysId: Guid; RecordRef: RecordRef): Boolean
    begin
        if RecordRef.Number() = 0 then
            exit(false);

        SysId := RecordRef.Field(RecordRef.SystemIdNo()).Value();
        exit(not IsNullGuid(SysId));
    end;

    internal procedure FindByRecordID(RecID: RecordID): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if FindRowFromRecordID(RecID, MasterDataMgtCoupling) then begin
            Copy(MasterDataMgtCoupling);
            exit(true);
        end;
    end;

    internal procedure FindRecordIDFromID(SourceIntegrationSystemID: Guid; DestinationTableID: Integer; var DestinationRecordId: RecordID): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        RecId: RecordId;
    begin
        if FindRowFromIntegrationSystemID(SourceIntegrationSystemID, DestinationTableID, MasterDataMgtCoupling) then begin
            if MasterDataMgtCoupling.FindRecordId(RecId) then
                DestinationRecordId := RecId;
            exit(true);
        end;
    end;

    internal procedure FindIDFromRecordID(SourceRecordID: RecordID; var DestinationIntegrationSystemID: Guid): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if FindRowFromRecordID(SourceRecordID, MasterDataMgtCoupling) then begin
            DestinationIntegrationSystemID := MasterDataMgtCoupling."Integration System ID";
            exit(true);
        end;
    end;

    internal procedure FindIDFromRecordRef(SourceRecordRef: RecordRef; var DestinationSystemID: Guid): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if FindRowFromRecordRef(SourceRecordRef, MasterDataMgtCoupling) then begin
            DestinationSystemID := MasterDataMgtCoupling."Integration System ID";
            exit(true);
        end;
    end;

    internal procedure RemoveCouplingToRecord(RecordID: RecordID): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        SysId: Guid;
    begin
        if not FindSystemIdByRecordId(SysId, RecordID) then
            Error(IntegrationRecordNotFoundErr, Format(RecordID, 0, 1));

        if FindRowFromLocalSystemID(SysId, MasterDataMgtCoupling) then begin
            Copy(MasterDataMgtCoupling);
            MasterDataMgtCoupling.Delete(true);
            exit(true);
        end;
    end;

    internal procedure RemoveCouplingToIntegrationSystemID(IntegrationSystemID: Guid; DestinationTableID: Integer): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if FindRowFromIntegrationSystemID(IntegrationSystemID, DestinationTableID, MasterDataMgtCoupling) then begin
            Copy(MasterDataMgtCoupling);
            MasterDataMgtCoupling.Delete(true);
            exit(true);
        end;
    end;

    internal procedure SetNewLocalSystemId(LocalSystemId: Guid)
    begin
        Delete();
        Validate("Local System ID", LocalSystemId);
        Insert();
    end;

    internal procedure SetLastSynchResultFailed(SourceRecRef: RecordRef; DirectionToIntTable: Boolean; JobId: Guid; var MarkedAsSkipped: Boolean)
    var
        MasterDataManagement: Codeunit "Master Data Management";
        Found: Boolean;
    begin
        if DirectionToIntTable then
            Found := FindByRecordID(SourceRecRef.RecordId)
        else
            Found := FindByIntegrationSystemID(MasterDataManagement.GetIntegrationSystemIdFromRecRef(SourceRecRef));
        if Found then begin
            if MarkedAsSkipped then
                Skipped := true;
            if DirectionToIntTable then begin
                if (not Skipped) and ("Last Synch. Int. Result" = "Last Synch. Int. Result"::Failure) then
                    Skipped := false;
                "Last Synch. Int. Job ID" := JobId;
                "Last Synch. Int. Result" := "Last Synch. Int. Result"::Failure
            end else begin
                if (not Skipped) and ("Last Synch. Result" = "Last Synch. Result"::Failure) then
                    Skipped := false;
                "Last Synch. Job ID" := JobId;
                "Last Synch. Result" := "Last Synch. Result"::Failure;
            end;
            if Skipped then
                MarkedAsSkipped := true;
            Modify(true);
        end;
    end;

    internal procedure FindRowFromRecordID(SourceRecordID: RecordID; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"): Boolean
    var
        SysId: Guid;
        Found: Boolean;
    begin
        if FindSystemIdByRecordId(SysId, SourceRecordID) then begin
            Found := FindRowFromLocalSystemID(SysId, MasterDataMgtCoupling);
            if Found then
                if MasterDataMgtCoupling."Table ID" = 0 then begin
                    MasterDataMgtCoupling."Table ID" := SourceRecordID.TableNo();
                    MasterDataMgtCoupling.Modify();
                end;
        end;
        exit(Found);
    end;

    internal procedure FindRowFromRecordRef(SourceRecordRef: RecordRef; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"): Boolean
    var
        SysId: Guid;
        Found: Boolean;
    begin
        if FindSystemIdByRecordRef(SysId, SourceRecordRef) then begin
            Found := FindRowFromLocalSystemID(SysId, MasterDataMgtCoupling);
            if Found then
                if MasterDataMgtCoupling."Table ID" = 0 then begin
                    MasterDataMgtCoupling."Table ID" := SourceRecordRef.Number();
                    MasterDataMgtCoupling.Modify();
                end;
        end;
        exit(Found);
    end;

    internal procedure FindRowFromIntegrationSystemID(IntegrationSystemID: Guid; DestinationTableID: Integer; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"): Boolean
    begin
        MasterDataMgtCoupling.SetRange("Integration System ID", IntegrationSystemID);
        if DestinationTableID <> 0 then
            MasterDataMgtCoupling.SetFilter("Table ID", Format(DestinationTableID));
        exit(MasterDataMgtCoupling.FindFirst());
    end;

    internal procedure FindRowFromLocalSystemID(IntegrationID: Guid; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"): Boolean
    begin
        MasterDataMgtCoupling.SetCurrentKey("Local System ID");
        MasterDataMgtCoupling.SetFilter("Local System ID", IntegrationID);
        exit(MasterDataMgtCoupling.FindFirst());
    end;
}

