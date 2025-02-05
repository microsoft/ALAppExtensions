// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Processing.Interfaces;

enum 6156 "Import Process" implements IImportProcess
{
    Extensible = true;
    value(0; "Version 1.0")
    {
        Caption = 'Version 1.0';
        Implementation = IImportProcess = "E-Doc. Import";
    }
}
