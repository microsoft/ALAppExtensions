codeunit 30204 "Shpfy Checklist Item List"
{
    trigger OnRun()
    begin
        Page.Run(Page::"Item List");
    end;
}