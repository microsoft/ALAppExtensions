// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This page shows the target language and the translation for data in a table field.</summary>
page 3712 Translation
{
    Extensible = false;
    DataCaptionExpression = CaptionTxt;
    PageType = List;
    SourceTable = Translation;
    ContextSensitiveHelpPage = 'ui-get-ready-business';
    Permissions = tabledata Translation = rimd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LanguageName; LanguageNameValue)
                {
                    ApplicationArea = All;
                    Caption = 'Target Language';
                    ToolTip = 'The language to which the source text was translated.';

                    trigger OnAssistEdit()
                    var
                        Language: Codeunit Language;
                    begin
                        Language.LookupWindowsLanguageId("Language ID");
                        CalculateLanguageFromID();
                    end;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'The translated text.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        LanguageNameValue := '';
        Rec."Table ID" := TableId;
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateLanguageFromID();
    end;

    local procedure CalculateLanguageFromID()
    var
        Language: Codeunit Language;
    begin
        CalcFields("Language Name");
        LanguageNameValue := "Language Name";
        if LanguageNameValue = '' then
            LanguageNameValue := Language.GetWindowsLanguageName("Language ID");
    end;

    var
        TableId: Integer;
        CaptionTxt: Text;
        LanguageNameValue: Text;

    internal procedure SetTableId(Value: Integer)
    begin
        TableId := Value;
    end;

    /// <summary>
    /// Sets the page's caption.
    /// </summary>
    /// <param name="CaptionText">The caption to set.</param>
    [Scope('OnPrem')]
    procedure SetCaption(CaptionText: Text)
    begin
        CaptionTxt := CaptionText;
    end;
}

