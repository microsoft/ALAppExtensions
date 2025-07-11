// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 20235 "Tax Attributes Factbox"
{
    Caption = 'Attributes';
    PageType = ListPart;
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;
    SourceTable = "Tax Attribute Value";

    layout
    {
        area(Content)
        {
            repeater(Group2)
            {
                field(Attribute; "Attribute Name")
                {
                    Caption = 'Attribute';
                    Visible = TranslatedValuesVisible;
                    ToolTip = 'Specifies the name of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
                field(Value; Value)
                {
                    Caption = 'Value';
                    Visible = TranslatedValuesVisible;
                    ToolTip = 'Specifies the value of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
                field(RawValue; Value)
                {
                    Caption = 'Value';
                    Visible = not TranslatedValuesVisible;
                    ToolTip = 'Specifies the value of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    var
        TranslatedValuesVisible: Boolean;

    trigger OnOpenPage();
    begin
        SETAUTOCALCFIELDS("Attribute Name");
        TranslatedValuesVisible := CurrentClientType() <> CLIENTTYPE::Phone;
    end;
}
