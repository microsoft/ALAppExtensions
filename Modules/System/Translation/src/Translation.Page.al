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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LanguageName; LanguageName)
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
        LanguageName := '';
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
        LanguageName := "Language Name";
        if LanguageName = '' then
            LanguageName := Language.GetWindowsLanguageName("Language ID");
    end;

    var
        CaptionTxt: Text;
        LanguageName: Text;

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

