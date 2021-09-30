// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

pageextension 2025 "Image Analysis Setup Ext" extends "Image Analysis Setup"
{
    layout
    {
        addbefore("Api Uri")
        {
            field("Enable Image-Based Attribute Recognition"; "Image-Based Attribute Recognition Enabled")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to use the Image Analyzer extension to suggest attributes that it detects in images of items and contact persons.';

                trigger OnValidate()
                var
                    ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
                    DummyNotification: Notification;
                begin
                    if "Image-Based Attribute Recognition Enabled" then begin
                        "Image-Based Attribute Recognition Enabled" := false;
                        Modify();
                        Commit();
                        ImageAnalyzerExtMgt.OpenSetupWizard(DummyNotification);
                        Rec.Get();
                        CurrPage.Update();
                    end;
                end;
            }

            field("Confidence Threshold"; "Confidence Threshold")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the confidence score threshold for results from Microsoft Cognitive Services. Results with confidence below the threshold are considered inaccurate, and are not used. A typical threshold is 80%.';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(ViewBlacklistedTags)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View Blocked Attributes';
                Enabled = True;
                Visible = True;
                Image = Approvals;
                Promoted = true;
                PromotedIsBig = True;
                PromotedCategory = Process;
                ToolTip = 'View attributes that are currently blocked.';

                trigger OnAction()
                var
                    ImageAnalysisBlacklist: Page "Image Analysis Blacklist";
                begin
                    ImageAnalysisBlacklist.RunModal();
                end;
            }
        }
    }
}
