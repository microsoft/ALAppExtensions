﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

controladdin "Tax Information Addin"
{
    VerticalShrink = true;
    VerticalStretch = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedHeight = 400;

    StartupScript = '.\TaxEngine-TaxTypeHandler\src\TaxInformation\ControlAddin\scripts\TaxInformationStartup.js';
    Scripts = '.\TaxEngine-TaxTypeHandler\src\TaxInformation\ControlAddin\scripts\TaxInformation.js';

    StyleSheets = '.\TaxEngine-TaxTypeHandler\src\TaxInformation\ControlAddin\css\Taxinformation.css';
    procedure RenderTaxInformation(Attributes: JsonObject; Components: JsonObject);
    event AddInLoaded();
}
