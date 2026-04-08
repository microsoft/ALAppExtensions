// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Agents;
using System.Email;

page 3305 "PA Agent Email Task"
{
    Caption = 'Email Task';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Agent Task Message";
    DataCaptionExpression = GetCaption();
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(Email)
            {
                Caption = 'Header';
                field(EmailFrom; EmailFrom)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'From';
                    ToolTip = 'Specifies the sender of the email.';
                }
                field(EmailSubject; EmailSubject)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Subject';
                    ToolTip = 'Specifies the subject of the email.';
                }

            }
            group(EmailContentGroup)
            {
                Caption = 'Body';
                field(EmailContent; EmailContent)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewMailMessage)
            {
                ApplicationArea = All;
                Caption = 'View e-mail message';
                ToolTip = 'View the source e-mail message.';
                Image = Email;

                trigger OnAction()
                var
                    OutlookIntegrationImpl: Codeunit "Outlook Integration Impl.";
                begin
                    if (EDocument."Outlook Mail Message Id" <> '') then
                        HyperLink(StrSubstNo(OutlookIntegrationImpl.WebLinkText(), EDocument."Outlook Mail Message Id"));
                end;
            }
            action(ViewFile)
            {
                ApplicationArea = All;
                Caption = 'View pdf';
                ToolTip = 'View the received pdf.';
                Image = ViewDetails;
                Visible = ViewPDFVisible;

                trigger OnAction()
                begin
                    EDocument.ViewSourceFile();
                end;
            }
        }
        area(Promoted)
        {
            actionref(ViewMailMessage_Promoted; ViewMailMessage)
            {
            }
            actionref(ViewFile_Promoted; ViewFile)
            { }
        }
    }

    var
        EDocument: Record "E-Document";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EmailSubject: Text;
        EmailFrom: Text;
        EmailContent: Text;
        ViewPDFVisible: Boolean;
        PDFReceivedFromEmailTxt: label 'Email received with PDF attachment';
        NoPDFReceivedFromEmailTxt: label 'Email received without PDF attachment';

    trigger OnAfterGetCurrRecord()
    var
        EmailMessage: Codeunit "Email Message";
        EntryNo: Integer;
    begin
        if Evaluate(EntryNo, Rec."External ID") then;
        if not EDocument.Get(EntryNo) then;
        if not EDocDataStorage.Get(EDocument."Unstructured Data Entry No.") then;
        EmailMessage.Get(EDocument."Mail Message Id");
        EmailFrom := EDocument."Source Details";
        EmailContent := EmailMessage.GetBody();
        EmailSubject := EDocument."Additional Source Details";
        ViewPDFVisible := EDocDataStorage."File Format" = Enum::"E-Doc. File Format"::PDF;
    end;

    local procedure GetCaption(): Text[250]
    var
        EntryNo: Integer;
    begin
        if not Evaluate(EntryNo, Rec."External ID") then
            exit(NoPDFReceivedFromEmailTxt);

        if not EDocument.Get(EntryNo) then
            exit(NoPDFReceivedFromEmailTxt);

        if EDocument."Unstructured Data Entry No." = 0 then
            exit(NoPDFReceivedFromEmailTxt);

        if not EDocDataStorage.Get(EDocument."Unstructured Data Entry No.") then
            exit(NoPDFReceivedFromEmailTxt);

        if EDocDataStorage."File Format" = Enum::"E-Doc. File Format"::PDF then
            exit(PDFReceivedFromEmailTxt)
        else
            exit(NoPDFReceivedFromEmailTxt);
    end;

}