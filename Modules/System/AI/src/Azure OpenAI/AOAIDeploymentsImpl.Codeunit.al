// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Environment;

codeunit 7769 "AOAI Deployments Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EnviromentInformation: Codeunit "Environment Information";
        UnableToGetDeploymentNameErr: Label 'Unable to get deployment name, if this is a third party capability you must specify your own deployment name. You may need to contact your partner.';
        Turbo0301SaasLbl: Label 'turbo-0301', Locked = true;
        GPT40613SaasLbl: Label 'gpt4-0613', Locked = true;
        Turbo0613SaasLbl: Label 'turbo-0613', Locked = true;
        Turbo0301Lbl: Label 'chatGPT_GPT35-turbo-0301', Locked = true;
        GPT40613Lbl: Label 'GPT-4-32K-0314', Locked = true;
        Turbo031316kLbl: Label 'gpt-35-turbo-16k', Locked = true;

    [NonDebuggable]
    procedure GetTurbo0301(CallerModuleInfo: ModuleInfo): Text
    begin
        if EnviromentInformation.IsSaaS() then
            exit(GetDeploymentName(Turbo0301SaasLbl, CallerModuleInfo));

        exit(Turbo0301Lbl);
    end;

    [NonDebuggable]
    procedure GetGPT40613(CallerModuleInfo: ModuleInfo): Text
    begin
        if EnviromentInformation.IsSaaS() then
            exit(GetDeploymentName(GPT40613SaasLbl, CallerModuleInfo));

        exit(GPT40613Lbl);
    end;

    [NonDebuggable]
    procedure GetTurbo0613(CallerModuleInfo: ModuleInfo): Text
    begin
        if EnviromentInformation.IsSaaS() then
            exit(GetDeploymentName(Turbo0613SaasLbl, CallerModuleInfo));

        exit(Turbo031316kLbl);
    end;

    [NonDebuggable]
    local procedure GetDeploymentName(DeploymentName: Text; CallerModuleInfo: ModuleInfo): Text
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if (CallerModuleInfo.Publisher <> CurrentModuleInfo.Publisher) then
            Error(UnableToGetDeploymentNameErr);

        exit(DeploymentName);
    end;
}