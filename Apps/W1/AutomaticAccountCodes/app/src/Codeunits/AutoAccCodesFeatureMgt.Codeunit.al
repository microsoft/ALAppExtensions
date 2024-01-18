#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Environment;
using System.Environment.Configuration;

codeunit 4853 "Auto. Acc. Codes Feature Mgt."
{
    Permissions = TableData "Feature Key" = rm;
    ObsoleteState = Pending;
    ObsoleteReason = 'The codeunit contains functions to help upgrade in countries where the feature existed in Base Application.';
    ObsoleteTag = '22.0';
    Access = Internal;

    procedure OnBeforeUpgradeToAutomaticAccountCodes(var AutomaticAccHeaderTableId: Integer; var AutomaticAccLineTableId: Integer)
    begin
        AutomaticAccHeaderTableId := 11203; // Database::"Automatic Acc. Header";
        AutomaticAccLineTableId := 11204; // Database::"Automatic Acc. Line";
    end;

    procedure IsEnabled(): Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsEnabled(Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit(FeatureManagementFacade.IsEnabled(FeatureKeyIdTok));
    end;

    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;

    procedure DisableAutoAccCodesActions()
    var
        AutoAccCodesPageMgt: Codeunit "Auto. Acc. Codes Page Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        Country: Text;
    begin
        Country := EnvironmentInformation.GetApplicationFamily();
        if (Country = 'SE') or (Country = 'FI') then begin
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups Card", 11206); // page 11206 "Automatic Acc. Header"
            AutoAccCodesPageMgt.SetSetupKey(Enum::"AAC Page Setup Key"::"Automatic Acc. Groups List", 11208); // page 11208 "Automatic Acc. List"
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsEnabled(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    var
        FeatureKeyIdTok: Label 'AutomaticAccountCodes', Locked = true;
}
#endif