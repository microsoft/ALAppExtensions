namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

table 8016 "Usage Data Supp. Subscription"
{
    Caption = 'Usage Data Supplier Subscription';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Subscriptions";
    DrillDownPageId = "Usage Data Subscriptions";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            TableRelation = "Usage Data Supplier";
        }
        field(3; "Supplier Description"; Text[80])
        {
            Caption = 'Supplier Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Usage Data Supplier".Description where("No." = field("Supplier No.")));
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(5; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(6; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            Editable = false;
        }
        field(7; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
            TableRelation = "Subscription Line";
            ValidateTableRelation = false;
            Editable = false;
            trigger OnValidate()
            var
                ServiceCommitment: Record "Subscription Line";
            begin
                if ((Rec."Subscription Line Entry No." <> 0) and (Rec."Subscription Header No." <> '')) then begin
                    ServiceCommitment.Get(Rec."Subscription Line Entry No.");
                    ServiceCommitment.TestField("Supplier Reference Entry No.", Rec."Supplier Reference Entry No.");
                end else
                    Clear("Subscription Header No.");

                Clear("Connect to Sub. Header No.");
                Clear("Connect to Sub. Header at Date");
                Clear("Connect to Sub. Header Method");
            end;

        }
        field(8; "Product Name"; Text[100])
        {
            Caption = 'Product Name';
        }
        field(9; Status; Enum "Usage Data Subscription Status")
        {
            Caption = 'Status';
        }
        field(10; "Billing Cycle"; Enum "Billing Cycle")
        {
            Caption = 'Billing Cycle';
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(12; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(13; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(14; "Supplier Reference Entry No."; Integer)
        {
            Caption = 'Supplier Reference Entry No.';
            TableRelation = "Usage Data Supplier Reference";

            trigger OnValidate()
            var
                UsageDataSupplierReference: Record "Usage Data Supplier Reference";
            begin
                if "Supplier Reference Entry No." = 0 then
                    exit;
                UsageDataSupplierReference.Get("Supplier Reference Entry No.");
                "Supplier Reference" := UsageDataSupplierReference."Supplier Reference";
            end;
        }
        field(15; "Supplier Reference"; Text[80])
        {
            Caption = 'Supplier Reference';
            Editable = false;
        }
        field(16; "Customer ID"; Text[80])
        {
            Caption = 'Customer ID';
        }
        field(17; "Customer Description"; Text[100])
        {
            Caption = 'Customer Description';
        }
        field(18; "Product ID"; Text[80])
        {
            Caption = 'Product ID';
        }
        field(19; "Processing Status"; Enum "Processing Status")
        {
            Caption = 'Processing Status';
            Editable = false;
        }
        field(20; "Unit Type"; Text[80])
        {
            Caption = 'Unit Type';
        }
        field(21; "Connect to Sub. Header No."; Code[20])
        {
            Caption = 'Connect to Subscription No.';
            TableRelation = "Subscription Header" where("End-User Customer No." = field("Customer No."),
                                                    "Provision End Date" = filter(0D));
            trigger OnValidate()
            var
                ServiceCommitment: Record "Subscription Line";
                InvoicedToDate: Date;
            begin
                if "Connect to Sub. Header No." = '' then
                    ResetConnectToFields()
                else begin
                    SetInvoicedToDateFromServiceCommitment(ServiceCommitment, InvoicedToDate);
                    SetConnectToValues(ServiceCommitment, InvoicedToDate);
                end;
            end;
        }
        field(22; "Connect to Sub. Header Method"; Enum "Connect To SO Method")
        {
            Caption = 'Connect to Subscription Method';
            trigger OnValidate()
            begin
                TestField("Connect to Sub. Header No.");
                if not ("Connect to Sub. Header Method" = "Connect to Sub. Header Method"::"Existing Service Commitments") then
                    exit;
                ErrorIfServiceCommitmentsDoesNotExist("Connect to Sub. Header No.");
                "Connect to Sub. Header at Date" := 0D;
            end;
        }
        field(23; "Connect to Sub. Header at Date"; Date)
        {
            Caption = 'Connect to Subscription at Date';

            trigger OnValidate()
            begin
                if "Connect to Sub. Header at Date" <> 0D then
                    TestField("Connect to Sub. Header Method", "Connect to Sub. Header Method"::"New Service Commitments");
            end;
        }
        field(24; "Reason (Preview)"; Text[80])
        {
            Caption = 'Reason (Preview)';
            Editable = false;

            trigger OnLookup()
            begin
                ShowReason();
            end;
        }
        field(25; Reason; Blob)
        {
            Caption = 'Reason';
            Compressed = false;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Supplier No.", "Product Name", "Supplier Reference", "Start Date", Quantity)
        {
        }
    }

    var
        SubscriptionCannotBeConnectedErr: Label 'The Subscription cannot be linked via "Existing Subscription Lines" because the Subscription Lines are not charged based on usage. Instead, select Link via=New Subscription Lines.';

    local procedure ResetConnectToFields()
    begin
        "Connect to Sub. Header at Date" := 0D;
        "Connect to Sub. Header Method" := "Connect to Sub. Header Method"::None;
    end;

    local procedure SetInvoicedToDateFromServiceCommitment(var ServiceCommitment: Record "Subscription Line"; var InvoicedToDate: Date)
    begin
        ServiceCommitment.SetRange("Subscription Header No.", "Connect to Sub. Header No.");
        ServiceCommitment.SetFilter("Subscription Contract No.", '<>%1', '');
        if ServiceCommitment.FindSet() then
            repeat
                if CalcDate('<-1D>', ServiceCommitment."Next Billing Date") > InvoicedToDate then
                    InvoicedToDate := CalcDate('<-1D>', ServiceCommitment."Next Billing Date");
            until ServiceCommitment.Next() = 0;
    end;

    local procedure SetConnectToValues(var ServiceCommitment: Record "Subscription Line"; InvoicedToDate: Date)
    begin
        ServiceCommitment.SetRange("Subscription Contract No.");
        ServiceCommitment.SetRange("Usage Based Billing", true);

        if not ServiceCommitment.IsEmpty then
            "Connect to Sub. Header Method" := "Connect to Sub. Header Method"::"Existing Service Commitments"
        else begin
            "Connect to Sub. Header Method" := "Connect to Sub. Header Method"::"New Service Commitments";
            if InvoicedToDate <> 0D then
                "Connect to Sub. Header at Date" := InvoicedToDate + 1;
        end;
    end;

    local procedure ErrorIfServiceCommitmentsDoesNotExist(ConnecttoServiceObjectNo: Code[20])
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ConnecttoServiceObjectNo);
        ServiceCommitment.SetFilter("Subscription Contract No.", '<>%1', '');
        ServiceCommitment.SetRange("Usage Based Billing", true);
        if ServiceCommitment.IsEmpty then
            Error(SubscriptionCannotBeConnectedErr);
    end;

    internal procedure SetErrorReason(ErrorText: Text)
    begin
        Rec.Validate("Processing Status", Enum::"Processing Status"::Error);
        Rec.SetReason(ErrorText);
    end;

    internal procedure ShowReason()
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        CalcFields(Reason);
        RRef.GetTable(Rec);
        TextManagement.ShowFieldText(RRef, FieldNo(Reason));
    end;

    internal procedure SetReason(ReasonText: Text)
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        if ReasonText = '' then begin
            Clear("Reason (Preview)");
            Clear(Reason);
        end else begin
            "Reason (Preview)" := CopyStr(ReasonText, 1, MaxStrLen("Reason (Preview)"));
            RRef.GetTable(Rec);
            TextManagement.WriteBlobText(RRef, FieldNo(Reason), ReasonText);
            RRef.SetTable(Rec);
        end;
    end;

    internal procedure ResetProcessingStatus(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    begin
        if UsageDataSubscription.FindSet(true) then
            repeat
                UsageDataSubscription.Validate("Processing Status", UsageDataSubscription."Processing Status"::None);
                UsageDataSubscription.Modify(true);
            until UsageDataSubscription.Next() = 0;
    end;

    internal procedure ResetServiceObjectAndServiceCommitment()
    begin
        if Rec."Entry No." = 0 then
            exit;
        Rec.Validate("Subscription Header No.", '');
        Rec.Validate("Subscription Line Entry No.", 0);
        Rec.Modify(true);
    end;

    internal procedure FindForSupplierReference(SupplierNo: Code[20]; SupplierReference: Text[80]): Boolean
    begin
        Rec.SetRange("Supplier No.", SupplierNo);
        Rec.SetRange("Supplier Reference", SupplierReference);
        exit(Rec.FindFirst());
    end;

    internal procedure UpdateServiceObjectNoForUsageDataGenericImport()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        UsageDataGenericImport.SetFilter("Processing Status", '<>%1', "Processing Status"::Ok);
        UsageDataGenericImport.SetRange("Supp. Subscription ID", Rec."Supplier Reference");
        UsageDataGenericImport.ModifyAll("Subscription Header No.", Rec."Subscription Header No.");
        UsageDataGenericImport.ModifyAll("Service Object Availability", UsageDataGenericImport."Service Object Availability"::Connected);
    end;
}
