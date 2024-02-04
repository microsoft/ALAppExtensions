// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Finance.VAT.Calculation;

using System.Environment;
using System.Environment.Configuration;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 31463 "Replace VAT Date Mgt. CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'The VAT Date CZL will be replaced by VAT Reporting Date by default.';

    var
        ReplaceVATDateFeatureIdTok: Label 'ReplaceVATDateCZ', Locked = true, MaxLength = 50;
        ReplaceVATDateNotEnabledErr: Label 'The replacing VAT Date CZ field with VAT Reporting Date is not enabled.\Please enable it by using Feature Management before use.';
        ReplaceVATDateEnabledErr: Label 'The replacing VAT Date CZ field with VAT Reporting Date is already enabled.\Please use the new VAT Reporting Date feature instead.';

    procedure IsEnabled() FeatureEnabled: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        FeatureEnabled := FeatureManagementFacade.IsEnabled(GetFeatureKey());
#pragma warning disable AL0432
        OnAfterIsEnabled(FeatureEnabled);
#pragma warning restore AL0432
    end;

    procedure TestIsEnabled()
    begin
        if not IsEnabled() then
            Error(ReplaceVATDateNotEnabledErr);
    end;

    procedure TestIsNotEnabled()
    begin
        if IsEnabled() then
            Error(ReplaceVATDateEnabledErr);
    end;

    procedure GetFeatureKey(): Text[50]
    begin
        exit(ReplaceVATDateFeatureIdTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', true, true)]
    local procedure OnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        Company: Record Company;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if FeatureKey.ID <> GetFeatureKey() then
            exit;
        if Company.FindSet() then
            repeat
                GeneralLedgerSetup.ChangeCompany(Company.Name);
                GeneralLedgerSetup.Get();
                if GeneralLedgerSetup."Use VAT Date CZL" then
                    GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::"Enabled (Prevent modification)"
                else
                    GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Disabled;
                GeneralLedgerSetup.Modify();
            until Company.Next() = 0;
    end;

    [Obsolete('The VAT Date CZL will be replaced by VAT Reporting Date by default.', '22.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
    end;
}
#endif
