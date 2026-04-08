// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.Email;
using System.Environment;
using System.Telemetry;

/// <summary>
/// This codeunit is used to implement the demo guide functionality.
/// </summary>
codeunit 3309 "PA Demo Guide"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Returns true if the demo experience is available for the current company.
    /// </summary>
    /// <returns>Returns true if the demo experience is available for the current company</returns>
    procedure DemoExperienceAvailable(): Boolean
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(Company."Evaluation Company");
    end;

    /// <summary>
    /// Opens the demo guide page.
    /// </summary>
    procedure OpenGuidePage()
    var
        PADemoGuidePage: Page "PA Demo Guide";
    begin
        PADemoGuidePage.Run();
    end;

#if not CLEAN28
    /// <summary>
    /// Creates demo files to use for the demo email when the agent is enabled.
    /// </summary>
    [Obsolete('Demo files are created during the evaluation company creation', '28.0')]
    procedure CreateDemoFilesForEmail()
    begin
    end;
#endif

    /// <summary>
    /// Sends a demo email using the active PA setup configuration.
    /// </summary>
    procedure SendDemoEmail()
    var
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
    begin
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        SendDemoEmail(PASetupConfiguration);
    end;

    /// <summary>
    /// Sends a demo email using the provided PA setup configuration.
    /// </summary>
    /// <param name="PASetupConfiguration">An email account to send a demo email</param>
    procedure SendDemoEmail(PASetupConfiguration: Codeunit "PA Setup Configuration");
    var
        EDocSamplePurchInvFile: Record "E-Doc Sample Purch. Inv File";
        TempEmailAccount: Record "Email Account";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Telemetry: Codeunit Telemetry;
        FileInStream: InStream;
        EmailNotSentErr: Label 'The email has not been sent. Error: %1.', Comment = '%1 - error message from the email management codeunit';
        EmailSendingFailedErr: Label 'Email sending failed: %1.\\Verify that you have access to send emails from %2', Comment = '%1 - error message from the email management codeunit, %2 = sender email address';
        SubjectTxt: Label 'Sample email from Payables Agent', MaxLength = 255, Comment = 'Payables Agent is a term, and should not be translated.';
        BodyTextTxt: Label 'This is a sample email from Payables Agent.', MaxLength = 255, Comment = 'Payables Agent is a term, and should not be translated.';
    begin
        if not DemoExperienceAvailable() then
            exit;
        if not CanSendDemoEmail(PASetupConfiguration) then
            exit;
        EDocSamplePurchInvFile.SetRange("Send By Email", true);
        if EDocSamplePurchInvFile.IsEmpty() then
            exit;
        TempEmailAccount := PASetupConfiguration.GetEmailAccount();

        EmailMessage.Create(TempEmailAccount."Email Address", SubjectTxt, BodyTextTxt, true);
        EDocSamplePurchInvFile.FindSet();
        repeat
            EDocSamplePurchInvFile.CalcFields("File Content");
            EDocSamplePurchInvFile."File Content".CreateInStream(FileInStream);
            EmailMessage.AddAttachment(EDocSamplePurchInvFile."File Name", 'application/pdf', FileInStream);
        until EDocSamplePurchInvFile.Next() = 0;

        ClearLastError();
        if not Email.Send(EmailMessage, TempEmailAccount) then begin
            Telemetry.LogMessage('0000PJW', StrSubstNo(EmailNotSentErr, GetLastErrorText()), Verbosity::Warning, DataClassification::SystemMetadata);
            error(EmailSendingFailedErr, GetLastErrorText(), TempEmailAccount."Email Address");
        end;
        EDocSamplePurchInvFile.SetRange("Send By Email");
        EDocSamplePurchInvFile.ModifyAll("Send By Email", false);
    end;

    /// <summary>
    /// Gets the count of the demo files to download.
    /// </summary>
    /// <returns>Count of demo files</returns>
    procedure GetDemoFilesToDownloadCount(): Integer
    var
        EDocSamplePurchInvFile: Record "E-Doc Sample Purch. Inv File";
    begin
        exit(EDocSamplePurchInvFile.Count());
    end;

    /// <summary>
    /// Shows the page with the demo files available for download.
    /// </summary>
    procedure ShowDemoFilesToDownload()
    begin
        Page.Run(Page::"E-Doc Sample Purch. Inv. Files");
    end;

#if not CLEAN28
#pragma warning disable AL0432
    /// <summary>
    /// Downloads the selected demo file.
    /// </summary>
    /// <param name="PADemoFile">Selected demo file</param>
    [Obsolete('Sample files are now downloaded from E-Doc Sample Purch. Inv. Files page', '28.0')]
    procedure DownloadDemoFile(PADemoFile: Record "PA Demo File")
    begin
    end;
#pragma warning restore AL0432
#endif

    local procedure CanSendDemoEmail(PASetupConfiguration: Codeunit "PA Setup Configuration"): Boolean
    begin
        if PASetupConfiguration.GetAgentSetupBuffer().State = PASetupConfiguration.GetAgentSetupBuffer().State::Disabled then
            exit(false);
        if not PASetupConfiguration.GetPayablesAgentSetup()."Monitor Outlook" then
            exit(false);
        if IsNullGuid(PASetupConfiguration.GetEmailAccount()."Account Id") then
            exit(false);
        exit(true);
    end;
}