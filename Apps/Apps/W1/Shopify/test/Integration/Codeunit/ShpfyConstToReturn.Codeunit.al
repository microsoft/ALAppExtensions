codeunit 139562 "Shpfy Const to Return" implements "Shpfy Stock Calculation"
{
    var
        ConsttoReturn: Decimal;

    procedure GetStock(var Item: Record Item): Decimal;
    begin
        exit(ConsttoReturn);
    end;

    internal procedure SetConstToReturn(NewConst: Decimal)
    begin
        ConsttoReturn := NewConst;
    end;

}
