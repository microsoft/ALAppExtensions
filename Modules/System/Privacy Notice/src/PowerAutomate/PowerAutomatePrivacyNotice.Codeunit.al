// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1568 "Power Automate Privacy Notice"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SignInAgainMsg: Label 'You must sign out and then sign in again to make the changes take effect.', Comment = '"sign out" and "sign in" are the same terms as shown in the Business Central client.';
        SignInAgainNotificationGuidTok: Label '63b6f5ec-6db4-4e87-b103-c4bcb539f09e', Locked = true;
        ShowingPrivacyNoticeTelemetryTxt: Label 'Showing privacy notice for Power Automate', Locked = true;
        TelemetryCategoryTxt: Label 'Privacy Notice Power Automate', Locked = true;

    local procedure SendSignInAgainNotification()
    var
        SignInAgainNotification: Notification;
    begin
        SignInAgainNotification.Id := SignInAgainNotificationGuidTok;
        SignInAgainNotification.Message := SignInAgainMsg;
        SignInAgainNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        SignInAgainNotification.Send();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Privacy Notice Approval", OnAfterModifyEvent, '', false, false)]
    local procedure DisplayNotificiationAfterModifyPowerAutomate(var Rec: Record "Privacy Notice Approval"; var xRec: Record "Privacy Notice Approval")
    var
        SystemPrivacyNoticeRegCodeunit: Codeunit "System Privacy Notice Reg.";
    begin
        if Rec.IsTemporary then
            exit;

        if not (Rec.ID = SystemPrivacyNoticeRegCodeunit.GetPowerAutomatePrivacyNoticeId()) then
            exit;

        SendSignInAgainNotification();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Privacy Notice Approval", OnAfterInsertEvent, '', false, false)]
    local procedure DisplayNotificiationAfterInsertPowerAutomate(var Rec: Record "Privacy Notice Approval")
    var
        SystemPrivacyNoticeRegCodeunit: Codeunit "System Privacy Notice Reg.";
    begin
        if Rec.IsTemporary then
            exit;

        if not (Rec.ID = SystemPrivacyNoticeRegCodeunit.GetPowerAutomatePrivacyNoticeId()) then
            exit;

        SendSignInAgainNotification();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Privacy Notice Approval", OnBeforeDeleteEvent, '', false, false)]
    local procedure DisplayNotificiationBeforeDeletePowerAutomate(var Rec: Record "Privacy Notice Approval")
    var
        SystemPrivacyNoticeRegCodeunit: Codeunit "System Privacy Notice Reg.";
    begin
        if Rec.IsTemporary() then
            exit;

        if not (Rec.ID = SystemPrivacyNoticeRegCodeunit.GetPowerAutomatePrivacyNoticeId()) then
            exit;

        SendSignInAgainNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", OnBeforeShowPrivacyNotice, '', false, false)]
    local procedure ShowPrivacyNoticePowerAutomate(PrivacyNotice: Record "Privacy Notice"; var Handled: Boolean)
    var
        SystemPrivacyNoticeReg: Codeunit "System Privacy Notice Reg.";
        PowerAutomatePrivacyNoticePage: Page "Power Automate Privacy Notice";
    begin
        if Handled then
            exit;

        if PrivacyNotice.ID <> SystemPrivacyNoticeReg.GetPowerAutomatePrivacyNoticeId() then
            exit;

        Session.LogMessage('0000I58', ShowingPrivacyNoticeTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        PowerAutomatePrivacyNoticePage.SetRecord(PrivacyNotice);
        PowerAutomatePrivacyNoticePage.RunModal();
        Handled := true;
    end;

}
