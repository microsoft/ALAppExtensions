// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

/// <summary>
/// E-Document Error Status
/// </summary>
codeunit 6106 "E-Doc Error Status" implements IEDocumentStatus
{
    procedure GetEDocumentStatus(): Enum "E-Document Status"
    begin
        exit(Enum::"E-Document Status"::Error);
    end;
}