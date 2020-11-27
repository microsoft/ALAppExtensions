tableextension 11768 "Payment Method CZP" extends "Payment Method"
{
    fields
    {
        field(11740; "Cash Desk Code CZP"; Code[20])
        {
            Caption = 'Cash Desk Code';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Cash Desk Code CZP" = '' then
                    "Cash Document Action CZP" := "Cash Document Action CZP"::" "
                else
                    if xRec."Cash Document Action CZP" = "Cash Document Action CZP"::" " then
                        "Cash Document Action CZP" := "Cash Document Action CZP"::Create;
            end;
        }
        field(11741; "Cash Document Action CZP"; Enum "Cash Document Action CZP")
        {
            Caption = 'Cash Document Action';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Cash Document Action CZP" <> "Cash Document Action CZP"::" " then
                    TestField("Cash Desk Code CZP");
            end;
        }
    }
}
