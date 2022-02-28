// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

pageextension 2026 "Item Picture Analyzer Ext" extends "Item Card"
{
    actions
    {
        addlast(ItemActionGroup)
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
                    ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
                    OnRecord: Option " ",Item,Contact;
                begin
                    if not ImageAnalysisSetup.Get() then begin
                        ImageAnalyzerExtMgt.SendEnableNotification("No.", OnRecord::Item);
                        exit;
                    end;
                    if not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then begin
                        ImageAnalyzerExtMgt.SendEnableNotification("No.", OnRecord::Item);
                        exit;
                    end;

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