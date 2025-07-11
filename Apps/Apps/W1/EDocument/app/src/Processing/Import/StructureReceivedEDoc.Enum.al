// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Format;

enum 6103 "Structure Received E-Doc." implements IStructureReceivedEDocument
{
    Extensible = true;

    value(0; Unspecified)
    {
        Caption = 'Unspecified';
        Implementation = IStructureReceivedEDocument = "E-Doc. Unspecified Impl.";
    }
    value(1; "Already Structured")
    {
        Caption = 'Already Structured';
        Implementation = IStructureReceivedEDocument = "E-Doc. Empty Draft";
    }
    value(2; "ADI")
    {
        Caption = 'Azure Document Intelligence';
        Implementation = IStructureReceivedEDocument = "E-Document ADI Handler";
    }
}