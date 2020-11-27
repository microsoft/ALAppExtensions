tableextension 11712 "Inventory Setup CZL" extends "Inventory Setup"
{
    fields
    {
        field(31063; "Def.Tmpl. for Phys.Pos.Adj CZL"; Code[10])
        {
            Caption = 'Default Template for Physical Inventory Positive Adjustment';
            TableRelation = "Invt. Movement Template CZL" where("Entry Type" = const("Positive Adjmt."));
            DataClassification = CustomerContent;
        }
        field(31064; "Def.Tmpl. for Phys.Neg.Adj CZL"; Code[10])
        {
            Caption = 'Default Template for Physical Inventory Negative Adjustment';
            TableRelation = "Invt. Movement Template CZL" where("Entry Type" = const("Negative Adjmt."));
            DataClassification = CustomerContent;
        }
    }
}
