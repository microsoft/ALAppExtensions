#pragma warning disable AA0247
tableextension 14111 ItemTrackingCodeExt extends "Item Tracking Code"
{
    fields
    {
        field(14100; "CD Location Setup Exists"; Boolean)
        {
            CalcFormula = Exist("CD Location Setup" WHERE("Item Tracking Code" = FIELD(Code)));
            Caption = 'CD Location Setup Exists';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
