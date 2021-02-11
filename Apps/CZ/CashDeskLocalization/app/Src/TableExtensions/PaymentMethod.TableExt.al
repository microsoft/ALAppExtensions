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
                else begin
                    if xRec."Cash Document Action CZP" = "Cash Document Action CZP"::" " then
                        "Cash Document Action CZP" := "Cash Document Action CZP"::Create;
                    CheckCashDocumentAction();
                end;
            end;
        }
        field(11741; "Cash Document Action CZP"; Enum "Cash Document Action CZP")
        {
            Caption = 'Cash Document Action';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Cash Document Action CZP" <> "Cash Document Action CZP"::" " then begin
                    TestField("Cash Desk Code CZP");
                    CheckCashDocumentAction();
                end;
            end;
        }
    }

    local procedure CheckCashDocumentAction()
    var
        EETManagementCZP: Codeunit "EET Management CZP";
    begin
        EETManagementCZP.CheckCashDocumentAction("Cash Desk Code CZP", "Cash Document Action CZP");
    end;
}
