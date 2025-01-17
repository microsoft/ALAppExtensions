#if not CLEAN24
namespace Microsoft.Finance.EU3PartyTrade;

using System.Environment.Configuration;

codeunit 31123 "EU3 Party Trade Feat Mgt. CZL"
{
    Permissions = TableData "Feature Key" = rm;
    ObsoleteState = Pending;
    ObsoleteReason = 'The codeunit contains functions to help upgrade in countries where the feature existed in Base Application.';
    ObsoleteTag = '24.0';
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    procedure IsEnabled(): Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        exit(FeatureManagementFacade.IsEnabled(FeatureKeyIdTok));
    end;

    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;

    var
        FeatureKeyIdTok: Label 'EU3PartyTradePurchase', Locked = true;
}
#endif