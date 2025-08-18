namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;

pageextension 6383 EDocumentListExt extends "E-Documents"
{
    actions
    {
        addlast(Processing)
        {
            action(ViewMailMessage)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View e-mail message';
                ToolTip = 'View the source e-mail message.';
                Image = Email;
                Visible = EmailActionsVisible;

                trigger OnAction()
                var
                    OutlookIntegrationImpl: Codeunit "Outlook Integration Impl.";
                begin
                    if (Rec."Outlook Mail Message Id" <> '') then
                        HyperLink(StrSubstNo(OutlookIntegrationImpl.WebLinkText(), Rec."Outlook Mail Message Id"))
                end;
            }
        }
        addafter(Promoted_ViewFile)
        {
            actionref(Promoted_ViewMailMessage; ViewMailMessage) { }
        }
    }

    trigger OnOpenPage()
    var
        OutlookIntegrationImpl: Codeunit "Outlook Integration Impl.";
    begin
        OutlookIntegrationImpl.SetConditionalVisibilityFlag(Rec, EmailActionsVisible);
    end;

    var
        EmailActionsVisible: Boolean;
}