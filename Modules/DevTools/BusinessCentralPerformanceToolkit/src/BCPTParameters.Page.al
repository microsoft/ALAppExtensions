page 149009 "BCPT Parameters"
{
    Caption = 'Parameters';
    PageType = StandardDialog;
    Extensible = false;
    SourceTable = "BCPT Parameter Line";
    sourcetabletemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name; Rec."Parameter Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the parameter for the test codeunit.';
                }
                field(Value; Rec."Parameter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value in text format of the parameter.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := true;
    end;

    internal procedure GetParameterString(): Text
    var
        ResultString: Text;
    begin
        if Rec.IsEmpty then
            exit('');
        if Rec.FindSet() then
            repeat
                if ResultString <> '' then
                    ResultString += ', ';
                ResultString += Rec."Parameter Name" + '=' + Rec."Parameter Value";
            until Rec.next() = 0;
        exit(ResultString);
    end;

    internal procedure SetParamTable(Params: Text)
    var
        i: Integer;
        p: Integer;
        KeyVal: Text;
        NoOfParams: Integer;
    begin
        Rec.DeleteAll();
        if Params = '' then
            exit;
        NoOfParams := StrLen(Params) - strlen(delchr(Params, '=', ',')) + 1;
        for i := 1 to NoOfParams do begin
            if NoOfParams = 1 then
                KeyVal := Params
            else
                KeyVal := SelectStr(i, Params);
            p := StrPos(KeyVal, '=');
            Rec.init();

            if p > 0 then begin
                Rec."Parameter Name" := CopyStr(delchr(delchr(CopyStr(KeyVal, 1, p - 1)), '<'), 1, MaxStrLen(rec."Parameter Name"));
                Rec."Parameter Value" := CopyStr(delchr(delchr(CopyStr(KeyVal, p + 1)), '<'), 1, MaxStrLen(rec."Parameter Name"));
            end else
                Rec."Parameter Name" := CopyStr(delchr(delchr(KeyVal), '<'), 1, MaxStrLen(rec."Parameter Name"));
            Rec.insert();
        end;
    end;
}