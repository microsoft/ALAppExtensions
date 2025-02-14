// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Telemetry;
using System.Email;

page 6384 "Outlook Setup"
{
    Permissions = tabledata "Outlook Setup" = rim,
                  tabledata "Email Account" = r;
    ApplicationArea = Basic, Suite;
    Caption = 'Outlook Document Import Setup';
    PageType = StandardDialog;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "Outlook Setup";
    UsageCategory = Administration;
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(content)
        {
            group(Status)
            {
                Caption = ' ';
                ShowCaption = false;

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies is the document import enabled.';
                }
            }
            group(General)
            {
                Caption = 'Mailbox Details';
                InstructionalText = 'Specify the e-mail address of the Microsoft 365 mailbox in which you receive document attachments. You must have read and write access to the specified mailbox, and it must be in the same tenant in which your Businesss Central environment is hosted.';

                field(Mailbox; MailboxName)
                {
                    Caption = 'Account';
                    ToolTip = 'Specifies the Microsoft 365 mailbox from which to download document attachments.';
                    Editable = false;
                    ShowMandatory = true;

                    trigger OnAssistEdit()
                    var
                        EmailAccounts: Page "Email Accounts";
                    begin
                        if Rec.Enabled then
                            Error(DisableToConfigErr);

                        if not CheckMailboxExists() then
                            Page.RunModal(Page::"Email Account Wizard");

                        if not CheckMailboxExists() then
                            exit;
                        EmailAccounts.EnableLookupMode();
                        EmailAccounts.FilterConnectorV3Accounts(true);
                        if EmailAccounts.RunModal() = Action::LookupOK then begin
                            EmailAccounts.GetAccount(TempEmailAccount);
                            TempOutlookSetup."Email Account ID" := TempEmailAccount."Account Id";
                            TempOutlookSetup."Email Connector" := TempEmailAccount.Connector;
                            if Format(TempOutlookSetup."Email Connector") <> M365Lbl then
                                Error(M365MailboxMustBeSpecifiedErr);
                        end;

                        if MailboxName <> TempEmailAccount."Email Address" then begin
                            MailboxName := TempEmailAccount."Email Address";
                            ConfigUpdated();
                            Rec."Email Account ID" := TempEmailAccount."Account Id";
                            Rec."Email Connector" := TempEmailAccount.Connector;
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        ConfigUpdated();
                    end;
                }
                field(LastSync; LastSync)
                {
                    Caption = 'Last sync';
                    ToolTip = 'Specifies the date and time of the last sync with the mailbox.';
                    Editable = false;
                    Visible = ShowLastSync;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TempEmailAccountLocal: Record "Email Account" temporary;
        EmailAccount: Codeunit "Email Account";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DriveProcessing: Codeunit "Drive Processing";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
            FeatureTelemetry.LogUptake('0000OGX', DriveProcessing.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
            FeatureTelemetry.LogUsage('0000OGY', DriveProcessing.FeatureName(), 'Outlook');
        end;

        if not IsNullGuid(Rec."Email Account ID") then begin
            EmailAccount.GetAllAccounts(false, TempEmailAccountLocal);
            TempEmailAccountLocal.SetRange("Account Id", Rec."Email Account ID");
            TempEmailAccountLocal.SetRange(Connector, Rec."Email Connector");
            if TempEmailAccountLocal.FindFirst() then
                MailboxName := TempEmailAccountLocal."Email Address";
        end;

        UpdateBasedOnEnable();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Rec.Enabled then
            if not Confirm(StrSubstNo(EnableServiceQst, CurrPage.Caption), true) then
                exit(false);
    end;

    local procedure CheckMailboxExists(): Boolean
    var
        EmailAccounts: Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        IConnector: Interface "Email Connector";
    begin
        EmailAccount.GetAllAccounts(false, EmailAccounts);
        if EmailAccounts.IsEmpty() then
            exit(false);

        repeat
            IConnector := EmailAccounts.Connector;
            if IConnector is "Email Connector v3" then
                exit(true);
        until EmailAccounts.Next() = 0;
    end;

    local procedure ConfigUpdated()
    begin
        if not CheckIsValidConfig() then
            Error(MailboxMustBeSpecifiedErr);
    end;

    local procedure CheckIsValidConfig(): Boolean
    begin
        exit(MailboxName <> '');
    end;

    var
        TempEmailAccount: Record "Email Account" temporary;
        TempOutlookSetup: Record "Outlook Setup" temporary;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = page caption';
        DisableToConfigErr: Label 'You must disable the setup before making changes to the configuration.';
        MailboxMustBeSpecifiedErr: label 'You must specify the e-mail address of the Microsoft 365 mailbox in which you receive e-mails with document attachments.';
        M365MailboxMustBeSpecifiedErr: label 'You must specify a Microsoft 365 mailbox.', Comment = 'Microsoft 365 is a name of a range of Microsoft offerings - do not translate it';
        M365Lbl: label 'Microsoft 365', Locked = true;
        MailboxName: Text;
        LastSync: Text;
        ShowLastSync: Boolean;

    local procedure UpdateBasedOnEnable()
    begin
        ShowLastSync := CheckIsValidConfig() and (TempOutlookSetup."Last Sync At" <> 0DT);
    end;

}

