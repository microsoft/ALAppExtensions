namespace Microsoft.SubscriptionBilling;

table 8001 "Sub. Contract Renewal Line"
{
    Caption = 'Subscription Contract Renewal Line';
    DataClassification = CustomerContent;
    LookupPageId = "Contract Renewal Lines";
    DrillDownPageId = "Contract Renewal Lines";

    fields
    {
        field(1; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            Editable = false;
            TableRelation = "Subscription Header";

            trigger OnValidate()
            begin
                RefreshContractInfo();
            end;
        }
        field(2; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
            Editable = false;
            TableRelation = "Subscription Line"."Entry No.";

            trigger OnValidate()
            begin
                RefreshContractInfo();
            end;
        }
        field(10; "Linked to Sub. Line Entry No."; Integer)
        {
            Caption = 'Linked to Subscription Line Entry No.';
            Editable = false;

        }
        field(11; "Linked to Sub. Contract No."; Code[20])
        {
            Caption = 'Linked to Subscription Contract No.';
            Editable = false;
            TableRelation = "Customer Subscription Contract";
        }
        field(12; "Linked to Sub. Contr. Line No."; Integer)
        {
            Caption = 'Linked to Subscription Contr. Line No.';
            Editable = false;
            TableRelation = "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Linked to Sub. Contract No."));
        }
        field(13; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            Editable = false;
            TableRelation =
                if (Partner = const(Customer)) "Customer Subscription Contract" else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(14; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            Editable = false;
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
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
            CalcFormula = lookup("Subscription Line".Partner where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(101; "Subscription t Description"; Text[100])
        {
            Caption = 'Subscription  Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Description where("No." = field("Subscription Header No.")));
        }
        field(102; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line".Description where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(103; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line"."Subscription Line Start Date" where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(104; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line"."Subscription Line End Date" where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(105; "Price"; Decimal)
        {
            Caption = 'Price';
            BlankZero = true;
            AutoFormatType = 2;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line"."Price" where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(106; Amount; Decimal)
        {
            Caption = 'Amount';
            BlankZero = true;
            AutoFormatType = 1;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line".Amount where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(107; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Line"."Billing Rhythm" where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(108; "Planned Sub. Line exists"; Boolean)
        {
            Caption = 'Planned Subscription Line exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Subscription Line" where("Entry No." = field("Subscription Line Entry No.")));
        }
        field(201; "Agreed Sub. Line Start Date"; Date)
        {
            Caption = 'Agreed Subscription Line Start Date';
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
        key(PK; "Subscription Line Entry No.")
        {
            Clustered = true;
        }
        key(PageSort; "Linked to Sub. Contract No.", "Linked to Sub. Contr. Line No.") { }
    }

    local procedure RefreshContractInfo()
    var
        ServiceCommitment: Record "Subscription Line";
        ContractLineFound: Boolean;
    begin
        ContractLineFound := false;
        if Rec."Subscription Line Entry No." <> 0 then
            if ServiceCommitment.Get(Rec."Subscription Line Entry No.") then begin
                Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
                Rec."Subscription Contract Line No." := ServiceCommitment."Subscription Contract Line No.";
                Rec."Linked to Sub. Contract No." := ServiceCommitment."Subscription Contract No.";
                Rec."Linked to Sub. Contr. Line No." := ServiceCommitment."Subscription Contract Line No.";
                ContractLineFound := true;
            end;
        if not ContractLineFound then begin
            Rec."Subscription Contract No." := '';
            Rec."Subscription Contract Line No." := 0;
            Rec."Linked to Sub. Contract No." := '';
            Rec."Linked to Sub. Contr. Line No." := 0;
        end;
        OnAfterRefreshContractInfo(Rec, ServiceCommitment);
    end;

    internal procedure InitFromServiceCommitment(var ServiceCommitment: Record "Subscription Line"): Boolean
    begin
        Clear(Rec);
        if ContractRenewalLineExists(ServiceCommitment) then
            exit(false);
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        if ServiceCommitment."Planned Sub. Line exists" then
            exit(false);
        Rec.Init();
        Rec."Subscription Line Entry No." := ServiceCommitment."Entry No.";
        Rec."Subscription Header No." := ServiceCommitment."Subscription Header No.";
        RefreshContractInfo();
        Rec.Validate("Renewal Term", ServiceCommitment."Renewal Term");
        if ServiceCommitment."Subscription Line End Date" <> 0D then
            Rec.Validate("Agreed Sub. Line Start Date", CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date"));
        OnAfterInitFromSubscriptionLine(Rec, ServiceCommitment);
        exit(true);
    end;

    local procedure ContractRenewalLineExists(ServiceCommitment: Record "Subscription Line"): Boolean
    var
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
    begin
        exit(ContractRenewalLine.Get(ServiceCommitment."Entry No."));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromSubscriptionLine(var SubContractRenewalLine: Record "Sub. Contract Renewal Line"; SubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRefreshContractInfo(var SubContractRenewalLine: Record "Sub. Contract Renewal Line"; SubscriptionLine: Record "Subscription Line")
    begin
    end;
}