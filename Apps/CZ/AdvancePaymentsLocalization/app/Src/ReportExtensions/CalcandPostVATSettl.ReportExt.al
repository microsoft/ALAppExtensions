reportextension 31005 "Calc. and Post VAT Settl. CZZ" extends "Calc. and Post VAT Settl. CZL"
{
    dataset
    {

        modify(Advance)
        {
            trigger OnAfterPreDataItem()
            begin
                SetRange(Number, 1, 2);
            end;

            trigger OnAfterAfterGetRecord()
            begin
                CalcAndPostVATHandler.SetAdvanceNumberRun(Advance.Number);
            end;
        }
    }
    trigger OnPreReport()
    begin
        BindSubscription(CalcAndPostVATHandler);
    end;

    trigger OnPostReport()
    begin
        UnbindSubscription(CalcAndPostVATHandler);
    end;

    var
        CalcAndPostVATHandler: Codeunit "Calc. And Post VAT Handler CZZ";
}