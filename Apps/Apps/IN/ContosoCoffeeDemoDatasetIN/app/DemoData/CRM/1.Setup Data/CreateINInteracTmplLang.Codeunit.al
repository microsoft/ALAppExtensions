// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;

codeunit 19059 "Create IN Interac. Tmpl. Lang."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateInteractionTemplateLanguages();
    end;

    local procedure CreateInteractionTemplateLanguages()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateInteractionTemplate: Codeunit "Create Interaction Template";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCRM.InsertInteractionTmplLanguage(CreateInteractionTemplate.Abstract(), CreateLanguage.ENG());
        ContosoCRM.InsertInteractionTmplLanguage(CreateInteractionTemplate.Bus(), CreateLanguage.ENG());
    end;
}
