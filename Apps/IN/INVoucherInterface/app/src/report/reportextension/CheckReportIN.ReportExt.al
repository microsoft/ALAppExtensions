reportextension 18940 "Check Report IN ReportExt" extends Check
{
    dataset
    {
        modify(GenJnlLine)
        {
            trigger OnBeforeAfterGetRecord()
            var
                TaxBaseLibrary: Codeunit "Tax Base Library";
                TDSAmount: Decimal;
            begin
                if GenJnlLine."TDS Section Code" <> '' then begin
                    TaxBaseLibrary.GetTDSAmount(GenJnlLine, TDSAmount);
                    GenJnlLine.Amount -= TDSAmount;
                end;
            end;

            trigger OnAfterAfterGetRecord()
            var
                TaxBaseLibrary: Codeunit "Tax Base Library";
                TDSAmount: Decimal;
            begin
                if GenJnlLine."TDS Section Code" <> '' then begin
                    TaxBaseLibrary.GetTDSAmount(GenJnlLine, TDSAmount);
                    GenJnlLine.Amount += TDSAmount;
                end;
            end;

        }
    }
}