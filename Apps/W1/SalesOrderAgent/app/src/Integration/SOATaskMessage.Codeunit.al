// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Email;
using Microsoft.CRM.Contact;

codeunit 4398 "SOA Task Message"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SentMessageTemplateLbl: Label '<b>Sent:</b> %1<br/>', Comment = '%1 = Sender Address';
        ToMessageTemplateLbl: Label '<b>To:</b> %1<br/>', Comment = '%1 = Sender Address';
        FromMessageTemplateLbl: Label '<b>From:</b> %1<br/>', Comment = '%1 = Sender Address';
        EmailSeparatorTok: Label '<br/><hr/>', Locked = true;
        EmailXMLWrapperTxt: Label '<div>%1</div>', Locked = true, Comment = '%1 = Email message text';

    internal procedure GetPreviousText(AgentTaskMessage: Record "Agent Task Message"): Text
    var
        PreviousAgentTaskMessage: Record "Agent Task Message";
        PreviousMessagesText: Text;
    begin
        PreviousAgentTaskMessage.SetRange("Task ID", AgentTaskMessage."Task ID");
        PreviousAgentTaskMessage.SetFilter(SystemCreatedAt, '<%1', AgentTaskMessage.SystemCreatedAt);
        PreviousAgentTaskMessage.SetFilter(Status, '<>%1', PreviousAgentTaskMessage.Status::Discarded);
        PreviousAgentTaskMessage.ReadIsolation := IsolationLevel::ReadUncommitted;
        PreviousAgentTaskMessage.SetCurrentKey(SystemCreatedAt);
        PreviousAgentTaskMessage.Ascending(false);

        if not PreviousAgentTaskMessage.FindSet() then
            exit('');

        PreviousMessagesText := GetPreviousMessageText(PreviousAgentTaskMessage);
        if PreviousAgentTaskMessage.Next() <> 0 then begin
            repeat
                PreviousMessagesText += EmailSeparatorTok + GetPreviousMessageText(PreviousAgentTaskMessage);
            until PreviousAgentTaskMessage.Next() = 0;

            PreviousMessagesText := StrSubstNo(EmailXMLWrapperTxt, PreviousMessagesText);
        end;

        exit(PreviousMessagesText);
    end;

    local procedure GetPreviousMessageText(var PreviousAgentTaskMessage: Record "Agent Task Message"): Text
    var
        AgentMessage: Codeunit "Agent Message";
        ToAddress: Text;
        HeaderText: Text;
        TextMessage: Text;
    begin
        TextMessage := AgentMessage.GetText(PreviousAgentTaskMessage);
        Clear(HeaderText);
        if PreviousAgentTaskMessage.Type = PreviousAgentTaskMessage.Type::Output then begin
            if GetSentMessageToAddress(PreviousAgentTaskMessage, ToAddress) then
                HeaderText += StrSubstNo(ToMessageTemplateLbl, ToAddress);
            HeaderText += StrSubstNo(SentMessageTemplateLbl, Format(PreviousAgentTaskMessage.SystemModifiedAt));
        end;

        if (PreviousAgentTaskMessage.Type = PreviousAgentTaskMessage.Type::Input) then begin
            if (PreviousAgentTaskMessage.From <> '') then
                HeaderText += StrSubstNo(FromMessageTemplateLbl, PreviousAgentTaskMessage.From);
            HeaderText += StrSubstNo(SentMessageTemplateLbl, Format(GetSentMessageDate(PreviousAgentTaskMessage)));
        end;

        exit(HeaderText + TextMessage);
    end;

    internal procedure GetSentMessageDate(AgentTaskMessage: Record "Agent Task Message"): DateTime
    var
        SOAEmail: Record "SOA Email";
    begin
        SOAEmail.SetRange("Task ID", AgentTaskMessage."Task ID");
        SOAEmail.SetRange("Task Message ID", AgentTaskMessage.ID);
        if not SOAEmail.FindFirst() then
            exit(AgentTaskMessage.SystemCreatedAt);

        exit(SOAEmail."Sent DateTime");
    end;

    internal procedure GetSentMessageToAddress(var OutputAgentTaskMessage: Record "Agent Task Message"; var ToAddress: Text): Boolean
    var
        SentAgentTaskMessage: Record "Agent Task Message";
    begin
        Clear(ToAddress);
        if OutputAgentTaskMessage.Type <> OutputAgentTaskMessage.Type::Output then
            exit(false);

        if not SentAgentTaskMessage.Get(OutputAgentTaskMessage."Task ID", OutputAgentTaskMessage."Input Message ID") then
            exit(false);
        if SentAgentTaskMessage.From = '' then
            exit(false);

        ToAddress := SentAgentTaskMessage.From;
        exit(true);
    end;

    internal procedure MessageRequiresReview(SOASetup: Record "SOA Setup"; EmailInbox: Record "Email Inbox"; IsFirstMessageInTask: Boolean): Boolean
    var
        Contact: Record Contact;
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
        SOAInputMessageReview: Enum "SOA Input Message Review";
    begin
        // If we have the same review setting for both registered and unregistered senders,
        // then we can skip trying to find the contact.
        if SOASetup."Known Sender In. Msg. Review" = SOASetup."Unknown Sender In. Msg. Review" then
            SOAInputMessageReview := SOASetup."Known Sender In. Msg. Review"
        else begin
            // Check if the sender is a registered contact
            Contact.SetFilter("E-Mail", SOAFiltersImpl.GetSafeFromEmailFilter(EmailInbox."Sender Address"));
            Contact.ReadIsolation := IsolationLevel::ReadCommitted;
            if Contact.IsEmpty() then
                SOAInputMessageReview := SOASetup."Unknown Sender In. Msg. Review"
            else
                SOAInputMessageReview := SOASetup."Known Sender In. Msg. Review";
        end;

        case SOAInputMessageReview of
            SOAInputMessageReview::"All Messages":
                exit(true);
            SOAInputMessageReview::"First Message":
                exit(IsFirstMessageInTask);
            SOAInputMessageReview::"No Review":
                exit(false);
            else
                // If the review setting is not recognized, we default to 'true'.
                // This is a safety measure to ensure that we don't skip reviews unintentionally.
                exit(true);
        end;
    end;

}