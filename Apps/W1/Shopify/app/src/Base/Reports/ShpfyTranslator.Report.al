// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Globalization;

report 30111 "Shpfy Translator"
{
    Caption = 'Shopify Translator';
    ProcessingOnly = true;

    var
        AttributeTitleLbl: Label 'Item Attributes';

    internal procedure GetAttributeTitle(LanguageCode: Code[10]): Text;
    var
        Language: Codeunit Language;
    begin
        CurrReport.Language := Language.GetLanguageIdOrDefault(LanguageCode);
        exit(AttributeTitleLbl);
    end;
}