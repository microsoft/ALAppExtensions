// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

/// <summary>
/// Page for viewing settings for Azure OpenAI.
/// </summary>
page 2010 "Azure OpenAi Settings"
{
    ApplicationArea = All;
    Caption = 'Azure OpenAI Settings';
    AdditionalSearchTerms = 'OpenAI,AI';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    Extensible = false;
    SourceTable = "Azure OpenAi Settings";

    layout
    {
        area(content)
        {
            group(settings)
            {
                ShowCaption = false;

                field(Endpoint; Rec.Endpoint)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint to use.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field(Model; Rec.Model)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the model to use.';
                }

                field(Secret; Secret)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the secret to connect to the endpoint.';
                    Caption = 'Secret';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        Rec.SetSecret(Secret);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        if not Rec.Get() then
            Rec.SetDefaults();
    end;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.SetDefaults();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.HasSecret() then
            Secret := SecretPlaceholderLbl
        else
            Clear(Secret);
    end;

    var
        Secret: Text;
        SecretPlaceholderLbl: Label '***', Locked = true;
}