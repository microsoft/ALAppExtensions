tableextension 18017 "GST Item Templ. Ext." extends "Item Templ."
{
    fields
    {
        field(18000; "GST Group Code"; code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(18001; "HSN/SAC Code"; code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18002; "GST Credit"; enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
    }
}