// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                field("Language Name"; "Language Name")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        Language: Codeunit Language;
                    begin
                        Language.LookupWindowsLanguageId("Language ID");
                        if "Language ID" <> xRec."Language ID" then
                            CalcFields("Language Name");
                    end;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        CaptionTxt: Text;

    [Scope('OnPrem')]
    procedure SetCaption(CaptionText: Text)
    begin
        CaptionTxt := CaptionText;
    end;
}

