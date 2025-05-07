#pragma warning disable AA0247
table 8021 "Usage Data Billing Metadata"
{
    Access = Internal;
    Caption = 'Usage Data Billing Metadata';
    DataClassification = CustomerContent;
    DrillDownPageId = "Usage Data Billing Metadata";
    LookupPageId = "Usage Data Billing Metadata";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Usage Data Billing Entry No."; Integer)
        {
            Caption = 'Entry No.';
            TableRelation = "Usage Data Billing";
        }
        field(3; "Subscription No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(4; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
            TableRelation = "Subscription Line";
        }
        field(5; "Supplier Charge Start Date"; Date)
        {
            Caption = 'Supplier Charge Start Date';
        }
        field(6; "Supplier Charge End Date"; Date)
        {
            Caption = 'Supplier Charge End Date';
        }
        field(7; "Original Invoiced to Date"; Date)
        {
            Caption = 'Original Invoiced to Date';
        }
        field(8; Invoiced; Boolean)
        {
            Caption = 'Invoiced';
        }
        field(9; Rebilling; Boolean)
        {
            Caption = 'Rebilling';
        }
        field(10; "Billing Document Type"; Enum "Usage Based Billing Doc. Type")
        {
            Caption = 'Billing Document Type';
            FieldClass = FlowField;
            CalcFormula = lookup("Usage Data Billing"."Document Type" where("Entry No." = field("Usage Data Billing Entry No.")));
            Editable = false;
        }
        field(11; "Billing Document No."; Code[20])
        {
            Caption = 'Billing Document No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Usage Data Billing"."Document No." where("Entry No." = field("Usage Data Billing Entry No.")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure InsertFromUsageDataBilling(UsageDataBilling: Record "Usage Data Billing")
    var
        ServiceCommitment: Record "Subscription Line";
        NewOriginalInvoicedToDate: Date;
        NextBillingDate: Date;
    begin
        "Entry No." := 0;
        "Usage Data Billing Entry No." := UsageDataBilling."Entry No.";
        "Subscription No." := UsageDataBilling."Subscription Header No.";
        "Subscription Line Entry No." := UsageDataBilling."Subscription Line Entry No.";
        "Supplier Charge Start Date" := UsageDataBilling."Charge Start Date";
        "Supplier Charge End Date" := UsageDataBilling."Charge End Date";
        Rebilling := UsageDataBilling.Rebilling;

        if ("Subscription No." <> '') and ("Subscription Line Entry No." <> 0) then begin
            ServiceCommitment.Get("Subscription Line Entry No.");
            NewOriginalInvoicedToDate := ServiceCommitment.GetLastSupplierChargeEndDateIfMetadataExist();
            if NewOriginalInvoicedToDate = 0D then
                NewOriginalInvoicedToDate := ServiceCommitment."Subscription Line Start Date" - 1;
            "Original Invoiced to Date" := NewOriginalInvoicedToDate;

            NextBillingDate := ServiceCommitment.GetSupplierChargeStartDateIfRebillingMetadataExist(0D);
            if NextBillingDate <> 0D then begin
                ServiceCommitment."Next Billing Date" := NextBillingDate;
                ServiceCommitment.Modify(false);
            end;
        end;
        Insert(true);
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitmentEntryNo: Integer)
    begin
        Rec.SetRange("Subscription Line Entry No.", ServiceCommitmentEntryNo);
    end;
}
