﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

#pragma warning disable AL0432
codeunit 11780 "VAT Stmt. Template Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnAfterInsertEvent', '', false, false)]
    local procedure InitializeVATAttributesOnAfterInsert(var Rec: Record "VAT Statement Template")
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.InitVATAttributesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteCommentsAndAttachmentsOnAfterDeleteVATStatementTemplate(var Rec: Record "VAT Statement Template")
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.DeleteCommentsAndAttachmentsCZL();
        Rec.DeleteVATAttributesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Template", 'OnAfterValidateEvent', 'Page ID', false, false)]
    local procedure UpdateVATStatementReportIDOnAfterValidatePageID(var Rec: Record "VAT Statement Template"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = 0 then
            if Rec."VAT Statement Report ID" = Report::"VAT Statement" then
                Rec."VAT Statement Report ID" := Report::"VAT Statement CZL";
    end;
}
