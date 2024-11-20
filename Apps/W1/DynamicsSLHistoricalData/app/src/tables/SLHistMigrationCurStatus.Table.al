// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42821 "SL Hist. Migration Cur. Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Current Step"; enum "SL Hist. Migration Step Type")
        {
            Caption = 'Current Step';
            DataClassification = SystemMetadata;
        }
        field(3; "Log Count"; Integer)
        {
            CalcFormula = count("SL Hist. Migration Step Status");
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Reset Data"; Boolean)
        {
            Caption = 'Reset Data';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure EnsureInit()
    begin
        if not Rec.Get() then begin
            Rec."Current Step" := "SL Hist. Migration Step Type"::"Not Started";
            Rec.Insert();
        end;
    end;

    procedure GetCurrentStep(): enum "SL Hist. Migration Step Type"
    begin
        EnsureInit();
        exit(Rec."Current Step");
    end;

    procedure SetCurrentStep(Step: enum "SL Hist. Migration Step Type")
    begin
        EnsureInit();
        Rec."Current Step" := Step;
        Rec.Modify();
    end;
}