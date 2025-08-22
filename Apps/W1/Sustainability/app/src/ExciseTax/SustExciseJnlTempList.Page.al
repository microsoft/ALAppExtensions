// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

page 6265 "Sust. Excise Jnl. Temp. List"
{
    Caption = 'Excise Journal Template List';
    Editable = false;
    PageType = List;
    SourceTable = "Sust. Excise Journal Template";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;
    Description = 'Used when more than one Template is available. Selection is required when open the Sustainability Excise Journal.';

    layout
    {
        area(Content)
        {
            repeater(repeater)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the sustainability excise journal template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the sustainability excise journal template.';
                }
            }
        }
    }
}