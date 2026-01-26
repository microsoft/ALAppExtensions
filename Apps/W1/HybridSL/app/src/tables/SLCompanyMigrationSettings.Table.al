// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

table 47052 "SL Company Migration Settings"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; Name; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Hybrid Company".Name;
        }
        field(2; Replicate; Boolean)
        {
            CalcFormula = lookup("Hybrid Company".Replicate where(Name = field(Name)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Global Dimension 1"; Text[30])
        {
            Description = 'Global Dimension 1 for the company';
            TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = field(Name));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                SLSegmentNames: Record "SL Segment Name";
            begin
                SLSegmentNames.SetFilter("Company Name", Name);
                if (SLSegmentNames.Count() > 0) and ("Global Dimension 1" = '') then
                    Error(GlobalDimension1MustNotBeBlankErr);

                if ("Global Dimension 1" <> '') and ("Global Dimension 1" = "Global Dimension 2") then begin
                    SLSegmentNames.SetFilter("Segment Name", '<> %1', "Global Dimension 1");
                    if SLSegmentNames.FindFirst() then
                        "Global Dimension 2" := SLSegmentNames."Segment Name"
                    else
                        "Global Dimension 2" := '';
                end;
            end;
        }
        field(5; "Global Dimension 2"; Text[30])
        {
            Description = 'Global Dimension 2 for the company';
            TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = field(Name));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                SLSegmentNames: Record "SL Segment Name";
            begin
                if (SLSegmentNames.Count() > 1) and ("Global Dimension 2" = '') then
                    Error(GlobalDimension2MustNotBeBlankErr);

                if ("Global Dimension 1" <> '') and ("Global Dimension 1" = "Global Dimension 2") then
                    Error(GlobalDimensionsCannotBeTheSameErr);
            end;
        }
        field(7; "Migrate Inactive Customers"; Boolean)
        {
            InitValue = true;
        }
        field(8; "Migrate Inactive Vendors"; Boolean)
        {
            InitValue = true;
        }
        field(9; NumberOfSegments; Integer)
        {
            CalcFormula = count("SL Segment Name" where("Company Name" = field(Name)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; ProcessesAreRunning; Boolean)
        {
            InitValue = false;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    var
        GlobalDimension1MustNotBeBlankErr: Label 'Global Dimension 1 cannot be blank.';
        GlobalDimension2MustNotBeBlankErr: Label 'Global Dimension 2 cannot be blank.';
        GlobalDimensionsCannotBeTheSameErr: Label 'Global Dimension 1 and Global Dimension 2 cannot be the same.';
}