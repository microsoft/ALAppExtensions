codeunit 5111 "Create Svc Loaners Demo Data"
{

    Permissions =
        tabledata "Loaner" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        LOANER1Tok: Label 'LOANER1', MaxLength = 10;
        LOANER2Tok: Label 'LOANER2', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateLoaners();
    end;

    local procedure CreateLoaners()
    begin
        CreateLoaner(LOANER1Tok, SvcDemoDataSetup."Item 1 No.");
        CreateLoaner(LOANER2Tok, SvcDemoDataSetup."Item 2 No.");
    end;

    local procedure CreateLoaner(LoanerNo: Code[20]; ItemNo: Code[20])
    var
        Loaner: Record "Loaner";
    begin
        if Loaner.Get(LoanerNo) then
            exit;
        Loaner.Init();
        Loaner.Validate("No.", LoanerNo);
        Loaner.Validate("Description", LoanerNo);
        Loaner.Validate("Item No.", ItemNo);
        Loaner.Insert(true);
    end;
}