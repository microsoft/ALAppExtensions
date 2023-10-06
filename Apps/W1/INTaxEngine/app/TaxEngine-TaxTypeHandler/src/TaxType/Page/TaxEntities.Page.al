// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 20247 "Tax Entities"
{
    PageType = List;
    SourceTable = "Tax Entity";
    SourceTableView = sorting("Entity Type");
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of table which will be used in tax computation of this tax type.';
                }

                field("Entity Type"; "Entity Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of this table.';
                }
            }
        }
    }
}
