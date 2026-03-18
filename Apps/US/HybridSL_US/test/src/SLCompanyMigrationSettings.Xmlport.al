// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147652 "SL Company Migration Settings"
{
    Caption = 'Company Migration Settings data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Company Migration Settings"; "SL Company Migration Settings")
            {
                AutoSave = false;
                XmlName = 'SLCompanyMigrationSettings';

                textelement("Name")
                {
                }
                textelement("GlobalDimension1")
                {
                }
                textelement("GlobalDimension2")
                {
                }
                textelement("MigrateInactiveCustomers")
                {
                }
                textelement("MigrateInactiveVendors")
                {
                }
                textelement("ProcessesAreRunning")
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
                    SLCompanyMigrationSettings: Record "SL Company Migration Settings";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCompanyMigrationSettings.Name := Name;
                    SLCompanyMigrationSettings."Global Dimension 1" := GlobalDimension1;
                    SLCompanyMigrationSettings."Global Dimension 2" := GlobalDimension2;
                    Evaluate(SLCompanyMigrationSettings."Migrate Inactive Customers", MigrateInactiveCustomers);
                    Evaluate(SLCompanyMigrationSettings."Migrate Inactive Vendors", MigrateInactiveVendors);
                    Evaluate(SLCompanyMigrationSettings.ProcessesAreRunning, ProcessesAreRunning);
                    SLCompanyMigrationSettings.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCompanyMigrationSettings.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
}