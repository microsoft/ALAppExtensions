// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47062 "SL Migration Warnings"
{
    Access = Internal;
    Caption = 'SL Migration Warnings';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(3; "Migration Area"; Text[50])
        {
            Caption = 'Migration Area';
        }
        field(4; Context; Text[50])
        {
            Caption = 'Context';
        }
        field(5; "Warning Text"; Text[500])
        {
            Caption = 'Warning Text';
        }
    }
    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    internal procedure InsertWarning(MigrationArea: Text[50]; ContextValue: Text[50]; WarningText: Text[500])
    var
        SLMigrationWarnings: Record "SL Migration Warnings";
    begin
        SLMigrationWarnings."Company Name" := CopyStr(CompanyName(), 1, 30);
        SLMigrationWarnings."Migration Area" := MigrationArea;
        SLMigrationWarnings.Context := ContextValue;
        SLMigrationWarnings."Warning Text" := WarningText;
        SLMigrationWarnings.Insert();
    end;
}
