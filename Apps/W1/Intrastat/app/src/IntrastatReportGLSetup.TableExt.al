tableextension 4818 "Intrastat Report GL Setup" extends "General Ledger Setup"
{
    fields
    {
        modify("Additional Reporting Currency")
        {
            trigger OnAfterValidate()
            var
                IntrastatReportHeader: Record "Intrastat Report Header";
                IntrastatReportLine: Record "Intrastat Report Line";
                AdjAddReportingCurr: Report "Adjust Add. Reporting Currency";
            begin
                if ("Additional Reporting Currency" <> xRec."Additional Reporting Currency") and AdjAddReportingCurr.IsExecuted() then begin
                    IntrastatReportHeader.SetRange(Reported, false);
                    IntrastatReportHeader.SetRange("Amounts in Add. Currency", true);
                    if IntrastatReportHeader.FindSet() then
                        repeat
                            IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
                            IntrastatReportLine.DeleteAll();
                        until IntrastatReportHeader.Next() = 0;
                end;
            end;
        }
    }
}