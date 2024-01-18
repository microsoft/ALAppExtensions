// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Utilities;
using System.Environment.Configuration;

codeunit 31401 "Instruction Mgt. CZB"
{
    Permissions = tabledata "My Notifications" = rimd;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        ConfirmAfterIssuingDocumentsTxt: Label 'Confirm after issuing documents.';
        ConfirmAfterIssuingDocumentsDescriptionTxt: Label 'Show warning when you issue a document where you can choose to view the issued document.';

    procedure ShowIssuedConfirmationMessageCode(): Code[50]
    begin
        exit(UpperCase('ShowIssuedConfirmationMessageCZB'));
    end;

    procedure GetOpeningIssuedDocumentNotificationId(): Guid
    begin
        exit('DACB9790-B0F5-4811-AE08-D72B17B06A94');
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetOpeningIssuedDocumentNotificationId(),
          ConfirmAfterIssuingDocumentsTxt,
          ConfirmAfterIssuingDocumentsDescriptionTxt,
          InstructionMgt.IsEnabled(GetOpeningIssuedDocumentNotificationId()));
    end;

    [EventSubscriber(ObjectType::Table, 1518, 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
        case NotificationId of
            GetOpeningIssuedDocumentNotificationId():
                if NewEnabledState then
                    InstructionMgt.EnableMessageForCurrentUser(ShowIssuedConfirmationMessageCode())
                else
                    InstructionMgt.DisableMessageForCurrentUser(ShowIssuedConfirmationMessageCode());
        end;
    end;
}
