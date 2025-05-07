#if not CLEANSCHEMA26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

#if not CLEAN26
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.Environment;
using System.Environment.Configuration;
using System.Upgrade;
#endif

codeunit 4888 "Upgrade EU3 Party Purchase"
{
    ObsoleteReason = 'EU 3rd party purchase app is moved to a new app.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';

    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
#if not CLEAN26
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDefEU3PartyPurchase: Codeunit "Upg. Tag Def. EU3 Party Purch.";
        EnvironmentInformation: Codeunit "Environment Information";
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
        Localization: Text;
#endif
    begin
#if not CLEAN26
        // app was available since v23 as EU3 Party trade  feature key was introduced for SE
        if IsFeatureKeyEnabled() then
            exit;

        if UpgradeTag.HasUpgradeTag(UpgTagDefEU3PartyPurchase.GetEU3PartyPurchaseUpgradeTag()) then
            exit;

        Localization := EnvironmentInformation.GetApplicationFamily();
        if (Localization <> 'SE') or EU3PartyTradeFeatureMgt.IsEnabled() then begin
            UpgradeTag.SetUpgradeTag(UpgTagDefEU3PartyPurchase.GetEU3PartyPurchaseUpgradeTag());
            exit;
        end;

        UpgradeEU3PartyPurchase();
        UpdateVATSetup();
        UpgradeTag.SetUpgradeTag(UpgTagDefEU3PartyPurchase.GetEU3PartyPurchaseUpgradeTag());
#endif
    end;

#if not CLEAN26
    local procedure UpgradeEU3PartyPurchase()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        VATStatementLine: Record "VAT Statement Line";
    begin
        UpdatePurchRecords(Database::"Purchase Header", 11200, PurchaseHeader.FieldNo("EU 3 Party Trade"));
        UpdatePurchRecords(Database::"Purch. Inv. Header", 11200, PurchInvHeader.FieldNo("EU 3 Party Trade"));
        UpdatePurchRecords(Database::"Purch. Cr. Memo Hdr.", 11200, PurchCrMemoHdr.FieldNo("EU 3 Party Trade"));
        UpdateStatementRecords(Database::"VAT Statement Line", 11200, VATStatementLine.FieldNo("EU 3 Party Trade"));
    end;
#endif

#if not CLEAN26
    local procedure UpdatePurchRecords(SourceTableId: Integer; SourceFieldId: Integer; TargetFieldId: Integer)
    var
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(SourceTableId, SourceTableId);
        DataTransfer.AddSourceFilter(SourceFieldId, '=%1', true);
        DataTransfer.AddFieldValue(SourceFieldId, TargetFieldId);
        DataTransfer.CopyFields();
        Clear(DataTransfer);
    end;
#endif

#if not CLEAN26
    local procedure UpdateStatementRecords(SourceTableId: Integer; SourceFieldId: Integer; TargetFieldId: Integer)
    var
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(SourceTableId, SourceTableId);
        DataTransfer.AddSourceFilter(SourceFieldId, '=%1', true);
        DataTransfer.AddConstantValue("EU3 Party Trade Filter"::EU3, TargetFieldId);
        DataTransfer.CopyFields();
        Clear(DataTransfer);

        DataTransfer.SetTables(SourceTableId, SourceTableId);
        DataTransfer.AddSourceFilter(SourceFieldId, '=%1', false);
        DataTransfer.AddConstantValue("EU3 Party Trade Filter"::"non-EU3", TargetFieldId);
        DataTransfer.CopyFields();
        Clear(DataTransfer);
    end;
#endif

#if not CLEAN26
    [Obsolete('The feature key EU3PartyTradePurchase is deleted in v26', '26.0')]
    local procedure UpdateVATSetup()
    var
        VATSetup: Record "VAT Setup";
    begin
        if not VATSetup.Get() then
            VATSetup.Insert();
        VATSetup."Enable EU 3-Party Purchase" := true;
        VATSetup.Modify(true);
    end;
#endif

#if not CLEAN26
    [Obsolete('The feature key EU3PartyTradePurchase is deleted in v26', '26.0')]
    local procedure IsFeatureKeyEnabled(): Boolean
    var
        VATSetup: Record "VAT Setup";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if not VATSetup.Get() then
            exit(false);
        exit(FeatureManagementFacade.IsEnabled('EU3PartyTradePurchase') or VATSetup."Enable EU 3-Party Purchase");
    end;
#endif
}
#endif