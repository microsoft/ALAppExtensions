// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Default implementations for E-Document interfaces.
/// </summary>
codeunit 6116 "E-Doc. Default Implementation" implements IEDocumentFinishDraft
{
    Access = Internal;

    procedure ApplyDraftToBC(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): RecordId
    var
        NoMethodSpecifiedErr: Label 'The E-Document type %1 is not supported.', Comment = '%1 - Document type';
    begin
        Error(NoMethodSpecifiedErr, EDocument."Document Type");
    end;

    procedure RevertDraftActions(EDocument: Record "E-Document")
    begin
    end;
}