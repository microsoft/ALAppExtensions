// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Globalization;

/// <summary>This page shows the target language and the translation for data in a table field.</summary>
page 3712 Translation
{
    Extensible = false;
    DataCaptionExpression = CaptionTxt;
    PageType = List;
    SourceTable = Translation;
    ContextSensitiveHelpPage = 'ui-get-ready-business';
    Permissions = tabledata Translation = rimd;
    UsageCategory = None;

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
                    ToolTip = 'Specifies the language to which the source text was translated.';

                    trigger OnAssistEdit()
                    var
                        Language: Codeunit Language;
                    begin
                        Language.LookupWindowsLanguageId(Rec."Language ID");
                        CalculateLanguageFromID();
                    end;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the translated text.';

                    trigger OnValidate()
                    var
                        TranslationImplementation: Codeunit "Translation Implementation";
                    begin
                        if FieldLengthCheckEnabled then
                            TranslationImplementation.CheckLengthOfTranslationValue(Rec);
                    end;
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
        Rec.CalcFields("Language Name");
        LanguageNameValue := Rec."Language Name";
        if LanguageNameValue = '' then
            LanguageNameValue := Language.GetWindowsLanguageName(Rec."Language ID");
    end;

    var
        FieldLengthCheckEnabled: Boolean;
        TableId: Integer;
        CaptionTxt: Text;
        LanguageNameValue: Text;

    internal procedure SetTableId(TableNo: Integer)
    begin
        TableId := TableNo;
    end;

    internal procedure SetCheckFieldLength(CheckFieldLength: Boolean)
    begin
        FieldLengthCheckEnabled := CheckFieldLength;
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


