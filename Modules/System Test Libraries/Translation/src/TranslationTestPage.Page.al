// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Globalization;

using System.Globalization;

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
                field(PK; Rec.PK)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the primary key.';
                }
                field(TextField; TranslatedTextField)
                {
                    ApplicationArea = All;
                    Caption = 'Text field';
                    ToolTip = 'Specifies the translated value.';

                    trigger OnAssistEdit()
                    begin
                        Translation.Show(Rec, Rec.FieldNo(TextField));
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TranslatedTextField := Translation.Get(Rec, Rec.FieldNo(TextField));
    end;

    var
        Translation: Codeunit Translation;
        TranslatedTextField: Text;
}


