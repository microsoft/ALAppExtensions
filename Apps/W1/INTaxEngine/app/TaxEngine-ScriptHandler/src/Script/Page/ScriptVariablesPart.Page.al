// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.ScriptHandler;

page 20204 "Script Variables Part"
{
    Caption = 'Variables';
    DataCaptionExpression = Name;
    PageType = StandardDialog;
    SourceTable = "Script Variable";
    MultipleNewLines = true;
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of variable.';
                }
                field(Datatype; Datatype)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the data type of variable.';
                }
            }
        }
    }
}
