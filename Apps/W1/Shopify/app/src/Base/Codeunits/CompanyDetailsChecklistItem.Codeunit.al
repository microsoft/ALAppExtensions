codeunit 30203 "Company Details Checklist Item"
{
    Access = Internal;

    trigger OnRun()
    begin
        Page.Run(Page::"Assisted Company Setup Wizard");
    end;
}