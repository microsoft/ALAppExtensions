// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Installs the selected extension.
/// </summary>
page 2503 "Extension Installation"
{
    Extensible = false;
    PageType = Card;
    SourceTable = "Published Application";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = 'ui-extensions';

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CurrPage.Close();
    end;

    trigger OnOpenPage()
    var
        ExtensionMarketplace: Codeunit "Extension Marketplace";
        MarketplaceExtnDeployment: Page "Marketplace Extn Deployment";
    begin
        GetDetailsFromFilters();

        MarketplaceExtnDeployment.SetAppID(Rec.ID);
        MarketplaceExtnDeployment.RunModal();
        if MarketplaceExtnDeployment.GetInstalledSelected() then begin
            if NOT IsNullGuid(ID) then
                ExtensionMarketplace.InstallMarketplaceExtension(ID, ResponseURL, MarketplaceExtnDeployment.GetLanguageId());
            CurrPage.Close();
        end;
    end;

    local procedure GetDetailsFromFilters()
    var
        RecordRef: RecordRef;
        i: Integer;
    begin
        RecordRef.GetTable(Rec);
        for i := 1 to RecordRef.FieldCount() do
            ParseFilter(RecordRef.FieldIndex(i));
        RecordRef.SetTable(Rec);
    end;

    local procedure ParseFilter(FieldRef: FieldRef)
    var
        FilterPrefixDotNet_Regex: DotNet Regex;
        SingleQuoteDotNet_Regex: DotNet Regex;
        EscapedEqualityDotNet_Regex: DotNet Regex;
        "Filter": Text;
    begin
        FilterPrefixDotNet_Regex := FilterPrefixDotNet_Regex.Regex('^@\*([^\\]+)\*$');
        SingleQuoteDotNet_Regex := SingleQuoteDotNet_Regex.Regex('^''([^\\]+)''$');
        EscapedEqualityDotNet_Regex := EscapedEqualityDotNet_Regex.Regex('~');
        Filter := FieldRef.GetFilter();
        Filter := FilterPrefixDotNet_Regex.Replace(Filter, '$1');
        Filter := SingleQuoteDotNet_Regex.Replace(Filter, '$1');
        Filter := EscapedEqualityDotNet_Regex.Replace(Filter, '=');

        if Filter <> '' then
            FieldRef.Value(Filter);
    end;
}

