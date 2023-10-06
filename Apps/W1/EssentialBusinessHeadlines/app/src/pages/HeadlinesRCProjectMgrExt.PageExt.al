// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

pageextension 1443 "Headlines RC Project Mgr. Ext" extends "Headline RC Project Manager"
{

    layout
    {
        addlast(Content)
        {
            group(Headline1)
            {
                Visible = Headline1Visible;
                Editable = false;
                ShowCaption = false;

                field(Headline1Text; Headline1Text)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        OnSetVisibility(Headline1Visible, Headline1Text);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVisibility(var Headline1Visible: Boolean; var Headline1Text: Text[250])
    begin
    end;

    var
        [InDataSet]
        Headline1Visible: Boolean;
        [InDataSet]
        Headline1Text: Text[250];
}