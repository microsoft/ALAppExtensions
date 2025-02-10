namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;

pageextension 6383 EDocumentListExt extends "E-Documents"
{
    layout
    {
        addafter("Entry No")
        {
            field("File Id"; Rec."File Id")
            {
                ApplicationArea = All;
                Caption = 'File Name';
                ToolTip = 'Specifies the name of the attached file';
                Visible = FileIdVisible;
                Editable = false;

                trigger OnDrillDown()
                var
                    DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
                begin
                    DriveIntegrationImpl.PreviewContent(Rec);
                end;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(ViewFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View file';
                ToolTip = 'View the source file.';
                Image = ViewDetails;
                Visible = FileIdVisible;

                trigger OnAction()
                var
                    DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
                begin
                    DriveIntegrationImpl.PreviewContent(Rec);
                end;
            }
            action(ViewMailMessage)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View e-mail message';
                ToolTip = 'View the source e-mail message.';
                Image = Email;
                Visible = EmailActionsVisible;

                trigger OnAction()
                begin
                    if (Rec."Mail Message Id" <> '') then
                        HyperLink(StrSubstNo(WebLinkTxt, Rec."Mail Message Id"))
                end;
            }
        }
        addafter(Promoted_EDocumentServices)
        {
            actionref(Promoted_ViewFile; ViewFile) { }
            actionref(Promoted_ViewMailMessage; ViewMailMessage) { }
        }
    }

    trigger OnOpenPage()
    var
        DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
        OutlookIntegrationImpl: Codeunit "Outlook Integration Impl.";
    begin
        DriveIntegrationImpl.SetConditionalVisibilityFlag(FileIdVisible);
        OutlookIntegrationImpl.SetConditionalVisibilityFlag(EmailActionsVisible);
    end;

    var
        FileIdVisible: Boolean;
        EmailActionsVisible: Boolean;
        WebLinkTxt: label 'https://outlook.office365.com/owa/?ItemID=%1&exvsurl=1&viewmodel=ReadMessageItem', Locked = true;
}