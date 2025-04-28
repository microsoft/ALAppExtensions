codeunit 31429 "Contoso Bank Documents CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateBankAccountCZB: Codeunit "Create Bank Account CZB";
    begin
        if Module <> Enum::"Contoso Demo Data Module"::Bank then
            exit;

        BindSubscription(CreateBankAccountCZB);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateBankAccountCZB: Codeunit "Create Bank Account CZB";
    begin
        if Module <> Enum::"Contoso Demo Data Module"::Bank then
            exit;

        UnbindSubscription(CreateBankAccountCZB);
    end;
}
