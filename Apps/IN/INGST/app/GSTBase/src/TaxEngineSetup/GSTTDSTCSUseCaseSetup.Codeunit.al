// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18014 "GST TDS TCS Use Case Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        CaseList: list of [Guid];
        CaseId: Guid;
    begin
        UpdateUseCaseList(CaseList);

        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        foreach CaseId in CaseList do
            TaxJsonDeserialization.ImportUseCases(GetText(CaseId));
    end;

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
        GSTTDSTCSTaxTypeSetup: Codeunit "GST TDS TCS Tax Type Setup";
        IsHandled: Boolean;
    begin
        exit(GSTTDSTCSTaxTypeSetup.GetConfig(CaseId, IsHandled));
    end;

    local procedure UpdateUseCaseList(CaseList: list of [Guid])
    begin
        CaseList.Add('{94D595D0-1FF1-4501-AC76-164AD453F547}');
        CaseList.Add('{8DDE731C-68ED-4658-BF7F-58385526601A}');
        CaseList.Add('{2EC51C0B-DBA5-490B-AA60-944452C6BD3E}');
        CaseList.Add('{C5A33AA3-0DA8-42DC-B6B2-B55888508F58}');
        CaseList.Add('{81E6747B-B7CE-4A75-BEE5-F630FF17C687}');
        CaseList.Add('{c34d7e4b-1538-4d41-9e72-71dfcf6fc94d}');
        CaseList.Add('{5430a349-b6ae-4ca1-a7d9-6884d93da5ef}');
    end;
}
