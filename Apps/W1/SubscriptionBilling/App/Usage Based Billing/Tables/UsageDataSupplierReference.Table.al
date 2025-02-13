namespace Microsoft.SubscriptionBilling;

table 8015 "Usage Data Supplier Reference"
{
    Caption = 'Usage Data Supplier Reference';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Supp. References";
    DrillDownPageId = "Usage Data Supp. References";
    Access = Internal;

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
        field(4; "Type"; Enum "Usage Data Reference Type")
        {
            Caption = 'Type';
        }
        field(5; "Supplier Reference"; Text[80])
        {
            Caption = 'Supplier Reference';

            trigger OnValidate()
            begin
                "Supplier Reference" := LowerCase("Supplier Reference");
            end;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Supplier No.", "Supplier Reference", Type)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Supplier No.", "Supplier Description", "Supplier Reference", Type)
        {
        }
    }
    internal procedure CreateSupplierReference(SupplierNo: Code[20]; SupplierReference: Text[80]; ReferenceType: Enum "Usage Data Reference Type")
    begin
        if Rec.FindSupplierReference(SupplierNo, SupplierReference, ReferenceType) then begin
            Rec.Reset();
            exit;
        end;

        Rec."Entry No." := 0;
        Rec."Supplier No." := SupplierNo;
        Rec.Validate("Supplier Reference", SupplierReference);
        Rec.Type := ReferenceType;
        Rec.Insert(false);
        Rec.Reset();
    end;

    internal procedure FindSupplierReference(SupplierNo: Code[20]; SupplierReference: Text[80]; ReferenceType: Enum "Usage Data Reference Type"): Boolean
    begin
        Rec.FilterUsageDataSupplierReference(SupplierNo, SupplierReference, ReferenceType);
        exit(Rec.FindFirst());
    end;

    internal procedure DeleteSupplierReference(SupplierNo: Code[20]; SupplierReference: Text[80]; ReferenceType: Enum "Usage Data Reference Type")
    begin
        Rec.FilterUsageDataSupplierReference(SupplierNo, SupplierReference, ReferenceType);
        Rec.DeleteAll(true);
        Rec.Reset();
    end;

    internal procedure FilterUsageDataSupplierReference(SupplierNo: Code[20]; SupplierReference: Text[80]; ReferenceType: Enum "Usage Data Reference Type")
    begin
        Rec.SetCurrentKey("Supplier No.", "Supplier Reference", Type);
        Rec.SetRange("Supplier No.", SupplierNo);
        Rec.SetRange("Supplier Reference", LowerCase(SupplierReference));
        Rec.SetRange(Type, ReferenceType);
    end;
}
