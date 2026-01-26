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
        WarnVATLCYPurchDocumentTxt: Label 'Warn about VAT in local currency in purchase.';
        WarnVATLCYSalesDocumentTxt: Label 'Warn about VAT in local currency in sales.';
        WarnVATLCYPurchDocumentsDescriptionTxt: Label 'Show warning to check the VAT amount in local currency if the purchase document (invoice, credit memo) has been posted in a foreign currency.';
        WarnVATLCYSalesDocumentsDescriptionTxt: Label 'Show warning to check the VAT amount in local currency if the sales document (invoice, credit memo) has been posted in a foreign currency.';

    procedure ShowVATLCYCorrectionConfirmationMessageCode(): Code[50]
    begin
        exit(UpperCase('ShowVATLCYCorrectionConfirmationMessage'));
    end;

    procedure ShowVATLCYCorrectionConfirmationMessageForSalesCode(): Code[50]
    begin
        exit(UpperCase('ShowVATLCYCorrectionConfirmationMessageForSales'));
    end;

    procedure GetOpeningVATLCYCorrectionNotificationId(): Guid
    begin
        exit('F75390d9-F39A-4621-8982-61AB7DA2EE6C');
    end;

    procedure GetOpeningVATLCYCorrectionForSalesNotificationId(): Guid
    begin
        exit('1E9C0A99-46A9-4873-AAEB-27D195AA9430');
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetOpeningVATLCYCorrectionNotificationId(),
          WarnVATLCYPurchDocumentTxt,
          WarnVATLCYPurchDocumentsDescriptionTxt,
          InstructionMgt.IsEnabled(GetOpeningVATLCYCorrectionNotificationId()));
        MyNotifications.InsertDefault(GetOpeningVATLCYCorrectionForSalesNotificationId(),
          WarnVATLCYSalesDocumentTxt,
          WarnVATLCYSalesDocumentsDescriptionTxt,
          InstructionMgt.IsEnabled(GetOpeningVATLCYCorrectionForSalesNotificationId()));
    end;

    [EventSubscriber(ObjectType::Table, 1518, 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
        if NewEnabledState then
            InstructionMgt.EnableMessageForCurrentUser(GetInstructionType(NotificationId))
        else
            InstructionMgt.DisableMessageForCurrentUser(GetInstructionType(NotificationId));
    end;

    local procedure GetInstructionType(NotificationId: Guid): Code[50]
    begin
        case NotificationId of
            GetOpeningVATLCYCorrectionNotificationId():
                exit(ShowVATLCYCorrectionConfirmationMessageCode());
            GetOpeningVATLCYCorrectionForSalesNotificationId():
                exit(ShowVATLCYCorrectionConfirmationMessageForSalesCode())
        end;
    end;
}
