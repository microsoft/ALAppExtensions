codeunit 139562 "Shpfy Const to return" implements "Shpfy Stock Calculation"
{
    var
        ConstToRetrun: decimal;

    procedure GetStock(var Item: Record Item): decimal;
    begin
        Exit(ConstToRetrun);
    end;

    internal procedure SetConstToReturn(NewConst: Decimal)
    begin
        ConstToRetrun := NewConst;
    end;

}
