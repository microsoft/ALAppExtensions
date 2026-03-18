// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool;
using Microsoft.eServices.EDocument.DemoData;
using Microsoft.Purchases.Document;

codeunit 13439 "EDoc. Demodata FI"
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create E-Doc. Sample Invoices", OnUpdateRequiredDataInPurchaseHeaderForPosting, '', false, false)]
    local procedure OnUpdateRequiredDataInPurchaseHeaderForPosting(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.Validate("Message Type", PurchaseHeader."Message Type"::Message);
        PurchaseHeader.Validate("Invoice Message", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
    end;

    local procedure DefineLocalGLAccountInEDocumentsModuleSetup()
    var
        EDocumentModuleSetup: Record "E-Document Module Setup";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        EDocumentModuleSetup.InitEDocumentModuleSetup();
        EDocumentModuleSetup."Recurring Expense G/L Acc. No" := CreateFIGLAccounts.ITservices();
        EDocumentModuleSetup."Delivery Expense G/L Acc. No" := CreateFIGLAccounts.Shipping();
        EDocumentModuleSetup.Modify();
    end;
}
