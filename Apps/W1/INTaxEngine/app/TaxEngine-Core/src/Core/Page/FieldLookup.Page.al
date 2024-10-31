// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.Core;

using System.Reflection;

page 20130 "Field Lookup"
{
    PageType = List;
    SourceTable = Field;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the field.';
                }
                field(FieldName; FieldName)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field name of the table.';
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Datatype of the field.';
                }
            }
        }
    }
}
