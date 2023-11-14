// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using System.Environment.Configuration;

codeunit 31028 "Instruction Mgt. CZL"
{
    Permissions = tabledata "My Notifications" = rimd;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        WarnVATLCYDocumentTxt: Label 'Warn about VAT in local currency.';
        WarnVATLCYDocumentsDescriptionTxt: Label 'Show warning to check the VAT amount in local currency if the purchase document (invoice, credit memo) has been posted in a foreign currency.';


    procedure ShowVATLCYCorrectionConfirmationMessageCode(): Code[50]
    begin
        exit(UpperCase('ShowVATLCYCorrectionConfirmationMessage'));
    end;

    procedure GetOpeningVATLCYCorrectionNotificationId(): Guid
    begin
        exit('F75390d9-F39A-4621-8982-61AB7DA2EE6C');
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetOpeningVATLCYCorrectionNotificationId(),
          WarnVATLCYDocumentTxt,
          WarnVATLCYDocumentsDescriptionTxt,
          InstructionMgt.IsEnabled(GetOpeningVATLCYCorrectionNotificationId()));
    end;

    [EventSubscriber(ObjectType::Table, 1518, 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
        case NotificationId of
            GetOpeningVATLCYCorrectionNotificationId():
                if NewEnabledState then
                    InstructionMgt.EnableMessageForCurrentUser(ShowVATLCYCorrectionConfirmationMessageCode())
                else
                    InstructionMgt.DisableMessageForCurrentUser(ShowVATLCYCorrectionConfirmationMessageCode());
        end;
    end;
}
