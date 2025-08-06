// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

page 6430 "Logiq Connection Setup"
{
    Caption = 'Logiq Connection Setup';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    SourceTable = "Logiq Connection Setup";
    Extensible = false;

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
                        IsolatedStorage.Set(this.LogiqAuth.GetConnectionSetupClientSecretKey(), this.ClientSecret, DataScope::Company);
                    end;
                }
                field(Environment; Rec.Environment)
                {
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
                    LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
                    LoqiqConnectionUserSetupPage: Page "Logiq Connection User Setup";
                begin
                    LogiqConnectionUserSetup.FindUserSetup(CopyStr(UserId(), 1, 50));
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
        LogiqAuth: Codeunit "Logiq Auth";
        [NonDebuggable]
        ClientSecret: Text;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;

        if this.LogiqAuth.HasToken(this.LogiqAuth.GetConnectionSetupClientSecretKey(), DataScope::Company) then
            this.ClientSecret := '*';
    end;
}
