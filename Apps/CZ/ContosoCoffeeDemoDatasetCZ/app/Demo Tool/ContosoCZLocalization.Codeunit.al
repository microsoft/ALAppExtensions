codeunit 31215 "Contoso CZ Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        GLSetup: Record "General Ledger Setup";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    GLSetup.Get();
                    GLSetup."VAT Reporting Date Usage" := GLSetup."VAT Reporting Date Usage"::Disabled;
                    GLSetup.Modify();
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create VAT Period CZ");
        end;
    end;
}