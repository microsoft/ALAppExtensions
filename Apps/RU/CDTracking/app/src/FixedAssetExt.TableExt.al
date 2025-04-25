#pragma warning disable AA0247
tableextension 14110 FixedAssetExt extends "Fixed Asset"
{
    fields
    {
        field(14100; "CD Number"; Code[50])
        {
            Caption = 'CD Number';
            TableRelation = "CD FA Information"."CD No." WHERE("FA No." = FIELD("No."));
        }
    }
}
