codeunit 133102 "Sample Setup For Test"
{
    trigger OnRun()
    begin
        Page.RunModal(Page::"Extension Settings");
    end;

}