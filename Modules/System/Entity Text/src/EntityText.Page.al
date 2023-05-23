// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The fallback edit page shown if the OnEditEntityText is not handled.
/// Uses the "Entity Text Part" to render the rich text editor.
/// </summary>
page 2013 "Entity Text"
{
    ApplicationArea = All;
    Caption = 'Entity Text';
    DelayedInsert = true;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    Extensible = false;
    SourceTable = "Entity Text";
    DataCaptionExpression = '';

    layout
    {
        area(content)
        {
            field(TextFormat; TextFormat)
            {
                Caption = 'Text format';
                ApplicationArea = All;
                ToolTip = 'Specifies the format of the suggested text.';

                trigger OnValidate()
                begin
                    CurrPage.EntityTextPart.Page.SetTextFormat(TextFormat);
                end;
            }

            field(Tone; Tone)
            {
                Caption = 'Tone of text';
                ApplicationArea = All;
                ToolTip = 'Specifies the tone of text to use in the suggested text.';

                trigger OnValidate()
                begin
                    CurrPage.EntityTextPart.Page.SetTextTone(Tone);
                end;
            }

            group(EntityTextGroup)
            {
                ShowCaption = false;

                part(EntityTextPart; "Entity Text Part")
                {
                    ApplicationArea = All;
                    Caption = 'Content';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        EntityTextModuleInfo: ModuleInfo;
        CallerModuleInfo: ModuleInfo;
    begin
        TextFormat := "Entity Text Format"::TaglineParagraph;
        Tone := "Entity Text Tone"::Inspiring;

        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        if CallerModuleInfo.Id() <> EntityTextModuleInfo.Id() then
            Error(InvalidAppErr);
    end;

    trigger OnAfterGetCurrRecord()
    var
        EntityText: Codeunit "Entity Text";
        EntityTextImpl: Codeunit "Entity Text Impl.";
        Facts: Dictionary of [Text, Text];
        Handled: Boolean;
    begin
        if IsNullGuid(Rec."Source System Id") then
            exit;

        EntityText.OnRequestEntityContext(Rec."Source Table Id", Rec."Source System Id", Rec.Scenario, Facts, Tone, TextFormat, Handled);

        CurrPage.EntityTextPart.Page.SetContext(EntityTextImpl.GetText(Rec), Facts, Tone, TextFormat);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> Action::LookupOK then
            exit(true);

        CurrPage.EntityTextPart.Page.UpdateRecord(Rec);
        Rec.Modify();
    end;

    internal procedure SetModuleInfo(CurrentModuleInfo: ModuleInfo)
    begin
        CurrPage.EntityTextPart.Page.SetModuleInfo(CurrentModuleInfo);
    end;

    var
        Tone: Enum "Entity Text Tone";
        TextFormat: Enum "Entity Text Format";
        InvalidAppErr: Label 'The Entity Text page could not be opened as it cannot be opened from another extension.';

}
