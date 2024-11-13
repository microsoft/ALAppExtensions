// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47017 "SL Migration Config"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
        }
        field(2; "Zip File"; Text[250])
        {
        }
        field(3; "Unziped Folder"; Text[250])
        {
        }
        field(4; "Total Items"; Integer)
        {
        }
        field(5; "Total Accounts"; Integer)
        {
        }
        field(6; "Total Customers"; Integer)
        {
        }
        field(7; "Total Vendors"; Integer)
        {
        }
        field(8; "Chart of Account Option"; Option)
        {
            OptionMembers = " ",Existing,New;
        }
        field(9; "Updated GL Setup"; Boolean)
        {
            InitValue = false;
        }
        field(10; "GL Transactions Processed"; Boolean)
        {
            InitValue = false;
        }
        field(11; "Account Validation Error"; Boolean)
        {
        }
        field(12; "Post Transactions"; Boolean)
        {
            InitValue = false;
        }
        field(14; "Finish Event Processed"; Boolean)
        {
            InitValue = false;
        }
        field(15; "Last Error Message"; Text[250])
        {
        }
        field(16; "PreMigration Cleanup Completed"; Boolean)
        {
            InitValue = false;
        }
        field(17; "Dimensions Created"; Boolean)
        {
            InitValue = false;
        }
        field(18; "Payment Terms Created"; Boolean)
        {
            InitValue = false;
        }
        field(19; "Item Tracking Codes Created"; Boolean)
        {
            InitValue = false;
        }
        field(20; "Locations Created"; Boolean)
        {
            InitValue = false;
        }
        field(21; "Historical Job Ran"; Boolean)
        {
            InitValue = false;
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }

    internal procedure GetSingleInstance();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    internal procedure SetAccountValidationError();
    var
        MigrationSLConfig: Record "SL Migration Config";
    begin
        MigrationSLConfig.GetSingleInstance();
        MigrationSLConfig."Account Validation Error" := true;
        MigrationSLConfig.Modify();
    end;

    internal procedure ClearAccountValidationError();
    var
        MigrationSLConfig: Record "SL Migration Config";
    begin
        MigrationSLConfig.GetSingleInstance();
        MigrationSLConfig."Account Validation Error" := false;
        MigrationSLConfig.Modify();
    end;

    internal procedure GetAccountValidationError(): Boolean;
    var
        MigrationSLConfig: Record "SL Migration Config";
    begin
        MigrationSLConfig.GetSingleInstance();
        exit(MigrationSLConfig."Account Validation Error");
    end;

    internal procedure HasHistoricalJobRan(): Boolean
    begin
        exit(Rec."Historical Job Ran");
    end;
}