table 4044 "GP Company Migration Settings"
{
    ReplicateData = false;
    DataPerCompany = false;
    Extensible = false;

    fields
    {
        field(1; Name; Text[30])
        {
            TableRelation = "Hybrid Company".Name;
            DataClassification = OrganizationIdentifiableInformation;
        }

        field(2; Replicate; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Hybrid Company".Replicate where(Name = field(Name)));
        }

        field(4; "Global Dimension 1"; Text[30])
        {
            Description = 'Global Dimension 1 for the company';
            TableRelation = "GP Segment Name" where("Company Name" = field("Name"));
            ValidateTableRelation = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPSegmentNames: Record "GP Segment Name";
            begin
                GPSegmentNames.SetFilter("Company Name", Name);
                if (GPSegmentNames.Count() > 0) and ("Global Dimension 1" = '') then
                    Error(GlobalDimension1MustNotBeBlankErr);

                if ("Global Dimension 1" <> '') and ("Global Dimension 1" = "Global Dimension 2") then begin
                    GPSegmentNames.SetFilter("Segment Name", '<> %1', "Global Dimension 1");
                    if GPSegmentNames.FindFirst() then
                        "Global Dimension 2" := GPSegmentNames."Segment Name"
                    else
                        "Global Dimension 2" := '';
                end;
            end;
        }

        field(5; "Global Dimension 2"; Text[30])
        {
            Description = 'Global Dimension 2 for the company';
            TableRelation = "GP Segment Name" where("Company Name" = field("Name"));
            ValidateTableRelation = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPSegmentNames: Record "GP Segment Name";
            begin
                if (GPSegmentNames.Count() > 1) and ("Global Dimension 2" = '') then
                    Error(GlobalDimension2MustNotBeBlankErr);

                if ("Global Dimension 1" <> '') and ("Global Dimension 1" = "Global Dimension 2") then
                    Error(GlobalDimensionsCannotBeTheSameErr);
            end;
        }

        field(7; "Migrate Inactive Customers"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;
        }

        field(8; "Migrate Inactive Vendors"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;
        }

        field(9; NumberOfSegments; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("GP Segment Name" where("Company Name" = field("Name")));
        }
        field(10; ProcessesAreRunning; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    var
        GlobalDimension1MustNotBeBlankErr: Label 'Global Dimension 1 cannot be blank.';
        GlobalDimension2MustNotBeBlankErr: Label 'Global Dimension 2 cannot be blank.';
        GlobalDimensionsCannotBeTheSameErr: Label 'Global Dimension 1 and Global Dimension 2 cannot be the same.';
}