codeunit 5541 "Create Named Forward Link"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        NamedForwardLink.Load();
    end;
}