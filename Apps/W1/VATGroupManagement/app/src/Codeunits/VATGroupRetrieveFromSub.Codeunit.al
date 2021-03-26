codeunit 4703 "VAT Group Retrieve From Sub."
{
    TableNo = "VAT Report Header";
    trigger OnRun()
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupApprovedMember: Record "VAT Group Approved Member";
    begin
        VATStatementReportLine.SetRange("VAT Report No.", Rec."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", Rec."VAT Report Config. Code");
        if not VATStatementReportLine.FindSet(true) then
            Error(SuggestLinesBeforeErr);

        //reset to original representative amount
        VATStatementReportLine.CalcSums(Amount);
        SumBefore := VATStatementReportLine.Amount;

        repeat
            VATStatementReportLine.Amount := VATStatementReportLine."Representative Amount";
            VATStatementReportLine.Modify();
        until VATStatementReportLine.Next() = 0;


        if VATGroupApprovedMember.FindSet() then begin
            VATGroupSubmissionHeader.SetFiltersForLastSubmissionInAPeriod(Rec."Start Date", Rec."End Date", true, '');

            repeat
                VATGroupSubmissionHeader.SetRange("Group Member ID", VATGroupApprovedMember.ID);
                if VATGroupSubmissionHeader.FindLast() then begin
                    // sum the amount based on the box no.
                    VATGroupSubmissionLine.SetRange("VAT Group Submission ID", VATGroupSubmissionHeader.ID);
                    if VATGroupSubmissionLine.FindSet() then
                        repeat
                            VATStatementReportLine.SetRange("Box No.", VATGroupSubmissionLine."Box No.");
                            if VATStatementReportLine.FindFirst() then begin
                                VATStatementReportLine.Amount += VATGroupSubmissionLine.Amount;
                                VATStatementReportLine.Modify();
                            end;
                        until VATGroupSubmissionLine.Next() = 0;
                end;
            until VATGroupApprovedMember.Next() = 0;
        end;

        VATStatementReportLine.SetRange("Box No.");
        VATStatementReportLine.CalcSums(Amount);
        SumAfter := VATStatementReportLine.Amount;
    end;

    var
        SumBefore: Decimal;
        SumAfter: Decimal;
        SuggestLinesBeforeErr: label 'You must run the Suggest Lines action before you include returns for the VAT group.';

    internal procedure IsNotificationNeeded(): Boolean
    begin
        exit(SumBefore <> SumAfter);
    end;
}