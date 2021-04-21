table 4020 "Hybrid BC Last Setup"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }

        field(2; "Handler Codeunit"; Integer)
        {
            DataClassification = SystemMetadata;
            InitValue = 4026;
        }
    }

    keys
    {
        key("Primary Key"; "Primary Key")
        {
        }
    }

    procedure CanHandleCodeunit(CodeunitID: Integer): Boolean
    var
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
    begin
        if not HybridBCLastSetup.Get() then begin
            HybridBCLastSetup.Init();
            HybridBCLastSetup.Insert();
        end;

        exit(HybridBCLastSetup."Handler Codeunit" = CodeunitID);
    end;

    procedure SetHandlerCodeunit(CodeunitID: Integer)
    var
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
    begin
        if HybridBCLastSetup.Get() then begin
            HybridBCLastSetup."Handler Codeunit" := CodeunitID;
            HybridBCLastSetup.Modify();
        end else begin
            HybridBCLastSetup.Init();
            HybridBCLastSetup."Handler Codeunit" := CodeunitID;
            HybridBCLastSetup.Insert();
        end;
    end;
}