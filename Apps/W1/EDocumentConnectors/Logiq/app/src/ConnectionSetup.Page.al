// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

page 6430 "Connection Setup"
{
    Caption = 'Logiq Connection Setup';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    SourceTable = "Connection Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(ClientID; Rec."Client ID")
                {
                    ShowMandatory = true;
                }
                field(ClientSecret; this.ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.LogiqAuth.SetIsolatedStorageValue(Rec."Client Secret", this.ClientSecret);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                }
                field("Base URL"; Rec."Base URL")
                {
                }
                field("File List Endpoint"; Rec."File List Endpoint")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Connect)
            {
                ApplicationArea = All;
                Caption = 'User Setup';
                Image = Setup;
                ToolTip = 'Open page for User Setup.';

                trigger OnAction()
                var
                    LogiqConnectionUserSetup: Record "Connection User Setup";
                    LoqiqConnectionUserSetupPage: Page "Connection User Setup";
                begin
                    LogiqConnectionUserSetup.FindUserSetup(UserSecurityId());
                    LoqiqConnectionUserSetupPage.SetRecord(LogiqConnectionUserSetup);
                    LoqiqConnectionUserSetupPage.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Connect_Promoted; Connect)
            {
            }
        }
    }

    var
        LogiqAuth: Codeunit Auth;
        [NonDebuggable]
        ClientSecret: Text;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;

        if this.LogiqAuth.HasToken(Rec."Client Secret", DataScope::Company) then
            this.ClientSecret := '*';
    end;
}
