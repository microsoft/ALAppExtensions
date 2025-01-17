namespace Microsoft.SubscriptionBilling;

table 8001 "Contract Renewal Line"
{
    Caption = 'Contract Renewal Line';
    DataClassification = CustomerContent;
    LookupPageId = "Contract Renewal Lines";
    DrillDownPageId = "Contract Renewal Lines";
    Access = Internal;

    fields
    {
        field(1; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            Editable = false;
            TableRelation = "Service Object";

            trigger OnValidate()
            begin
                RefreshContractInfo();
            end;
        }
        field(2; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
            Editable = false;
            TableRelation = "Service Commitment"."Entry No.";

            trigger OnValidate()
            begin
                RefreshContractInfo();
            end;
        }
        field(10; "Linked to Ser. Comm. Entry No."; Integer)
        {
            Caption = 'Linked to Service Commitment Entry No.';
            Editable = false;

        }
        field(11; "Linked to Contract No."; Code[20])
        {
            Caption = 'Linked to Contract No.';
            Editable = false;
            TableRelation = "Customer Contract";
        }
        field(12; "Linked to Contract Line No."; Integer)
        {
            Caption = 'Linked to Contract Line No.';
            Editable = false;
            TableRelation = "Customer Contract Line"."Line No." where("Contract No." = field("Linked to Contract No."));
        }
        field(13; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            Editable = false;
            TableRelation =
                if (Partner = const(Customer)) "Customer Contract" else
            if (Partner = const(Vendor)) "Vendor Contract";
        }
        field(14; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            Editable = false;
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
        }
        field(15; "Error Message"; Text[500])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(100; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment".Partner where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(101; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object".Description where("No." = field("Service Object No.")));
        }
        field(102; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment".Description where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(103; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment"."Service Start Date" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(104; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment"."Service End Date" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(105; "Price"; Decimal)
        {
            Caption = 'Price';
            BlankZero = true;
            AutoFormatType = 2;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment"."Price" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(106; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
            BlankZero = true;
            AutoFormatType = 1;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment"."Service Amount" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(107; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment"."Billing Rhythm" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(108; "Planned Serv. Comm. exists"; Boolean)
        {
            Caption = 'Planned Service Commitment exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Service Commitment" where("Entry No." = field("Service Commitment Entry No.")));
        }
        field(201; "Agreed Serv. Comm. Start Date"; Date)
        {
            Caption = 'Agreed Serv. Comm. Start Date';
        }
        field(202; "Renewal Term"; DateFormula)
        {
            Caption = 'Renewal Term';

            trigger OnValidate()
            var
                DateFormulaManagement: Codeunit "Date Formula Management";
            begin
                DateFormulaManagement.ErrorIfDateFormulaNegative("Renewal Term");
            end;
        }
    }

    keys
    {
        key(PK; "Service Commitment Entry No.")
        {
            Clustered = true;
        }
        key(PageSort; "Linked to Contract No.", "Linked to Contract Line No.") { }
    }

    local procedure RefreshContractInfo()
    var
        ServiceCommitment: Record "Service Commitment";
        ContractLineFound: Boolean;
    begin
        ContractLineFound := false;
        if Rec."Service Commitment Entry No." <> 0 then
            if ServiceCommitment.Get(Rec."Service Commitment Entry No.") then begin
                Rec."Contract No." := ServiceCommitment."Contract No.";
                Rec."Contract Line No." := ServiceCommitment."Contract Line No.";
                Rec."Linked to Contract No." := ServiceCommitment."Contract No.";
                Rec."Linked to Contract Line No." := ServiceCommitment."Contract Line No.";
                ContractLineFound := true;
            end;
        if not ContractLineFound then begin
            Rec."Contract No." := '';
            Rec."Contract Line No." := 0;
            Rec."Linked to Contract No." := '';
            Rec."Linked to Contract Line No." := 0;
        end;
        OnAfterRefreshContractInfo(Rec);
    end;

    procedure InitFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"): Boolean
    begin
        Clear(Rec);
        if ContractRenewalLineExists(ServiceCommitment) then
            exit(false);
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        if ServiceCommitment."Planned Serv. Comm. exists" then
            exit(false);
        Rec.Init();
        Rec."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        RefreshContractInfo();
        Rec.Validate("Renewal Term", ServiceCommitment."Renewal Term");
        if ServiceCommitment."Service End Date" <> 0D then
            Rec.Validate("Agreed Serv. Comm. Start Date", CalcDate('<+1D>', ServiceCommitment."Service End Date"));
        OnAfterInitFromServiceCommitment(Rec, ServiceCommitment);
        exit(true);
    end;

    procedure ContractRenewalLineExists(ServiceCommitment: Record "Service Commitment"): Boolean
    var
        ContractRenewalLine: Record "Contract Renewal Line";
    begin
        exit(ContractRenewalLine.Get(ServiceCommitment."Entry No."));
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInitFromServiceCommitment(var ContractRenewalLine: Record "Contract Renewal Line"; ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterRefreshContractInfo(var ContractRenewalLine: Record "Contract Renewal Line")
    begin
    end;
}