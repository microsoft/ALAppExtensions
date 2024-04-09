// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

tableextension 11748 "VAT Statement Template CZL" extends "VAT Statement Template"
{
    fields
    {
        field(11770; "XML Format CZL"; Enum "VAT Statement XML Format CZL")
        {
            Caption = 'XML Format';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if ("XML Format CZL" <> xRec."XML Format CZL") then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(YouChangedXMLFormatQst, FieldCaption("XML Format CZL"), "XML Format CZL", TableCaption, Name), true) then begin
                        DeleteVATAttributesCZL();
                        InitVATAttributesCZL();
                    end;
            end;
        }
        field(11771; "Allow Comments/Attachments CZL"; Boolean)
        {
            Caption = 'Allow Comments/Attachments';
            InitValue = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "Allow Comments/Attachments CZL" then
                    if not ConfirmManagement.GetResponse(StrSubstNo(DeleteCommAttachQst, TableCaption, Name), false) then
                        "Allow Comments/Attachments CZL" := true
                    else
                        DeleteCommentsAndAttachmentsCZL();
            end;
        }
    }
    var
        VATAttributeCodeMgtCZL: Codeunit "VAT Attribute Code Mgt. CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteCommAttachQst: Label 'This will delete all Comments/Attachments related to %1 %2. Do you want to continue?', Comment = '%1=tablecaption, %2=VAT statement template name';
        YouChangedXMLFormatQst: Label 'You have changed XML format.\\Do you want to initialize %1: "%2" default VAT attributes for %3 %4?', Comment = '%1=fieldcaption, %2=VAT statement XML format, %3=tablecaption, %4=VAT statement template name';

    procedure DeleteCommentsAndAttachmentsCZL()
    var
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        VATStatementCommentLineCZL.SetRange("VAT Statement Template Name", Name);
        VATStatementCommentLineCZL.DeleteAll();
        VATStatementAttachmentCZL.SetRange("VAT Statement Template Name", Name);
        VATStatementAttachmentCZL.DeleteAll();
    end;

    procedure DeleteVATAttributesCZL()
    begin
        VATAttributeCodeMgtCZL.DeleteVATAttributes(Rec);
    end;

    procedure InitVATAttributesCZL();
    begin
        VATAttributeCodeMgtCZL.InitVATAttributes(Rec);
    end;
}
