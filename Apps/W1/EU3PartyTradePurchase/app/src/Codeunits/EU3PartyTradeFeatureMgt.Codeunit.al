// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.VAT.Setup;
using System.Environment.Configuration;

codeunit 4881 "EU3 Party Trade Feature Mgt."
{
    Permissions = TableData "Feature Key" = rm,
                TableData "VAT Setup" = r;
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

#if CLEAN23
    procedure IsEnabled(): Boolean
    var
        VATSetup: Record "VAT Setup";
    begin
        if not VATSetup.ReadPermission() then
           exit(false);
        if not VATSetup.Get() then
            exit(false);
        exit(VATSetup."Enable EU 3-Party Purchase");
    end;
#else
    [Obsolete('The feature key EU3PartyTradePurchase will be deleted as part of deprecation process', '23.0')]
    procedure IsEnabled(): Boolean
    var
        VATSetup: Record "VAT Setup";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if not VATSetup.ReadPermission() then
            exit(false);
        if not VATSetup.Get() then
            exit(false);
        exit(FeatureManagementFacade.IsEnabled(FeatureKeyIdTok) and VATSetup."Enable EU 3-Party Purchase");
    end;
#endif

#if not CLEAN23
    [Obsolete('The feature key EU3PartyTradePurchase will be deleted as part of deprecation process', '23.0')]
    procedure IsFeatureKeyEnabled(): Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        exit(FeatureManagementFacade.IsEnabled(FeatureKeyIdTok));
    end;
#else
    procedure IsFeatureKeyEnabled(): Boolean
    begin
        exit(true);
    end;
#endif

#if not CLEAN23
    [Obsolete('The feature key EU3PartyTradePurchase will be deleted as part of deprecation process', '23.0')]
    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;
#endif

#if not CLEAN23
    var
        FeatureKeyIdTok: Label 'EU3PartyTradePurchase', Locked = true;
#endif
}