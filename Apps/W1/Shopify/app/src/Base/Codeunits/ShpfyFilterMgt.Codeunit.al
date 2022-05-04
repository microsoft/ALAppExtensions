codeunit 30104 "Shpfy Filter Mgt."
{
    Access = Internal;

    internal procedure CleanFilterValue(Value: Text): Text;
    begin
        exit('@' + Value.Replace('(', '?').Replace(')', '?').Replace('*', '?').Replace('.', '?').Replace('<', '?').Replace('>', '?').Replace('=', '?'));
    end;

    internal procedure CleanFilterValue(Value: Text; MaxLength: Integer): Text;
    begin
        exit(CleanFilterValue(CopyStr(Value, 1, MaxLength)));
    end;
}