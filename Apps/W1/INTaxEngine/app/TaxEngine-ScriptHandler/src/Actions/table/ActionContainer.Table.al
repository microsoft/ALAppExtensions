table 20159 "Action Container"
{
    Caption = 'Action Container';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(2; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(3; "Container Type"; Enum "Container Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Container Type';
        }
        field(4; "Container Action ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Container Action ID';
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
        }
        field(6; "Action Type"; Enum "Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Action Type';
        }
        field(7; "Action ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Action ID';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Container Type", "Container Action ID", "Line No.")
        {
            Clustered = True;
        }
        key(K1; "Action Type", "Action ID")
        {
        }
    }

    trigger OnDelete();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        ScriptEntityMgmt.DeleteContainerItem("Case ID", "Script ID", "Action Type", "Action ID");
    end;

    trigger OnInsert();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        InvalidContainerTypeErr: Label 'Invalid Container: %1', Comment = '%1 = Container Type';
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        case "Container Type" of
            "Container Action Type"::USECASE,
            "Container Action Type"::IFSTATEMENT,
            "Container Action Type"::LOOPNTIMES,
            "Container Action Type"::LOOPWITHCONDITION,
            "Container Action Type"::LOOPTHROUGHRECORDS:
                ;
            else
                Error(InvalidContainerTypeErr, "Container Type");
        end;
    end;

    var
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
}