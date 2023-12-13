namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;

xmlport 7231 ImportMDMSetup
{
    Caption = 'Import Master Data Management Setup';
    Direction = Import;
    Format = Xml;
    UseRequestPage = false;
    Permissions = tabledata "Integration Field Mapping" = rimd,
                  tabledata "Integration Table Mapping" = rimd;

    schema
    {
        textelement(root)
        {
            XmlName = 'Root';
            tableelement(integrationTableMapping; "Integration Table Mapping")
            {
                AutoSave = true;
                AutoUpdate = true;
                XmlName = 'IntegrationTableMapping';

                fieldattribute(IntegrationTableMapping_Name; integrationTableMapping.Name)
                {
                }
                fieldattribute(IntegrationTableMapping_TableID; integrationTableMapping."Table ID")
                {
                }
                fieldattribute(IntegrationTableMapping_IntegrationTableID; integrationTableMapping."Integration Table ID")
                {
                }
                fieldattribute(IntegrationTableMapping_SynchCodeunitID; integrationTableMapping."Synch. Codeunit ID")
                {
                }
                fieldattribute(IntegrationTableMapping_IntegrationTableUIDFldNo; integrationTableMapping."Integration Table UID Fld. No.")
                {
                }
                fieldattribute(IntegrationTableMapping_IntTblModifiedOnFldNo; integrationTableMapping."Int. Tbl. Modified On Fld. No.")
                {
                }
                fieldattribute(IntegrationTableMapping_IntTableUIDFieldType; integrationTableMapping."Int. Table UID Field Type")
                {
                }
                fieldattribute(IntegrationTableMapping_TableConfigTemplateCode; integrationTableMapping."Table Config Template Code")
                {
                }
                fieldattribute(IntegrationTableMapping_IntTblConfigTemplateCode; integrationTableMapping."Int. Tbl. Config Template Code")
                {
                }
                fieldattribute(IntegrationTableMapping_Direction; integrationTableMapping.Direction)
                {
                }
                fieldattribute(IntegrationTableMapping_IntTblCaptionPrefix; integrationTableMapping."Int. Tbl. Caption Prefix")
                {
                }
                textattribute(tableFilterText)
                {
                    XmlName = 'IntegrationTableMapping_TableFilter';
                }
                textattribute(integrationTableFilterText)
                {
                    XmlName = 'IntegrationTableMapping_IntegrationTableFilter';
                }
                fieldattribute(IntegrationTableMapping_SynchOnlyCoupledRecords; integrationTableMapping."Synch. Only Coupled Records")
                {
                }
                fieldattribute(IntegrationTableMapping_Type; integrationTableMapping.Type)
                {
                }
                fieldattribute(IntegrationTableMapping_Status; integrationTableMapping.Status)
                {
                }
                fieldattribute(IntegrationTableMapping_OverwriteLocalChange; integrationTableMapping."Overwrite Local Change")
                {
                    FieldValidate = No;
                }
                fieldattribute(IntegrationTableMapping_ParentName; integrationTableMapping."Parent Name")
                {
                }
                fieldattribute(IntegrationTableMapping_DeleteAfterSynchronization; integrationTableMapping."Delete After Synchronization")
                {
                }
                fieldattribute(IntegrationTableMapping_DeletionConflictResolution; integrationTableMapping."Deletion-Conflict Resolution")
                {
                }
                fieldattribute(IntegrationTableMapping_UpdateConflictResolution; integrationTableMapping."Update-Conflict Resolution")
                {
                }
                fieldattribute(IntegrationTableMapping_UncoupleCodeunitID; integrationTableMapping."Uncouple Codeunit ID")
                {
                }
                fieldattribute(IntegrationTableMapping_CouplingCodeunitID; integrationTableMapping."Coupling Codeunit ID")
                {
                }
                fieldattribute(IntegrationTableMapping_SynchAfterBulkCoupling; integrationTableMapping."Synch. After Bulk Coupling")
                {
                }
                fieldattribute(IntegrationTableMapping_DependencyFilter; integrationTableMapping."Dependency Filter")
                {
                }
                fieldattribute(IntegrationTableMapping_CreateNewInCaseOfNoMatch; integrationTableMapping."Create New in Case of No Match")
                {
                }

                tableelement(integrationFieldMapping; "Integration Field Mapping")
                {
                    AutoSave = true;
                    AutoUpdate = true;
                    XmlName = 'IntegrationFieldMapping';
                    LinkTable = IntegrationTableMapping;
                    LinkFields = "Integration Table Mapping Name" = field(Name);
                    SourceTableView = sorting("No.");
                    fieldattribute(IntegrationFieldMapping_No; IntegrationFieldMapping."No.")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_IntegrationTableMappingName; IntegrationFieldMapping."Integration Table Mapping Name")
                    {
                        FieldValidate = No;
                    }
                    fieldattribute(IntegrationFieldMapping_FieldNo; IntegrationFieldMapping."Field No.")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_FieldCaption; IntegrationFieldMapping."Field Caption")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_IntegrationTableFieldNo; IntegrationFieldMapping."Integration Table Field No.")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_Direction; IntegrationFieldMapping.Direction)
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_ConstantValue; IntegrationFieldMapping."Constant Value")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_ValidateField; IntegrationFieldMapping."Validate Field")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_ValidateIntegrationTableFld; IntegrationFieldMapping."Validate Integration Table Fld")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_ClearValueOnFailedSync; IntegrationFieldMapping."Clear Value On Failed Sync")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_Status; IntegrationFieldMapping.Status)
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_NotNull; IntegrationFieldMapping."Not Null")
                    {
                        FieldValidate = No;
                    }
                    fieldattribute(IntegrationFieldMapping_TransformationRule; IntegrationFieldMapping."Transformation Rule")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_TransformationDirection; IntegrationFieldMapping."Transformation Direction")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_UseForMatchBasedCoupling; IntegrationFieldMapping."Use For Match-Based Coupling")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_CaseSensitiveMatching; IntegrationFieldMapping."Case-Sensitive Matching")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_MatchPriority; IntegrationFieldMapping."Match Priority")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_OverwriteLocalChange; IntegrationFieldMapping."Overwrite Local Change")
                    {
                    }
                }

                trigger OnBeforeInsertRecord()
                var
                    MasterDataMgtSetupDefault: Codeunit "Master Data Mgt. Setup Default";
                    TableFilterOutStr: OutStream;
                    IntegrationTableFilterOutStr: OutStream;
                begin
                    integrationTableMapping."Table Caption" := MasterDataMgtSetupDefault.GetTableCaption(integrationTableMapping."Table ID");
                    integrationTableMapping."Table Filter".CreateOutStream(TableFilterOutStr);
                    integrationTableMapping."Integration Table Filter".CreateOutStream(IntegrationTableFilterOutStr);
                    TableFilterOutStr.WriteText(tableFilterText);
                    IntegrationTableFilterOutStr.WriteText(integrationTableFilterText);
                end;

                trigger OnAfterInsertRecord()
                var
                    MasterDataManagementSetup: Record "Master Data Management Setup";
                    IntegrationFieldMapping: Record "Integration Field Mapping";
                    MasterDataMgtSetupDefault: Codeunit "Master Data Mgt. Setup Default";
                    EnqueueJobQueueEntries: Boolean;
                begin
                    IntegrationFieldMapping.SetRange("Integration Table Mapping Name", integrationTableMapping.Name);
                    if IntegrationFieldMapping.FindSet() then
                        repeat
                            IntegrationFieldMapping."Field Caption" := CopyStr(MasterDataMgtSetupDefault.GetFieldCaption(integrationTableMapping."Table ID", IntegrationFieldMapping."Field No."), 1, MaxStrLen(IntegrationFieldMapping."Field Caption"));
                            IntegrationFieldMapping.Modify();
                        until IntegrationFieldMapping.Next() = 0;

                    if MasterDataManagementSetup.Get() then
                        if (MasterDataManagementSetup."Is Enabled") and (not MasterDataManagementSetup."Delay Job Scheduling") then
                            EnqueueJobQueueEntries := true;

                    MasterDataMgtSetupDefault.RecreateJobQueueEntryFromIntTableMapping(integrationTableMapping, 1, EnqueueJobQueueEntries, 30);
                end;

                trigger OnBeforeModifyRecord()
                var
                    TableFilterOutStr: OutStream;
                    IntegrationTableFilterOutStr: OutStream;
                begin
                    integrationTableMapping."Table Filter".CreateOutStream(TableFilterOutStr);
                    integrationTableMapping."Integration Table Filter".CreateOutStream(IntegrationTableFilterOutStr);
                    TableFilterOutStr.WriteText(tableFilterText);
                    IntegrationTableFilterOutStr.WriteText(integrationTableFilterText);
                end;

            }
        }
    }
}

