codeunit 31336 "Create Assembly Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateAssemblySetup();
    end;

    local procedure UpdateAssemblySetup()
    var
        AssemblySetup: Record "Assembly Setup";
        CreatePostingGroupsCZ: Codeunit "Create Posting Groups CZ";
    begin
        AssemblySetup.Get();
        AssemblySetup.Validate("Default Gen. Bus. Post. Group", CreatePostingGroupsCZ.IAssembly());
        AssemblySetup.Modify(true);
    end;
}
