namespace Microsoft.DataMigration.GP.HistoricalData;

table 40912 "Hist. Migration Current Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Current Step"; enum "Hist. Migration Step Type")
        {
            Caption = 'Current Step';
            DataClassification = SystemMetadata;
        }
        field(3; "Log Count"; Integer)
        {
            CalcFormula = count("Hist. Migration Step Status");
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
            Rec."Current Step" := "Hist. Migration Step Type"::"Not Started";
            Rec.Insert();
        end;
    end;

    procedure GetCurrentStep(): enum "Hist. Migration Step Type"
    begin
        EnsureInit();
        exit(Rec."Current Step");
    end;

    procedure SetCurrentStep(Step: enum "Hist. Migration Step Type")
    begin
        EnsureInit();
        Rec."Current Step" := Step;
        Rec.Modify();
    end;
}