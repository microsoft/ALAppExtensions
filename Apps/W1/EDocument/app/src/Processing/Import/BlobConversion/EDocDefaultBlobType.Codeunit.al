// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Interfaces;

/// <summary>
/// Pass through blob converter for E-Documents.
/// This codeunit is default implementation of the IBlobToStructuredDataConverter interface.
/// </summary>
codeunit 6105 "E-Doc. Default Blob Type" implements IBlobType
{
    Access = Internal;

    procedure IsStructured(): Boolean
    begin
        exit(true);
    end;

    procedure HasConverter(): Boolean
    begin
        exit(false);
    end;

    procedure GetStructuredDataConverter(): Interface IBlobToStructuredDataConverter
    begin
        // Empty by design
    end;

}