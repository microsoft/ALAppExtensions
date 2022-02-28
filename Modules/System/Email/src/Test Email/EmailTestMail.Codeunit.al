// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Sends a test email to a specified account.
/// </summary>
codeunit 8887 "Email Test Mail"
{
    TableNo = "Email Account";

    var
        TestEmailChoiceTxt: Label 'Choose the email address that should receive a test email message:';
        TestEmailSubjectTxt: Label 'Test Email Message';
        TestEmailBodyTxt: Label '<body><p style="font-family:Verdana,Arial;font-size:10pt"><b>The user %1 sent this message to test their email settings. You do not need to reply to this message.</b></p><p style="font-family:Verdana,Arial;font-size:9pt"><b>Sent through connector:</b> %2<BR></p></body>', Comment = '%1 is an email address, such as user@domain.com; %2 is the name of a connector, such as SMTP;';
        TestEmailSuccessMsg: Label 'Test email has been sent to %1.\Check your email for messages to make sure that the email was delivered successfully.', Comment = '%1 is an email address.';
        TestEmailFailedMsg: Label 'An error has occured while sending the email, please look at the Outbox to find the error.';
        TestEmailOtherTxt: Label 'Other...';

    trigger OnRun()
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailUserSpecifiedAddress: Page "Email User-Specified Address";
        EmailRecipient: Text;
        EmailChoices: Text;
        SelectedEmailChoice: Integer;
        EmailBody: Text;
        EmailChoicesSubLbl: Label '%1,%2', Locked = true;
    begin
        EmailChoices := StrSubstNo(EmailChoicesSubLbl, Rec."Email Address", TestEmailOtherTxt);
        SelectedEmailChoice := StrMenu(EmailChoices, 2, TestEmailChoiceTxt);

        if SelectedEmailChoice = 0 then
            exit;
        if SelectedEmailChoice = 1 then
            EmailRecipient := Rec."Email Address"
        else
            if EmailUserSpecifiedAddress.RunModal() = Action::OK then
                EmailRecipient := EmailUserSpecifiedAddress.GetEmailAddress()
            else
                exit;

#if not CLEAN17
#pragma warning disable AL0432
        Email.OnGetTestEmailBody(Rec.Connector, EmailBody);
#pragma warning restore        
#endif
        Email.OnGetBodyForTestEmail(Rec.Connector, Rec."Account Id", EmailBody);

        if EmailBody = '' then
            EmailBody := StrSubstNo(TestEmailBodyTxt, UserId(), Rec.Connector);

        EmailMessage.Create(EmailRecipient, TestEmailSubjectTxt, EmailBody, true);
        if Email.Send(EmailMessage, Rec) then
            Message(StrSubstNo(TestEmailSuccessMsg, EmailRecipient))
        else
            Error(TestEmailFailedMsg);
    end;
}
