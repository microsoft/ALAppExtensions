// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Utilities;

codeunit 31288 "Create Document Footer CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Document Footer CZL" = rim;

    trigger OnRun()
    var
        CreateLanguage: Codeunit "Create Language";
    begin
        InsertDocumentFooter(CreateLanguage.CSY(), FooterTextLbl);
    end;

    local procedure InsertDocumentFooter(LanguageCode: Code[10]; FooterText: Text[1000])
    var
        DocumentFooterCZL: Record "Document Footer CZL";
    begin
        if DocumentFooterCZL.Get(LanguageCode) then
            exit;

        DocumentFooterCZL.Init();
        DocumentFooterCZL."Language Code" := LanguageCode;
        DocumentFooterCZL."Footer Text" := FooterText;
        DocumentFooterCZL.Insert();
    end;

    var
        FooterTextLbl: Label 'Registered at the Municipal Court in Prague, Section B, File 6970789', MaxLength = 1000;
}
