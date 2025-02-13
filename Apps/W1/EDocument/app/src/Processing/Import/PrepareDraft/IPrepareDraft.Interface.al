// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument;

interface IPrepareDraft
{
    procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Enum "E-Document Type";
}