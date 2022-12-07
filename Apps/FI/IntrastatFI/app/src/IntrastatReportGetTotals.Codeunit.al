codeunit 13408 "Intrastat Report Get Totals"
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        DataExchField: Record "Data Exch. Field";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        IntrastatReportManagementFI: Codeunit "Intrastat Report Management FI";
        DecVar: Decimal;
        TotalRoundedAmount: Integer;
    begin
        TotalRoundedAmount := 0;

        DataExchFieldMapping.SetRange("Data Exch. Def Code", Rec."Data Exch. Def Code");
        DataExchFieldMapping.SetRange("Data Exch. Line Def Code", Rec."Data Exch. Line Def Code");
        DataExchFieldMapping.SetRange("Field ID", 13); // field Amount in Intrastat Report Line
        if DataExchFieldMapping.FindFirst() then begin
            DataExchField.SetRange("Data Exch. No.", Rec."Entry No.");
            DataExchField.SetRange("Column No.", DataExchFieldMapping."Column No.");
            if DataExchField.FindSet() then
                repeat
                    Evaluate(DecVar, DataExchField.GetValue());
                    TotalRoundedAmount += Round(DecVar, 1);
                until DataExchField.Next() = 0;
        end;

        IntrastatReportManagementFI.SetTotals(TotalRoundedAmount, DataExchField."Line No.");
    end;
}