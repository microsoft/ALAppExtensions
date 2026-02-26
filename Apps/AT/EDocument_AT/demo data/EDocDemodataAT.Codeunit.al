// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool;
using Microsoft.eServices.EDocument.DemoData;

codeunit 11190 "EDoc. Demodata AT"
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
        CreateATGLAccount: Codeunit "Create AT GL Account";
    begin
        EDocumentModuleSetup.InitEDocumentModuleSetup();
        EDocumentModuleSetup."Recurring Expense G/L Acc. No" := CreateATGLAccount.ExternalServices();
        EDocumentModuleSetup."Delivery Expense G/L Acc. No" := CreateATGLAccount.DeliveryExpensesTrade();
        EDocumentModuleSetup.Modify();
    end;
}
