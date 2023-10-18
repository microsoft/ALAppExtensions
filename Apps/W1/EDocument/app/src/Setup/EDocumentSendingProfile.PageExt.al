// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.Automation;
using System.Telemetry;

pageextension 6101 "E-Document Sending Profile" extends "Document Sending Profile"
{
    layout
    {
        modify("Electronic Document")
        {
            Visible = ElectronicDocumentVisible;
        }

        modify(Control18)
        {
            Visible = Rec."Electronic Document" = Rec."Electronic Document"::"Through Document Exchange Service";
        }

        addafter("Electronic Document")
        {
            group(EDocumentFlow)
            {
                ShowCaption = false;
                Visible = Rec."Electronic Document" = Rec."Electronic Document"::"Extended E-Document Service Flow";

                field("EDocument Service Flow"; Rec."Electronic Service Flow")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Electronic Document Service Flow Code';
                    ToolTip = 'Specifies Electronic Service FLow that is used for sending documents.';

                    trigger OnValidate()
                    var
                        Workflow: Record Workflow;
                        FeatureTelemetry: Codeunit "Feature Telemetry";
                        EDocumentHelper: Codeunit "E-Document Processing";
                    begin
                        if Workflow.Get(Rec."Electronic Service Flow") then
                            FeatureTelemetry.LogUptake('0000KZ5', EDocumentHelper.GetEDocTok(), Enum::"Feature Uptake Status"::"Set Up");
                    end;
                }
            }
        }
    }
    var
        ElectronicDocumentVisible: Boolean;

    trigger OnOpenPage()
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        EDocumentFormat: Record "E-Document Service";
    begin
        ElectronicDocumentVisible := not ElectronicDocumentFormat.IsEmpty() or not EDocumentFormat.IsEmpty();
    end;
}
