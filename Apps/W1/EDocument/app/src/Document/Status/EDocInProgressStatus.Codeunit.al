// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

/// <summary>
/// E-Document In Progress Status
/// </summary>
codeunit 6107 "E-Doc In Progress Status" implements IEDocumentStatus
{
    procedure GetEDocumentStatus(): Enum "E-Document Status"
    begin
        exit(Enum::"E-Document Status"::"In Progress");
    end;
}