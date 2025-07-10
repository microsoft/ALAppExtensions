// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.eServices.EDocument;

pageextension 13915 "E-Document Service DE" extends "E-Document Service"
{
    layout
    {
#if not CLEAN27
        addafter(ImportParamenters)
        {
#pragma warning disable AS0125
            group(Export)
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Rearranging the fields.';
                ObsoleteTag = '27.0';
#else
        addlast(ExportProcessing)
        {
            group(BuyerReference)
            {
                ShowCaption = false;
#endif
                field("Buyer Reference Mandatory"; Rec."Buyer Reference Mandatory")
                {
                    ApplicationArea = All;
                }
                field("Buyer Reference"; Rec."Buyer Reference")
                {
                    ApplicationArea = All;
                }
            }
#pragma warning restore AS0125
        }
        modify("Export Format")
        {
            trigger OnBeforeValidate()
            var
                PeppolFormatErr: Label 'For Germany, please use format %1, as the selected format isn''t applicable.', Comment = '%1 = "PEPPOL BIS 3.0 DE"';
            begin
                if Rec."Document Format" = Rec."Document Format"::"PEPPOL BIS 3.0" then
                    Message(PeppolFormatErr, Format(Rec."Document Format"::"PEPPOL BIS 3.0 DE"));
            end;

            trigger OnAfterValidate()
            begin
                IsParameterVisible := Rec."Document Format" in [Rec."Document Format"::"PEPPOL BIS 3.0 DE", Rec."Document Format"::XRechnung, Rec."Document Format"::ZUGFeRD]
            end;
        }

        modify(Parameters)
        {
            Visible = IsParameterVisible;
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsParameterVisible := Rec."Document Format" in [Rec."Document Format"::"PEPPOL BIS 3.0 DE", Rec."Document Format"::XRechnung, Rec."Document Format"::ZUGFeRD];
    end;

    var
        IsParameterVisible: Boolean;
}