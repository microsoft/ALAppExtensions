// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

reportextension 11229 "SE VAT VIES Decl. Tax Auth" extends "VAT- VIES Declaration Tax Auth"
{
    RDLCLayout = './src/ReportExtensions/VATVIESDeclarationTaxAuth.rdlc';

    labels
    {
        TotalAmountForItemsCaptionLbl = 'Total Sales of Items in the period';
        TotalAmountForServicesCaptionLbl = 'Total Sales of Services to EU in the period';
        TotalAmountFor3PartyCaptionLbl = 'Total Sales of EU 3-Party Item Trade in the period';
    }
}
