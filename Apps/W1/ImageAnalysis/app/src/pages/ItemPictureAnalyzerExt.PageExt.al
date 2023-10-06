namespace Microsoft.Utility.ImageAnalysis;

using Microsoft.Inventory.Item;
using System.AI;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

pageextension 2026 "Item Picture Analyzer Ext" extends "Item Card"
{
    actions
    {
        addlast(Functions)
        {
            action(AnalyzePicture)
            {
                Visible = true;
                ApplicationArea = Basic, Suite;
                Enabled = HasPicture;
                Caption = 'Analyze Picture';
                ToolTip = 'Analyze the picture attached to the item to identify attributes and item category, and assign them to the item.';
                Image = Refresh;

                trigger OnAction()
                var
                    ImageAnalysisSetup: Record "Image Analysis Setup";
                    ItemAttrPopulate: Codeunit "Item Attr Populate";
                    ImageAnalyzerWizard: Page "Image Analyzer Wizard";
                begin
                    if not ImageAnalysisSetup.Get() or not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then begin
                        ImageAnalyzerWizard.SetItem(Rec);
                        ImageAnalyzerWizard.RunModal();
                    end;

                    if not ImageAnalysisSetup.Get() or not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then
                        exit;

                    ItemAttrPopulate.AnalyzePicture(rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        HasPicture := Picture.Count() = 1;
    end;

    var
        [InDataSet]
        HasPicture: Boolean;
}