// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1566 "System Privacy Notice Reg."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        MicrosoftTeamsTxt: Label 'Microsoft Teams', Locked = true; // Product names are not translated and it's important this entry exists.
        PowerAutomateIdTxt: Label 'Power Automate', Locked = true; // Product names are not translated and it's important this entry exists.
        PowerAutomateLabelTxt: Label 'Microsoft Power Automate', Locked = true; // Product names are not translated and it's important this entry exists.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", OnRegisterPrivacyNotices, '', false, false)]
    local procedure CreatePrivacyNoticeRegistrations(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
        TempPrivacyNotice.Init();
        TempPrivacyNotice.ID := MicrosoftTeamsTxt;
        TempPrivacyNotice."Integration Service Name" := MicrosoftTeamsTxt;
        if not TempPrivacyNotice.Insert() then;
        TempPrivacyNotice.ID := PowerAutomateIdTxt;
        TempPrivacyNotice."Integration Service Name" := PowerAutomateLabelTxt;
        if not TempPrivacyNotice.Insert() then;
    end;

    procedure GetTeamsPrivacyNoticeId(): Code[50]
    begin
        exit(MicrosoftTeamsTxt);
    end;

    procedure GetPowerAutomatePrivacyNoticeId(): Code[50]
    begin
        exit(PowerAutomateIdTxt);
    end;

    procedure GetPowerAutomatePrivacyNoticeName(): Code[250]
    begin
        exit(PowerAutomateLabelTxt);
    end;
}
