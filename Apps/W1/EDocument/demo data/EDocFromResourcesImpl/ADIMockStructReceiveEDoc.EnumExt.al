// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.EServices.EDocument.Format;

enumextension 5405 "ADI Mock Struct Receive E-Doc." extends "Structure Received E-Doc."
{
    value(5405; "ADI Mock")
    {
        Caption = 'ADI Mock';
        Implementation = IStructureReceivedEDocument = "E-Doc ADI Handler Mock";
    }
}