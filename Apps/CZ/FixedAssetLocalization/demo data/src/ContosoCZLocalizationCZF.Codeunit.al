#pragma warning disable AA0247
codeunit 31217 "Contoso CZ Localization CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure BeginDemoDataUpdateOnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    begin
        BindSubscriptions(Module);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                FixedAssetModule(ContosoDemoDataLevel);
        end;

        UnbindSubscriptions(Module);
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create FA Setup CZF");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create FA Ext. Post. Group CZF");
        end;
    end;

    local procedure BindSubscriptions(Module: Enum "Contoso Demo Data Module")
    var
        CreateFAPostingGroupCZF: Codeunit "Create FA Posting Group CZF";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFAPostingGroupCZF);
        end;
    end;

    local procedure UnbindSubscriptions(Module: Enum "Contoso Demo Data Module")
    var
        CreateFAPostingGroupCZF: Codeunit "Create FA Posting Group CZF";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFAPostingGroupCZF);
        end;
    end;
}
