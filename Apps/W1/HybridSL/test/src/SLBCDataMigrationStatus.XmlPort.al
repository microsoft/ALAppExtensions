// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using System.Integration;

xmlport 147605 "SL BC Data Migration Status"
{
    Caption = 'Data Migration Status data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Data Migration Status"; "Data Migration Status")
            {
                AutoSave = false;
                XmlName = 'DataMigrationStatus';

                textelement("MigrationType")
                {
                }
                textelement("DestinationTableID")
                {
                }
                textelement("TotalNumber")
                {
                }
                textelement("MigratedNumber")
                {
                }
                textelement("ProgressPercent")
                {
                }
                textelement("Status")
                {
                }
                textelement("SourceStagingTableID")
                {
                }
                textelement("MigrationCodeunitToRun")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    DataMigrationStatus: Record "Data Migration Status";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    DataMigrationStatus."Migration Type" := MigrationType;
                    Evaluate(DataMigrationStatus."Destination Table ID", DestinationTableID);
                    Evaluate(DataMigrationStatus."Total Number", TotalNumber);
                    Evaluate(DataMigrationStatus."Migrated Number", MigratedNumber);
                    Evaluate(DataMigrationStatus."Progress Percent", ProgressPercent);
                    Evaluate(DataMigrationStatus.Status, Status);
                    Evaluate(DataMigrationStatus."Source Staging Table ID", SourceStagingTableID);
                    Evaluate(DataMigrationStatus."Migration Codeunit To Run", MigrationCodeunitToRun);
                    DataMigrationStatus.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        DataMigrationStatus.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        DataMigrationStatus: Record "Data Migration Status";
}
