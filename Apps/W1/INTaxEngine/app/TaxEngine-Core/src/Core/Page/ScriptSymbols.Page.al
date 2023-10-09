// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.Core;

page 20131 "Script Symbols"
{
    Caption = 'Symbols';
    PageType = List;
    SourceTable = "Script Symbol";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the Symbol.';
                }
                field(Datatype; Datatype)
                {
                    Caption = 'Datatype';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the datatype of the Symbol.';
                }
            }
        }
    }
}
