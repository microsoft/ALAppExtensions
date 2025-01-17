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
#if not CLEANSCHEMA29
        field(11770; "XML Format CZL"; Enum "VAT Statement XML Format CZL")
        {
            Caption = 'XML Format (obsoleted)';
            DataClassification = CustomerContent;
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'Replaced by "XML Format CZL" field in VAT Statement Name table.';
        }
#endif
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

    trigger OnAfterDelete()
    begin
        if IsTemporary() then
            exit;

        DeleteCommentsAndAttachmentsCZL();
        DeleteVATAttributesCZL();
    end;

    var
        VATAttributeCodeMgtCZL: Codeunit "VAT Attribute Code Mgt. CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteCommAttachQst: Label 'This will delete all Comments/Attachments related to %1 %2. Do you want to continue?', Comment = '%1=tablecaption, %2=VAT statement template name';

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
#if not CLEAN26

    [Obsolete('Replaced by InitVATAttributesCZL function in VAT Statement Name table.', '26.0')]
    procedure InitVATAttributesCZL();
    begin
#pragma warning disable AL0432
        VATAttributeCodeMgtCZL.InitVATAttributes(Rec);
#pragma warning restore AL0432
    end;
#endif
}
