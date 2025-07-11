#pragma warning disable AA0247
tableextension 14112 PackageNoInformationExt extends "Package No. Information"
{
    fields
    {
        field(14100; "CD Header Number"; Code[30])
        {
            Caption = 'CD Header Number';
            TableRelation = "CD Number Header";
        }
        field(14101; "Temporary CD Number"; Boolean)
        {
            Caption = 'Temporary CD Number';
        }
        field(14110; "Positive Adjmt. (Qty)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Package No." = FIELD("Package No."),
                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Entry Type" = CONST("Positive Adjmt.")));
            Caption = 'Positive Adjmt. (Qty)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14111; "Purchases (Qty)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Package No." = FIELD("Package No."),
                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Entry Type" = CONST(Purchase)));
            Caption = 'Purchases (Qty)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14112; "Negative Adjmt. (Qty)"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"),
                                                                   "Package No." = FIELD("Package No."),
                                                                   "Location Code" = FIELD("Location Filter"),
                                                                   "Entry Type" = CONST("Negative Adjmt.")));
            Caption = 'Negative Adjmt. (Qty)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14113; "Sales (Qty)"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"),
                                                                   "Package No." = FIELD("Package No."),
                                                                   "Location Code" = FIELD("Location Filter"),
                                                                   "Entry Type" = CONST(Sale)));
            Caption = 'Sales (Qty)';
            Editable = false;
            FieldClass = FlowField;
        }
        modify("Package No.")
        {
            trigger OnAfterValidate()
            var
                InventorySetup: Record "Inventory Setup";
                CDNumberFormat: Record "CD Number Format";
            begin
                InventorySetup.Get();
                if InventorySetup."Check CD Number Format" then
                    "Temporary CD Number" := not CDNumberFormat.Check("Package No.", false);
            end;
        }
    }

    keys
    {
        key(Key14100; "CD Header Number")
        {
        }
    }
}
