// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

page 4407 "SOA Email Template"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Edit mail signature';
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;
    layout
    {
        area(Content)
        {
            group(EmailTemplateGroup)
            {
                Caption = 'Edit mail signature';

                field(EmailSignature; EmailSignatureAsText)
                {
                    Caption = 'Type or paste the text that the agent uses as mail signature:';
                    ToolTip = 'Specifies the email signature for the Sales Order Agent.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ValueUpdated := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::Yes, Action::LookupOK] then
            SetNewEmailTemplateAsTxt();
    end;

    local procedure SetNewEmailTemplateAsTxt()
    var
        SOAOutputMessageSetup: Codeunit "SOA Output Message Setup";
    begin
        SOAOutputMessageSetup.CheckSignature(EmailSignatureAsText); // Check input contains no harmful content
        NewEmailSignatureAsText := EmailSignatureAsText;
        ValueUpdated := true;
    end;

    internal procedure SetCurrentSignatureAsTxt(CurrentEmailSignatureAsText: Text)
    begin
        EmailSignatureAsText := CurrentEmailSignatureAsText;
        NewEmailSignatureAsText := CurrentEmailSignatureAsText;
    end;

    internal procedure IsValueUpdated(): Boolean
    begin
        exit(ValueUpdated);
    end;

    internal procedure GetNewSignatureAsTxt(): Text
    begin
        exit(NewEmailSignatureAsText);
    end;

    var
        EmailSignatureAsText: Text;
        NewEmailSignatureAsText: Text;
        ValueUpdated: Boolean;
}