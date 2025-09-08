// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

#if not CLEAN27
using Microsoft.Finance.GST.Base;
#endif
codeunit 18009 "Cess Use Case Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        ImportGSTUseCase: Codeunit "Import GST Use Case";
    begin
        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        ImportGSTUseCase.ImportUseCases(ImportGSTUseCase.GetResourceForUseCase(GSTCessResFileLbl));
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade GST Tax Config", 'OnUpgradeGSTUseCases', '', false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UseCaseConfig := GetText(CaseID);
        if UseCaseConfig <> '' then
            IsHandled := true;
    end;

    local procedure GetText(CaseId: Guid): Text
    var
        CessTaxTypeSetup: Codeunit "Cess Tax Type Setup";
        IsHandled: Boolean;
    begin
        exit(CessTaxTypeSetup.GetConfig(CaseId, IsHandled))
    end;
#endif

    var
        GSTCessResFileLbl: Label 'GSTCESS', MaxLength = 20;
}
