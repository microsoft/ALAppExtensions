namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Threading;
using Microsoft.CRM.Contact;

table 7233 "Master Data Full Synch. R. Ln."
{
    Caption = 'Master Data Full Synch. Review Line';
    Permissions = tabledata "Master Data Full Synch. R. Ln." = r,
                  tabledata "Integration Table Mapping" = r,
                  tabledata "Integration Synch. Job" = r,
                  tabledata "Job Queue Entry" = r,
                  tabledata "Job Queue Log Entry" = r,
                  tabledata "Master Data Management Setup" = r;
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
        }
        field(2; "Dependency Filter"; Text[250])
        {
            Caption = 'Dependency Filter';
        }
        field(3; "Session ID"; Integer)
        {
            Caption = 'Session ID';
        }
        field(4; "To Int. Table Job ID"; Guid)
        {
            Caption = 'To Int. Table Job ID';

            trigger OnValidate()
            begin
                "To Int. Table Job Status" := GetSynchJobStatus("To Int. Table Job ID");
            end;
        }
        field(5; "To Int. Table Job Status"; Option)
        {
            Caption = 'To Int. Table Job Status';
            OptionCaption = ' ,Success,In Process,Error';
            OptionMembers = " ",Success,"In Process",Error;
        }
        field(6; "From Int. Table Job ID"; Guid)
        {
            Caption = 'From Int. Table Job ID';

            trigger OnValidate()
            begin
                "From Int. Table Job Status" := GetSynchJobStatus("From Int. Table Job ID");
            end;
        }
        field(7; "From Int. Table Job Status"; Option)
        {
            Caption = 'From Int. Table Job Status';
            OptionCaption = ' ,Success,In Process,Error';
            OptionMembers = " ",Success,"In Process",Error;
        }
        field(8; Direction; Option)
        {
            Caption = 'Direction';
            Editable = false;
            OptionCaption = 'Bidirectional,To Integration Table,From Integration Table';
            OptionMembers = Bidirectional,"To Integration Table","From Integration Table";
        }
        field(9; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';

            trigger OnValidate()
            var
                JobQueueEntry: Record "Job Queue Entry";
            begin
                if not IsNullGuid("Job Queue Entry ID") then
                    if JobQueueEntry.Get("Job Queue Entry ID") then
                        SetJobQueueEntryStatus(JobQueueEntry.Status)
                    else
                        SetJobQueueEntryStatus(JobQueueEntry.Status::Error)
            end;
        }
        field(10; "Job Queue Entry Status"; Option)
        {
            Caption = 'Job Queue Entry Status';
            OptionCaption = ' ,Ready,In Process,Error,On Hold,Finished';
            OptionMembers = " ",Ready,"In Process",Error,"On Hold",Finished;

            trigger OnValidate()
            begin
                if "Job Queue Entry Status" = "Job Queue Entry Status"::"In Process" then
                    "Session ID" := SessionId()
                else
                    "Session ID" := 0;
            end;
        }
        field(13; "Initial Synch Recommendation"; Option)
        {
            OptionCaption = 'Full Synchronization,Couple Records,No Records Found';
            OptionMembers = "Full Synchronization","Couple Records","No Records Found";
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    internal procedure Generate(SkipEntitiesNotFullSyncReady: Boolean)
    var
        InitialSynchRecommendations: Dictionary of [Code[20], Integer];
        DeletedLines: List of [Code[20]];
    begin
        GenerateDataSynchReviewLines(InitialSynchRecommendations, SkipEntitiesNotFullSyncReady, DeletedLines);
    end;

    internal procedure Generate(var InitialSynchRecommendations: Dictionary of [Code[20], Integer]; SkipEntitiesNotFullSyncReady: Boolean; DeletedLines: List of [Code[20]])
    begin
        GenerateDataSynchReviewLines(InitialSynchRecommendations, SkipEntitiesNotFullSyncReady, DeletedLines);
    end;

    internal procedure GetTableName(): Text
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        SourceTableRecordRef: RecordRef;
    begin
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"Integration Master Data Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange(Name, Rec.Name);
        if IntegrationTableMapping.FindFirst() then begin
            SourceTableRecordRef.Open(IntegrationTableMapping."Table ID");
            exit(SourceTableRecordRef.Name());
        end;
        exit('');
    end;

    local procedure GenerateDataSynchReviewLines(var InitialSynchRecommendations: Dictionary of [Code[20], Integer]; SkipNotFullSyncReady: Boolean; DeletedLines: List of [Code[20]])
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationTableMappingFilter: Text;
    begin
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"Integration Master Data Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMappingFilter := 'MDM_BUSINESSRELATION|MDM_CUSTOMER|MDM_VENDOR|MDM_CONTACT|MDM_CURRENCY|MDM_CURRENCYEXCHRATE|MDM_COUNTRYREGION|MDM_POSTCODE|MDM_SALESPERSON|MDM_PAYMENTTERMS|MDM_SHIPPINGAGENT|MDM_SHIPMENTMETHOD|MDM_NUMBERSERIES|MDM_NUMBERSERIESLINE|MDM_MARKETINGSETUP|MDM_SALESRECSETUP|MDM_PURCHPAYSETUP|MDM_VATBUSPGROUP|MDM_VATPRODPGROUP|MDM_GENBUSPGROUP|MDM_GENPRODPGROUP|MDM_TAXAREA|MDM_TAXGROUP|MDM_GLACCOUNT|MDM_VATPOSTINGSETUP|MDM_TAXJURISDICTION|MDM_DIMENSION|MDM_DIMENSIONVALUE|MDM_CUSTOMERPGROUP|MDM_VENDORPGROUP';
        if IntegrationTableMappingFilter <> '' then
            IntegrationTableMapping.SetFilter(Name, IntegrationTableMappingFilter);

        if IntegrationTableMapping.FindSet() then
            repeat
                if not DeletedLines.Contains(IntegrationTableMapping.Name) then
                    InsertOrModifyMasterDataFullSynchRLns(IntegrationTableMapping, InitialSynchRecommendations, SkipNotFullSyncReady)
            until IntegrationTableMapping.Next() = 0;
    end;

    local procedure InsertOrModifyMasterDataFullSynchRLns(IntegrationTableMapping: Record "Integration Table Mapping"; var InitialSynchRecommendations: Dictionary of [Code[20], Integer]; SkipNotFullSyncReady: Boolean)
    var
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        if (not SkipNotFullSyncReady) or (GetInitialSynchRecommendation(IntegrationTableMapping, InitialSynchRecommendations) in ["Initial Synch Recommendation"::"Full Synchronization", "Initial Synch Recommendation"::"Couple Records"]) then begin
            Init();
            Name := IntegrationTableMapping.Name;
            if not Find('=') then begin
                Validate("Dependency Filter", IntegrationTableMapping."Dependency Filter");
                Validate("Initial Synch Recommendation", GetInitialSynchRecommendation(IntegrationTableMapping, InitialSynchRecommendations));
                Direction := IntegrationTableMapping.Direction;
                Session.LogMessage('0000J8S', StrSubstNo(SynchRecommDetailsTxt, Name, Format(Direction), Format("Initial Synch Recommendation")), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                Insert(true);
            end else
                if "Job Queue Entry Status" = "Job Queue Entry Status"::" " then begin
                    Validate("Dependency Filter", IntegrationTableMapping."Dependency Filter");
                    Validate("Initial Synch Recommendation", GetInitialSynchRecommendation(IntegrationTableMapping, InitialSynchRecommendations));
                    Session.LogMessage('0000J8T', StrSubstNo(SynchRecommDetailsTxt, Name, Format(Direction), Format("Initial Synch Recommendation")), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                    Modify(true);
                end;
        end;
    end;

    internal procedure Start()
    var
        TempMasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln." temporary;
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataManagement: Codeunit "Master Data Management";
        JobQueueEntryID: Guid;
    begin
        if FindLinesThatCanBeStarted(TempMasterDataFullSynchRLn) then
            repeat
                if TempMasterDataFullSynchRLn."Initial Synch Recommendation" = TempMasterDataFullSynchRLn."Initial Synch Recommendation"::"Full Synchronization" then
                    JobQueueEntryID := MasterDataManagement.EnqueueFullSyncJob(TempMasterDataFullSynchRLn.Name);
                if TempMasterDataFullSynchRLn."Initial Synch Recommendation" = TempMasterDataFullSynchRLn."Initial Synch Recommendation"::"Couple Records" then
                    if IntegrationTableMapping.Get(TempMasterDataFullSynchRLn.Name) then
                        if MasterDataManagement.MatchBasedCoupling(IntegrationTableMapping."Table ID", true, true, false) then begin
                            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                            JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Int. Coupling Job Runner");
                            JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
                            if JobQueueEntry.FindFirst() then
                                JobQueueEntryID := JobQueueEntry.ID;
                        end;
                Get(TempMasterDataFullSynchRLn.Name);
                Validate("Job Queue Entry ID", JobQueueEntryID);
                Modify(true);
                Commit();
            until TempMasterDataFullSynchRLn.Next() = 0;
    end;


    local procedure GetInitialSynchRecommendation(IntegrationTableMapping: Record "Integration Table Mapping"; var InitialSynchRecommendations: Dictionary of [Code[20], Integer]): Option
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        BCRecRef: RecordRef;
        BCRecRefIsEmpty: Boolean;
        IntegrationRecRefIsEmpty: Boolean;
        DependencyInitialSynchRecommendation: Option "Full Synchronization","Couple Records","No Records Found";
    begin
        if InitialSynchRecommendations.ContainsKey(IntegrationTableMapping.Name) then
            exit(InitialSynchRecommendations.Get(IntegrationTableMapping.Name));

        if not MasterDataManagementSetup.Get() then
            exit(DependencyInitialSynchRecommendation::"No Records Found");

        BCRecRef.Open(IntegrationTableMapping."Table ID");
        BCRecRefIsEmpty := BCRecRef.IsEmpty();
        IntegrationRecRefIsEmpty := (MasterDataManagement.GetIntegrationRecRefCount(IntegrationTableMapping) = 0);
        if BCRecRef.Number() = Database::Contact then
            exit("Initial Synch Recommendation"::"Couple Records");
        if BCRecRefIsEmpty and IntegrationRecRefIsEmpty then
            exit("Initial Synch Recommendation"::"No Records Found");
        if (not BCRecRefIsEmpty) and (not IntegrationRecRefIsEmpty) then
            exit("Initial Synch Recommendation"::"Couple Records");

        exit("Initial Synch Recommendation"::"Full Synchronization");
    end;

    local procedure UpdateAsSynchJobStarted(MapName: Code[20]; JobID: Guid; SynchDirection: Option)
    begin
        Get(MapName);
        Validate("Job Queue Entry ID");
        case SynchDirection of
            Direction::"From Integration Table":
                Validate("From Int. Table Job ID", JobID);
            Direction::"To Integration Table":
                Validate("To Int. Table Job ID", JobID);
        end;
        Modify(true);
        Commit();
    end;

    local procedure UpdateAsSynchJobFinished(MapName: Code[20]; SynchDirection: Option)
    begin
        Get(MapName);
        Validate("Job Queue Entry ID");
        case SynchDirection of
            Direction::"From Integration Table":
                Validate("From Int. Table Job ID");
            Direction::"To Integration Table":
                Validate("To Int. Table Job ID");
        end;
        Modify(true);
        Commit();
    end;

    local procedure GetSynchJobStatus(JobID: Guid): Integer
    var
        IntegrationSynchJob: Record "Integration Synch. Job";
    begin
        if IsNullGuid(JobID) then
            exit("To Int. Table Job Status"::" ");

        IntegrationSynchJob.Get(JobID);
        if IntegrationSynchJob."Finish Date/Time" = 0DT then
            exit("To Int. Table Job Status"::"In Process");

        if IntegrationSynchJob.AreSomeRecordsFailed() then
            exit("To Int. Table Job Status"::Error);

        exit("To Int. Table Job Status"::Success);
    end;

    local procedure FindLinesThatCanBeStarted(var TempMasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln." temporary): Boolean
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        TempMasterDataFullSynchRLn.Reset();
        TempMasterDataFullSynchRLn.DeleteAll();

        MasterDataFullSynchRLn.SetRange(
          "Job Queue Entry Status", MasterDataFullSynchRLn."Job Queue Entry Status"::" ");
        if MasterDataFullSynchRLn.FindSet() then
            repeat
                if AreAllParentalJobsFinished(MasterDataFullSynchRLn."Dependency Filter") then begin
                    TempMasterDataFullSynchRLn := MasterDataFullSynchRLn;
                    TempMasterDataFullSynchRLn.Insert();
                end;
            until MasterDataFullSynchRLn.Next() = 0;
        exit(TempMasterDataFullSynchRLn.FindSet());
    end;

    local procedure AreAllParentalJobsFinished(DependencyFilter: Text[250]): Boolean
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        if DependencyFilter <> '' then begin
            MasterDataFullSynchRLn.SetFilter(Name, DependencyFilter);
            MasterDataFullSynchRLn.SetFilter(
              "Job Queue Entry Status", '<>%1', MasterDataFullSynchRLn."Job Queue Entry Status"::Finished);
            MasterDataFullSynchRLn.SetFilter("Initial Synch Recommendation", '<>%1', MasterDataFullSynchRLn."Initial Synch Recommendation"::"No Records Found");
            exit(MasterDataFullSynchRLn.IsEmpty());
        end;
        exit(true);
    end;

    internal procedure FullSynchFinished(IntegrationTableMapping: Record "Integration Table Mapping"; SynchDirection: Option)
    begin
        if IntegrationTableMapping.IsFullSynch() then
            UpdateAsSynchJobFinished(IntegrationTableMapping."Parent Name", SynchDirection);
    end;

    internal procedure FullSynchStarted(IntegrationTableMapping: Record "Integration Table Mapping"; JobID: Guid; SynchDirection: Option)
    begin
        if IntegrationTableMapping.IsFullSynch() then
            UpdateAsSynchJobStarted(IntegrationTableMapping."Parent Name", JobID, SynchDirection);
    end;

    internal procedure OnBeforeModifyJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        NameToGet: Code[20];
    begin
        NameToGet := GetIntTableMappingNameJobQueueEntry(JobQueueEntry);
        if NameToGet = '' then
            exit;
        if Get(NameToGet) then begin
            SetJobQueueEntryStatus(JobQueueEntry.Status);
            Modify();

            if IsJobQueueEntryProcessed(JobQueueEntry) then
                Start();
        end;
    end;

    local procedure GetIntTableMappingNameJobQueueEntry(JobQueueEntry: Record "Job Queue Entry"): Code[20]
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        RecID: RecordID;
        RecRef: RecordRef;
    begin
        if Format(JobQueueEntry."Record ID to Process") = '' then
            exit;
        RecID := JobQueueEntry."Record ID to Process";
        if RecID.TableNo = DATABASE::"Integration Table Mapping" then begin
            RecRef := RecID.GetRecord();
            RecRef.SetTable(IntegrationTableMapping);
            if not IntegrationTableMapping.Find() then
                exit('');
            if IntegrationTableMapping.IsFullSynch() then
                exit(IntegrationTableMapping."Parent Name");
        end;
    end;

    local procedure IsJobQueueEntryProcessed(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        xJobQueueEntry: Record "Job Queue Entry";
    begin
        xJobQueueEntry := JobQueueEntry;
        xJobQueueEntry.Find();
        exit(
          (xJobQueueEntry.Status = xJobQueueEntry.Status::"In Process") and
          (xJobQueueEntry.Status <> JobQueueEntry.Status));
    end;

    internal procedure IsActiveSession(): Boolean
    begin
        exit(IsSessionActive("Session ID"));
    end;

    internal procedure IsThereActiveSessionInProgress(): Boolean
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        MasterDataFullSynchRLn.SetFilter("Session ID", '<>0');
        MasterDataFullSynchRLn.SetRange("Job Queue Entry Status", "Job Queue Entry Status"::"In Process");
        if MasterDataFullSynchRLn.FindSet() then
            repeat
                if MasterDataFullSynchRLn.IsActiveSession() then
                    exit(true);
            until MasterDataFullSynchRLn.Next() = 0;
        exit(false);
    end;

    internal procedure IsThereBlankStatusLine(): Boolean
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        MasterDataFullSynchRLn.SetRange("Job Queue Entry Status", 0);
        exit(not MasterDataFullSynchRLn.IsEmpty());
    end;

    local procedure SetJobQueueEntryStatus(Status: Option)
    begin
        // shift the options to have an undefined state ' ' as 0.
        Validate("Job Queue Entry Status", Status + 1);
    end;

    internal procedure ShowJobQueueLogEntry()
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        JobQueueLogEntry.SetRange(ID, "Job Queue Entry ID");
        PAGE.RunModal(PAGE::"Job Queue Log Entries", JobQueueLogEntry);
    end;

    internal procedure ShowSynchJobLog(ID: Guid)
    var
        IntegrationSynchJob: Record "Integration Synch. Job";
    begin
        IntegrationSynchJob.SetRange(ID, ID);
        PAGE.RunModal(PAGE::"Integration Synch. Job List", IntegrationSynchJob);
    end;

    internal procedure GetStatusStyleExpression(StatusText: Text): Text
    begin
        case StatusText of
            'Error':
                exit('Unfavorable');
            'Finished', 'Success':
                exit('Favorable');
            'In Process':
                exit('Ambiguous');
            else
                exit('Subordinate');
        end;
    end;

    internal procedure GetInitialSynchRecommendationStyleExpression(IntialSynchRecomeendation: Text): Text
    begin
        case IntialSynchRecomeendation of
            'Dependency not satisfied':
                exit('Subordinate');
            'Full Synchronization', 'No Records Found':
                exit('Subordinate');
            'Couple Records':
                exit('Ambiguous')
            else
                exit('Subordinate');
        end;
    end;

    var
        SynchRecommDetailsTxt: Label 'The synchronization mode for table %1, with the direction %2 is %3', Comment = '%1 = Name of Business Central table, %2 = Synchronization Direction, %3 = Synchronization Recommendation', Locked = true;
}

