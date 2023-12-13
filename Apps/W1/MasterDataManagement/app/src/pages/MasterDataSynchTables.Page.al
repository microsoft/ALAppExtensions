namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Globalization;
using System.Reflection;
using System.Threading;

page 7233 "Master Data Synch. Tables"
{
    ApplicationArea = Suite;
    Caption = 'Synchronization Tables';
    PageType = List;
    SourceTable = "Integration Table Mapping";
    DelayedInsert = true;
    SourceTableView = where("Delete After Synchronization" = const(false),
                            Type = const(7230));
    UsageCategory = Lists;
    AdditionalSearchTerms = 'mdm,master data management,master data';
    Permissions = tabledata "Integration Table Mapping" = r,
                  tabledata "Job Queue Entry" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the table.';
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if synchronization is enabled for this table.';
                }
                field(TableCaptionValue; Rec."Table Caption")
                {
                    ApplicationArea = Suite;
                    Caption = 'Table';
                    Editable = false;
                    ToolTip = 'Specifies the table caption.';

                    trigger OnAssistEdit()
                    var
                        IntegrationTableMapping: Record "Integration Table Mapping";
                        IntegrationFieldMapping: Record "Integration Field Mapping";
                        AllObjWithCaption: Record AllObjWithCaption;
                        TableMetadata: Record "Table Metadata";
                        RecRef: RecordRef;
                        ExistingSynchTableNos: List of [Integer];
                        RelatedTablesToAdd: List of [Integer];
                        RelatedTablesToAddText: Text;
                        TableFilterTxt: Text;
                        RelatedTableNo: Integer;
                    begin
                        if Rec."Table ID" <> 0 then
                            exit;

                        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
                        if IntegrationTableMapping.FindSet() then
                            repeat
                                if TableFilterTxt = '' then
                                    TableFilterTxt := '<>' + Format(IntegrationTableMapping."Table ID")
                                else
                                    TableFilterTxt += '&<>' + Format(IntegrationTableMapping."Table ID");
                                ExistingSynchTableNos.Add(IntegrationTableMapping."Table ID");
                            until IntegrationTableMapping.Next() = 0;

                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        AllObjWithCaption.SetFilter("Object ID", TableFilterTxt);
                        if Page.RunModal(Page::"Table Objects", AllObjWithCaption) <> Action::LookupOK then
                            exit;

                        if not TableMetadata.Get(AllObjWithCaption."Object ID") then
                            Error(TableMetadataNotFoundErr, AllObjWithCaption."Object ID");

                        if not TableMetadata.DataPerCompany then
                            Error(TableNotPerCompanyErr, AllObjWithCaption."Object Name");

                        if TableMetadata.TableType <> TableMetadata.TableType::Normal then
                            Error(TableNotOfTypeNormalErr, AllObjWithCaption."Object Name");

                        RecRef.Open(AllObjWithCaption."Object ID");
                        if not RecRef.WritePermission() then
                            Error(TablePermissionMissingErr, AllObjWithCaption."Object Name");
                        RecRef.Close();

                        FindRelatedTables(ExistingSynchTableNos, RelatedTablesToAdd, RelatedTablesToAddText, AllObjWithCaption."Object ID");
                        AddTable(IntegrationTableMapping, AllObjWithCaption."Object Name", AllObjWithCaption."Object ID");
                        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);

                        if RelatedTablesToAdd.Count() > 0 then
                            if Confirm(StrSubstno(RelatedTablesQst, RelatedTablesToAddText)) then begin
                                IntegrationTableMapping.Validate(Status, IntegrationTableMapping.Status::Disabled);
                                IntegrationTableMapping.Modify();
                                foreach RelatedTableNo in RelatedTablesToAdd do
                                    if TableMetadata.Get(RelatedTableNo) then
                                        if (TableMetadata.TableType = TableMetadata.TableType::Normal) and TableMetadata.DataPerCompany then begin
                                            AddTable(IntegrationTableMapping, TableMetadata.TableName, RelatedTableNo);
                                            IntegrationTableMapping.Validate(Status, IntegrationTableMapping.Status::Disabled);
                                            IntegrationTableMapping.Modify();
                                        end;
                                Message(StrSubstNo(RelatedTablesAddedMsg, AllObjWithCaption."Object Name", RelatedTablesToAddText));
                                exit;
                            end;

                        Commit();
                        Page.Run(Page::"Master Data Synch. Fields", IntegrationFieldMapping);
                    end;
                }
                field(TableFilterValue; TableFilter)
                {
                    ApplicationArea = Suite;
                    Caption = 'Table Filter';
                    ToolTip = 'Specifies the filter on the table to control which records should be synchronized.';
                    visible = false;

                    trigger OnAssistEdit()
                    var
                        FilterPageBuilder: FilterPageBuilder;
                    begin
                        FilterPageBuilder.AddTable(Rec."Table Caption", Rec."Table ID");
                        if TableFilter <> '' then
                            FilterPageBuilder.SetView(Rec."Table Caption", TableFilter);
                        if FilterPageBuilder.RunModal() then begin
                            TableFilter := FilterPageBuilder.GetView(Rec."Table Caption", false);
                            Rec.SetTableFilter(TableFilter);
                        end;
                    end;
                }
                field("Overwrite Local Change"; Rec."Overwrite Local Change")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the synchronization engine should overwrite local changes that are done since last synchronization.';
                }
                field(IntegrationTableCaptionValue; IntegrationTableCaptionValue)
                {
                    ApplicationArea = Suite;
                    Caption = 'Integration Table';
                    Enabled = false;
                    ToolTip = 'Specifies the caption of the table.';
                    Visible = false;
                }
                field("Table Config Template Code"; Rec."Table Config Template Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a configuration template to use when creating new records out of the table in the source company.';
                    Visible = false;
                }
                field("Synch. Int. Tbl. Mod. On Fltr."; Rec."Synch. Int. Tbl. Mod. On Fltr.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a date/time that is used to determine which records to synchronize to the source company. Only records that have SystemModifiedAt value greater than this value, will be synchronized. This value keeps changing with every synchronization job.';
                    Visible = false;
                }
                field("Synch. Modified On Filter"; Rec."Synch. Modified On Filter")
                {
                    Caption = 'Synchronize Changes Since';
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a date/time that is used to determine which records to synchronize from the source company. Only records that have SystemModifiedAt value greater than this value, will be synchronized. This value keeps changing with every synchronization job.';
                }
                field(IntegrationTableFilter; IntegrationTableFilterHint)
                {
                    ApplicationArea = Suite;
                    Caption = 'Table Filter';
                    ToolTip = 'Specifies a filter on the table in the source company to control which records should be synchronized.';

                    trigger OnDrillDown()
                    var
                        MasterDataManagement: Codeunit "Master Data Management";
                        FilterPageBuilder: FilterPageBuilder;
                    begin
                        FilterPageBuilder.AddTable(IntegrationTableCaptionValue, Rec."Integration Table ID");
                        if IntegrationTableFilter <> '' then
                            FilterPageBuilder.SetView(IntegrationTableCaptionValue, IntegrationTableFilter);
                        Commit();
                        if FilterPageBuilder.RunModal() then begin
                            IntegrationTableFilter := FilterPageBuilder.GetView(IntegrationTableCaptionValue, false);
                            Session.LogMessage('0000J8R', StrSubstNo(UserEditedIntegrationTableFilterTxt, Rec.Name), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                            Rec.SetIntegrationTableFilter(IntegrationTableFilter);
                        end;
                    end;
                }
                field("Synch. Only Coupled Records"; Rec."Synch. Only Coupled Records")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if synchronization jobs should synchronize only currently coupled records. To synchronize newly inserted records, uncheck this checkbox.';
                    Visible = false;
                }
                field("Disable Event Job Resch."; Rec."Disable Event Job Resch.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if event-based rescheduling of synchronization jobs should be turned off for this table.';
                    Visible = false;
                }
                field("Deletion-Conflict Resolution"; Rec."Deletion-Conflict Resolution")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the action to take when a coupled record that is attempting to synchronize is deleted locally.';
                    Visible = false;
                }
                field("Update-Conflict Resolution"; Rec."Update-Conflict Resolution")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the action to take when a coupled record is updated both in the source and in the local company.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FieldMapping)
            {
                ApplicationArea = Suite;
                Caption = 'Fields';
                Enabled = HasRecords;
                Image = Relationship;
                RunObject = Page "Master Data Synch. Fields";
                RunPageLink = "Integration Table Mapping Name" = field(Name);
                ToolTip = 'Shows the fields that are synchronized.';
            }
            action(ResetConfiguration)
            {
                ApplicationArea = Suite;
                Caption = 'Use Default Synchronization Setup';
                Image = ResetStatus;
                ToolTip = 'Resets the tables, fields and synchronization jobs to the default values for the connection with the source company. All default synchronization table definitions are deleted and recreated.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                    DataSynchMgt: Codeunit "Master Data Management";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);

                    if IntegrationTableMapping.IsEmpty() then
                        Error(NoRecSelectedErr);

                    DataSynchMgt.ResetIntTableMappingDefaultConfiguration(IntegrationTableMapping);

                    if Confirm(JobQEntryCreatedQst) then
                        ShowJobQueueEntry(IntegrationTableMapping);
                end;
            }
            action(JobQueueEntry)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Job Queue Entry';
                Enabled = HasRecords;
                Image = JobListSetup;
                ToolTip = 'View or edit the job queue entry for the synchronization of this table.';

                trigger OnAction()
                begin
                    ShowJobQueueEntry(Rec);
                end;
            }
            action("View Integration Synch. Job Log")
            {
                ApplicationArea = Suite;
                Caption = 'Synchronization Log';
                Enabled = HasRecords;
                Image = Log;
                ToolTip = 'View the status of the individual synchronization jobs that have been run for this table.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    Rec.ShowSynchronizationLog(IntegrationTableMapping);
                end;
            }
            action(Enable)
            {
                ApplicationArea = Suite;
                Caption = 'Enable';
                Image = EnableAllBreakpoints;
                ToolTip = 'Enables the synchronization of the selected tables.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    if IntegrationTableMapping.FindSet() then
                        repeat
                            IntegrationTableMapping.Validate(Status, IntegrationTableMapping.Status::Enabled);
                            IntegrationTableMapping.Modify(true);
                        until IntegrationTableMapping.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(Disable)
            {
                ApplicationArea = Suite;
                Caption = 'Disable';
                Image = EnableAllBreakpoints;
                ToolTip = 'Disables the synchronization of the selected tables.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    if IntegrationTableMapping.FindSet() then
                        repeat
                            IntegrationTableMapping.Validate(Status, IntegrationTableMapping.Status::Disabled);
                            IntegrationTableMapping.Modify(true);
                        until IntegrationTableMapping.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(SynchronizeNow)
            {
                ApplicationArea = Suite;
                Caption = 'Synchronize Modified Records';
                Enabled = HasRecords and (Rec."Parent Name" = '');
                Image = Refresh;
                ToolTip = 'Synchronize records that have been modified since the last time they were synchronized.';

                trigger OnAction()
                var
                    MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
                    MasterDataManagement: Codeunit "Master Data Management";
                    IntegrationSynchJobList: Page "Integration Synch. Job List";
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    if Rec.IsEmpty() then
                        exit;

                    MasterDataMgtCoupling.SetRange("Table ID", Rec."Table ID");
                    if MasterDataMgtCoupling.IsEmpty() then begin
                        Message(NoCoupledRecordsMsg);
                        exit;
                    end;

                    Rec.SynchronizeNow(false);
                    Message(SynchronizeModifiedScheduledMsg, IntegrationSynchJobList.Caption);
                end;
            }
            action(SynchronizeAll)
            {
                ApplicationArea = Suite;
                Caption = 'Run Full Synchronization';
                Enabled = HasRecords and (Rec."Parent Name" = '');
                Image = RefreshLines;
                ToolTip = 'Start a job for full synchronization from records in the chosen source company for each of the selected tables.';

                trigger OnAction()
                var
                    MasterDataManagement: Codeunit "Master Data Management";
                    IntegrationSynchJobList: Page "Integration Synch. Job List";
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    if Rec.IsEmpty() then
                        exit;

                    if not Confirm(StartFullSynchronizationQst) then
                        exit;

                    Rec.SynchronizeNow(true, true);
                    Message(FullSynchronizationScheduledMsg, IntegrationSynchJobList.Caption);
                end;
            }
            action("View Integration Uncouple Job Log")
            {
                ApplicationArea = Suite;
                Caption = 'Integration Uncouple Job Log';
                Enabled = HasRecords;
                Visible = DataSynchEnabled;
                Image = Log;
                ToolTip = 'View the status of jobs for uncoupling records.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    Rec.ShowUncouplingLog(IntegrationTableMapping);
                end;
            }
            action("View Integration Coupling Job Log")
            {
                ApplicationArea = Suite;
                Caption = 'Integration Coupling Job Log';
                Enabled = HasRecords;
                Visible = DataSynchEnabled;
                Image = Log;
                ToolTip = 'View the status of jobs for match-based coupling of records.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                begin
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    Rec.ShowCouplingLog(IntegrationTableMapping);
                end;
            }
            action(RemoveCoupling)
            {
                ApplicationArea = Suite;
                Caption = 'Delete Couplings';
                Enabled = HasRecords and (Rec."Parent Name" = '');
                Visible = DataSynchEnabled;
                Image = UnLinkAccount;
                ToolTip = 'Delete couplings for the selected tables.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                    FilteredIntegrationTableMapping: Record "Integration Table Mapping";
                    MasterDataManagement: Codeunit "Master Data Management";
                    IntegrationSynchJobList: Page "Integration Synch. Job List";
                    ForegroundCount: Integer;
                    JobCount: Integer;
                    ConfirmMsg: Text;
                    ResultMsg: Text;
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    if not IntegrationTableMapping.FindSet() then
                        exit;

                    CurrPage.SetSelectionFilter(FilteredIntegrationTableMapping);
                    FilteredIntegrationTableMapping.SetRange(Type, FilteredIntegrationTableMapping.Type::"Master Data Management");
                    FilteredIntegrationTableMapping.SetRange("Uncouple Codeunit ID", Codeunit::"Master Data Mgt. Tbl. Uncouple");
                    if not FilteredIntegrationTableMapping.IsEmpty() then begin
                        ConfirmMsg := StartUncouplingQst;
                        ResultMsg := RemoveCouplingsScheduledMsg;
                    end else begin
                        ConfirmMsg := StartUncouplingForegroundQst;
                        ResultMsg := UncouplingCompletedMsg;
                    end;
                    if not Confirm(ConfirmMsg) then
                        exit;

                    repeat
                        MasterDataManagement.RemoveCoupling(IntegrationTableMapping."Table ID", IntegrationTableMapping."Integration Table ID");
                        if IntegrationTableMapping."Uncouple Codeunit ID" = Codeunit::"Master Data Mgt. Tbl. Uncouple" then
                            JobCount += 1
                        else
                            ForegroundCount += 1;
                    until IntegrationTableMapping.Next() = 0;

                    if ForegroundCount > 0 then
                        Message(ResultMsg, IntegrationSynchJobList.Caption, JobCount, StrSubstNo(RemoveCouplingsForegroundMsg, ForegroundCount))
                    else
                        Message(ResultMsg, IntegrationSynchJobList.Caption, JobCount, '');
                end;
            }
            action(MatchBasedCoupling)
            {
                ApplicationArea = Suite;
                Caption = 'Match-Based Coupling';
                Enabled = HasRecords and (Rec."Parent Name" = '');
                Visible = DataSynchEnabled;
                Image = LinkAccount;
                ToolTip = 'Couple existing records in the selected tables based on matching criteria.';

                trigger OnAction()
                var
                    IntegrationTableMapping: Record "Integration Table Mapping";
                    MasterDataManagement: Codeunit "Master Data Management";
                    IntegrationSynchJobList: Page "Integration Synch. Job List";
                    ConfirmMsg: Text;
                    ResultMsg: Text;
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    CurrPage.SetSelectionFilter(IntegrationTableMapping);
                    if not IntegrationTableMapping.FindFirst() then
                        exit;

                    ConfirmMsg := StartMatchBasedCouplingQst;
                    ResultMsg := MatchBasedCouplingScheduledMsg;
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if MasterDataManagement.MatchBasedCoupling(IntegrationTableMapping."Table ID") then
                        Message(ResultMsg, IntegrationSynchJobList.Caption);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(FieldMapping_Promoted; FieldMapping)
                {
                }
                actionref("View Integration Synch. Job Log_Promoted"; "View Integration Synch. Job Log")
                {
                }
                actionref(SynchronizeNow_Promoted; SynchronizeNow)
                {
                }
                actionref(JobQueueEntry_Promoted; JobQueueEntry)
                {
                }
            }
        }
    }

    local procedure FindRelatedTables(var ExistingSynchTableNos: List of [Integer]; var RelatedTablesToAdd: List of [Integer]; var RelatedTablesToAddText: Text; TableId: Integer)
    var
        Field: Record Field;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        if TableId = 0 then
            exit;

        Field.SetRange(TableNo, TableId);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetFilter(RelationTableNo, '<>' + Format(TableId));
        if not Field.FindSet() then
            exit;

        repeat
            if not (ExistingSynchTableNos.Contains(Field.RelationTableNo) or RelatedTablesToAdd.Contains(Field.RelationTableNo)) then
                if TableMetadata.Get(Field.RelationTableNo) then
                    if (TableMetadata.TableType = TableMetadata.TableType::Normal) and TableMetadata.DataPerCompany then begin
                        RecRef.Open(Field.RelationTableNo);
                        if RecRef.WritePermission() then begin
                            RelatedTablesToAdd.Add(Field.RelationTableNo);
                            if RelatedTablesToAddText = '' then
                                RelatedTablesToAddText := TableMetadata.Name
                            else
                                RelatedTablesToAddText += ', ' + TableMetadata.Name;
                            FindRelatedTables(ExistingSynchTableNos, RelatedTablesToAdd, RelatedTablesToAddText, Field.RelationTableNo);
                        end;
                        RecRef.Close();
                    end;
        until Field.Next() = 0;
    end;

    local procedure AddTable(var IntegrationTableMapping: Record "Integration Table Mapping"; TableName: Text; TableNo: Integer)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
        AllFieldsDisabledList: List of [Integer];
        IntegrationTableMappingName: Code[20];
        I: Integer;
        ShouldEnqueueJob: Boolean;
    begin
        IntegrationTableMappingName := CopyStr('MDM_' + DelChr(Uppercase(TableName), '=', DelChr(Uppercase(TableName), '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')), 1, MaxStrLen(IntegrationTableMappingName));
        IntegrationTableMapping.Reset();
        IntegrationTableMapping.SetRange(Name, IntegrationTableMappingName);
        I := 1;
        while not IntegrationTableMapping.IsEmpty() do begin
            IntegrationTableMappingName := 'MDM_MAPPING' + Format(I);
            IntegrationTableMapping.SetRange(Name, IntegrationTableMappingName);
            I += 1;
        end;

        ShouldEnqueueJob := true;
        if MasterDataManagementSetup.Get() then
            ShouldEnqueueJob := (not MasterDataManagementSetup."Delay Job Scheduling");
        MasterDataManagementSetupDefaults.GenerateIntegrationTableMapping(IntegrationTableMapping, AllFieldsDisabledList, IntegrationTableMappingName, TableNo, '', false, ShouldEnqueueJob);
    end;

    trigger OnAfterGetRecord()
    begin
        IntegrationTableCaptionValue := ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Table, Rec."Integration Table ID");
        IntegrationFieldCaptionValue := GetFieldCaption();
        IntegrationFieldTypeValue := GetFieldType();

        TableFilter := Rec.GetTableFilter();
        IntegrationTableFilter := Rec.GetIntegrationTableFilter();

        if IntegrationTableFilter <> '' then
            IntegrationTableFilterHint := EditIntegrationTableFilterTxt
        else
            IntegrationTableFilterHint := '';

        HasRecords := not Rec.IsEmpty();
    end;

    trigger OnInit()
    var
        MasterDataMgtUpgrade: Codeunit "Master Data Mgt. Upgrade";
    begin
        SetDataSynchEnabledState();
        MasterDataMgtUpgrade.UpgradeSynchTableCaptions();
    end;

    var
        ObjectTranslation: Record "Object Translation";
        TypeHelper: Codeunit "Type Helper";
        IntegrationFieldCaptionValue: Text;
        IntegrationFieldTypeValue: Text;
        IntegrationTableCaptionValue: Text[250];
        TableFilter: Text;
        IntegrationTableFilter: Text;
        IntegrationTableFilterHint: Text;
        JobQEntryCreatedQst: Label 'A synchronization job queue entry has been created. \\Do you want to view the job queue entry?';
        StartFullSynchronizationQst: Label 'You are about to synchronize all data within the mapping. \\The synchronization will run in the background, so you can continue with other tasks.\\Do you want to continue?';
        StartUncouplingQst: Label 'You are about to uncouple the selected mappings, which means data for the records will no longer synchronize. \\The uncoupling will run in the background, so you can continue with other tasks.\\Do you want to continue?';
        StartMatchBasedCouplingQst: Label 'You are about to couple Business Central records to the source company records from the selected mapping, based on the matching criteria that you must define. \\The coupling will run in the background, so you can continue with other tasks.\\Do you want to continue?';
        StartUncouplingForegroundQst: Label 'You are about to uncouple the selected mappings, which means data for the records will no longer synchronize. \\Do you want to continue?';
        UncouplingCompletedMsg: Label 'Uncoupling completed.';
        SynchronizeModifiedScheduledMsg: Label 'Synchronization is scheduled for Modified Records. \\Details are available on the %1 page.', Comment = '%1 caption from page Integration Synch. Job List';
        FullSynchronizationScheduledMsg: Label 'Full Synchronization is scheduled. \\Details are available on the %1 page.', Comment = '%1 caption from page Integration Synch. Job List';
        RemoveCouplingsScheduledMsg: Label 'Uncoupling is scheduled for %2 mappings. %3 \\Details are available on the %1 page.', Comment = '%1 - caption from page 5344, %2 - scheduled job count, %3 - additional foreground job message';
        MatchBasedCouplingScheduledMsg: Label 'Match-based coupling is scheduled. \\Details are available on the %1 page.', Comment = '%1 - caption from page 5344';
        RemoveCouplingsForegroundMsg: Label '%1 mappings are uncoupled.', Comment = '%1 - foreground uncoupling count';
        NoRecSelectedErr: Label 'You must choose at least one integration table mapping.';
        UserEditedIntegrationTableFilterTxt: Label 'The user edited the Integration Table Filter on %1 mapping.', Locked = true;
        EditIntegrationTableFilterTxt: Label '<Edit table filter>';
        NoCoupledRecordsMsg: label 'No records of this table are currently coupled to records from the source company. \\Choose the action Run Full Synchronization.';
        RelatedTablesQst: label 'The chosen table has a relation to the following tables that are currently not included in the synchronization: %1. \\Do you want to synchronize these tables too?', Comment = '%1 - comma-separated list of table names';
        RelatedTablesAddedMsg: label 'Table %1 and related tables: %2 are added to the synchronization with state set to Disabled. \\Open Synchronization Tables page, choose synchronization fields for each of the added tables and then set their status to Enabled.', Comment = '%1 - a table name, %2 - comma-separated list of table names';
        TableMetadataNotFoundErr: label 'Metadata for table %1 cannot be loaded. Choose another table.', Comment = '%1 - a table name';
        TableNotPerCompanyErr: label 'Table %1 is shared across all companies of this environment. Choose another table.', Comment = '%1 - a table name';
        TableNotOfTypeNormalErr: label 'Table %1 is either declared as temporary, a query or as an interface for accessing an external entity. Choose another table.', Comment = '%1 - a table name';
        TablePermissionMissingErr: label 'Your license doesn''t grant you permissions for writing into table %1. Choose another table.', Comment = '%1 - a table name';
        HasRecords: Boolean;
        DataSynchEnabled: Boolean;

    local procedure GetFieldCaption(): Text
    var
        "Field": Record "Field";
    begin
        if TypeHelper.GetField(Rec."Integration Table ID", Rec."Integration Table UID Fld. No.", Field) then
            exit(Field."Field Caption");
    end;

    local procedure GetFieldType(): Text
    var
        "Field": Record "Field";
    begin
        Field.Type := Rec."Int. Table UID Field Type";
        exit(Format(Field.Type))
    end;

    local procedure SetDataSynchEnabledState()
    var
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        DataSynchEnabled := MasterDataManagement.IsEnabled();
    end;

    local procedure ShowJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping");
    var
        JQueueEntry: Record "Job Queue Entry";
    begin
        JQueueEntry.SetRange("Object Type to Run", JQueueEntry."Object Type to Run"::Codeunit);
        JQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        if JQueueEntry.FindFirst() then
            Page.Run(Page::"Job Queue Entries", JQueueEntry);
    end;
}



