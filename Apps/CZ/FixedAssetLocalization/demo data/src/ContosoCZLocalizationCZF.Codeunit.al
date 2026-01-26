// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using Microsoft.DemoData.FixedAsset;

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
                begin
                    Codeunit.Run(Codeunit::"Create Depreciation Book CZF");
                    Codeunit.Run(Codeunit::"Create No. Series CZF");
                    Codeunit.Run(Codeunit::"Create FA Setup CZF");
                    Codeunit.Run(Codeunit::"Create Tax Depr. Grp. CZF");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create FA Ext. Post. Group CZF");
        end;
    end;

    local procedure BindSubscriptions(Module: Enum "Contoso Demo Data Module")
    var
        CreateFADeprBookCZF: Codeunit "Create FA Depr. Book CZF";
        CreateFAPostingGroupCZF: Codeunit "Create FA Posting Group CZF";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFAPostingGroupCZF);
                    BindSubscription(CreateFADeprBookCZF);
                end;
        end;
    end;

    local procedure UnbindSubscriptions(Module: Enum "Contoso Demo Data Module")
    var
        CreateFADeprBookCZF: Codeunit "Create FA Depr. Book CZF";
        CreateFAPostingGroupCZF: Codeunit "Create FA Posting Group CZF";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateFAPostingGroupCZF);
                    UnbindSubscription(CreateFADeprBookCZF);
                end;
        end;
    end;
}
