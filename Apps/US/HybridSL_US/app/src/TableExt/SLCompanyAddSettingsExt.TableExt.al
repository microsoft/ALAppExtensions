// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;


tableextension 47200 "SL Company Add. Settings Ext." extends "SL Company Additional Settings"
{
    fields
    {
        field(57200; "Migrate Current 1099 Year"; Boolean)
        {
            Caption = 'Migrate Current 1099 Year';
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Current 1099 Year" then begin
                    Rec.Validate("Migrate Payables Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }
        field(57201; "Migrate Next 1099 Year"; Boolean)
        {
            Caption = 'Migrate Next 1099 Year';
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Next 1099 Year" then begin
                    Rec.Validate("Migrate Payables Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }

        modify("Migrate Payables Module")
        {
            trigger OnAfterValidate()
            begin
                if not Rec."Migrate Payables Module" then begin
                    Rec."Migrate Current 1099 Year" := false;
                    Rec."Migrate Next 1099 Year" := false;
                end;
            end;
        }
        modify("Migrate GL Module")
        {
            trigger OnAfterValidate()
            begin
                if not Rec."Migrate GL Module" then begin
                    Rec."Migrate Current 1099 Year" := false;
                    Rec."Migrate Next 1099 Year" := false;
                end;
            end;
        }
    }

    procedure GetMigrateCurrent1099YearEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Current 1099 Year");
    end;

    procedure GetMigrateNext1099YearEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Next 1099 Year");
    end;
}