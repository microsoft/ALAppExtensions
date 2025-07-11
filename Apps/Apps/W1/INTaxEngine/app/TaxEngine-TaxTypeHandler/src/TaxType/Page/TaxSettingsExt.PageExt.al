// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

using System.Environment.Configuration;

pageextension 20263 "Tax Settings Ext." extends "Advanced Settings"
{
    layout
    {
        addafter(BaseAppRow)
        {
            grid(TaxEngineAppRow)
            {
                ShowCaption = false;
                GridLayout = Rows;

                group(TaxEngine)
                {
                    InstructionalText = 'Set up and manage Tax configurations.';
                    ShowCaption = false;

                    field(TaxTypes; 'Tax Types')
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        DrillDown = true;
                        Caption = 'Tax Types';
                        ToolTip = 'Opens the Tax Types.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Tax Types");
                            CurrPage.Close();
                        end;
                    }
                }
            }
        }
    }
}
