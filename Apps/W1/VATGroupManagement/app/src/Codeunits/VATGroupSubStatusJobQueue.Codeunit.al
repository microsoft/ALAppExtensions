codeunit 4707 "VAT Group Sub. Status JobQueue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"VAT Group Submission Status");
    end;
}