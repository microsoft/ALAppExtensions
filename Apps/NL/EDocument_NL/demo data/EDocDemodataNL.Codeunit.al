// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;
using Microsoft.eServices.EDocument.DemoData;

codeunit 11554 "E-Doc. Demodata NL"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module <> Enum::"Contoso Demo Data Module"::"E-Document Contoso Module" then
            exit;
        if ContosoDemoDataLevel = ContosoDemoDataLevel::"Transactional Data" then
            DefineLocalGLAccountInEDocumentsModuleSetup();
    end;

    local procedure DefineLocalGLAccountInEDocumentsModuleSetup()
    var
        EDocumentModuleSetup: Record "E-Document Module Setup";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        EDocumentModuleSetup.InitEDocumentModuleSetup();
        EDocumentModuleSetup."Recurring Expense G/L Acc. No" := CreateNLGLAccounts.LegalFeesandAttorneyServices();
        EDocumentModuleSetup."Delivery Expense G/L Acc. No" := CreateNLGLAccounts.Freightfeesforgoods();
        EDocumentModuleSetup.Modify();
    end;
}