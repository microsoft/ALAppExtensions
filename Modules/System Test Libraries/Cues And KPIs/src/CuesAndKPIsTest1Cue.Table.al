// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Visualization;

table 135039 "Cues And KPIs Test 1 Cue"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(10; NormalInteger; Integer)
        {
        }
        field(15; NormalDecimal; Decimal)
        {
        }
#pragma warning disable AA0232
        field(20; FlowfieldInteger; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Cues And KPIs Test 1 Cue".NormalInteger);
            Editable = false;
        }
        field(25; FlowfieldDecimal; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Cues And KPIs Test 1 Cue".NormalDecimal);
            Editable = false;
        }
#pragma warning restore AA0232
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
            SumIndexFields = NormalInteger, NormalDecimal;
        }
    }
}
