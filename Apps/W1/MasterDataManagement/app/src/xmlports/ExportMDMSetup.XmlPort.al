namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;

xmlport 7230 ExportMDMSetup
{
    Caption = 'Export Master Data Management Setup';
    Direction = Export;
    Format = Xml;
    UseRequestPage = false;
    Permissions = tabledata "Integration Field Mapping" = r,
                  tabledata "Integration Table Mapping" = r;

    schema
    {
        textelement(root)
        {
            XmlName = 'Root';
            tableelement(integrationTableMapping; "Integration Table Mapping")
            {
                AutoSave = false;
                AutoUpdate = false;
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
                    AutoSave = false;
                    AutoUpdate = false;
                    XmlName = 'IntegrationFieldMapping';
                    LinkTable = IntegrationTableMapping;
                    LinkFields = "Integration Table Mapping Name" = field(Name);
                    SourceTableView = sorting("No.");
                    fieldattribute(IntegrationFieldMapping_No; IntegrationFieldMapping."No.")
                    {
                    }
                    fieldattribute(IntegrationFieldMapping_IntegrationTableMappingName; IntegrationFieldMapping."Integration Table Mapping Name")
                    {
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

                trigger OnAfterGetRecord()
                var
                    TableFilterInStr: InStream;
                    IntegrationTableFilterInStr: InStream;
                begin
                    integrationTableMapping.CalcFields("Table Filter", "Integration Table Filter");
                    integrationTableMapping."Table Filter".CreateInStream(TableFilterInStr);
                    integrationTableMapping."Table Filter".CreateInStream(IntegrationTableFilterInStr);
                    TableFilterInStr.ReadText(tableFilterText);
                    IntegrationTableFilterInStr.ReadText(integrationTableFilterText);
                end;
            }
        }
    }
}

