// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 137121 "Translation Test Page"
{
    PageType = Card;
    SourceTable = "Translation Test Table";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PK; PK)
                {
                    ApplicationArea = All;
                }
                field(TextField; TranslatedTextField)
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        Translation.Show(Rec, FieldNo(TextField));
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TranslatedTextField := Translation.Get(Rec, FieldNo(TextField));
    end;

    var
        Translation: Codeunit Translation;
        TranslatedTextField: Text;
}

