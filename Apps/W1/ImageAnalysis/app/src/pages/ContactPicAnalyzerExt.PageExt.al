namespace Microsoft.Utility.ImageAnalysis;

using System.AI;
using Microsoft.CRM.Contact;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

pageextension 2027 "Contact Pic Analyzer Ext" extends "Contact Card"
{
    layout
    {
    }
    actions
    {
        addafter("Apply Template")
        {

            action(AnalyzePicture)
            {
                Visible = true;
                ApplicationArea = RelationshipMgmt;
                Enabled = HasPictureToAnalyze;
                Caption = 'Analyze Picture';
                ToolTip = 'Analyze the picture attached to the contact to identify gender and age, and assign them to the contact.';
                Image = Refresh;

                trigger OnAction()
                var
                    ImageAnalysisSetup: Record "Image Analysis Setup";
                    ContactPictureAnalyze: Codeunit "Contact Picture Analyze";
                    ImageAnalyzerWizard: Page "Image Analyzer Wizard";
                begin
                    if not ImageAnalysisSetup.Get() or not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then begin
                        ImageAnalyzerWizard.SetContact(Rec);
                        ImageAnalyzerWizard.RunModal();
                    end;

                    if not ImageAnalysisSetup.Get() and not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then
                        exit;

                    if Type <> Type::Person then
                        Message(ImageAnalysisForPersonsOnlyMsg);

                    ContactPictureAnalyze.AnalyzePicture(rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        HasPictureToAnalyze := Image.HasValue();
    end;

    var
        [InDataSet]
        HasPictureToAnalyze: Boolean;
        ImageAnalysisForPersonsOnlyMsg: Label 'The contact you''re analyzing a picture of is a company, not a person. The contact must be a person.';
}