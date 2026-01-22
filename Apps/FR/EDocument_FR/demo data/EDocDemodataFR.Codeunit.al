// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;

codeunit 10914 "E-Doc. Demodata FR"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module <> Enum::"Contoso Demo Data Module"::"E-Document Contoso Module" then
            exit;
        EDocumentModule(ContosoDemoDataLevel);
    end;

    local procedure EDocumentModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        ContosoDemoDataLevel := ContosoDemoDataLevel;
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                begin
                    Codeunit.Run(Codeunit::"Create Demo EDocs FR");
                    Codeunit.Run(Codeunit::"Create E-Doc Sample Inv. FR");
                end;
        end;
    end;
}
