// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Threading;

codeunit 6147 "E-Document Import Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EDocumentService: Record "E-Document Service";
        EDocImportManagement: Codeunit "E-Doc. Import";
    begin
        EDocumentService.Get(Rec."Record ID to Process");
        EDocImportManagement.ReceiveDocument(EDocumentService);
    end;
}
