// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18690 "TDS Tax Engine Setup"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TDSTaxTypes: Codeunit "TDS Tax Types";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(TDSTaxTypes.GetText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUseCaseConfig', '', false, false)]
    local procedure OnGetUseCaseConfig(CaseID: Guid; var ConfigText: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        ConfigText := GetConfig(CaseID, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        CaseList: list of [Guid];
        CaseId: Guid;
    begin
        UpdateUseCaseList(CaseList);

        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        foreach CaseId in CaseList do
            TaxJsonDeserialization.ImportUseCases(GetText(CaseId));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TDSTaxTypes: Codeunit "TDS Tax Types";
        TDSTaxTypeLbl: Label 'TDS';
    begin
        if IsHandled then
            exit;

        if TaxType = TDSTaxTypeLbl then begin
            ConfigText := TDSTaxTypes.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TDS Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TDSTaxTypeData: Codeunit "TDS Tax Types";
        TDSTaxTypeLbl: Label 'TDS';
    begin
        if IsHandled then
            exit;

        if TaxType = TDSTaxTypeLbl then begin
            ConfigText := TDSTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TDS Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetTDSConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;

    procedure GetText(CaseId: Guid): Text
    var
        IsHandled: Boolean;
    begin
        exit(GetConfig(CaseId, IsHandled))
    end;

    local procedure UpdateUseCaseList(CaseList: list of [Guid])
    begin
        CaseList.Add('{DB230097-4AA7-44E2-9373-02A467DC95AC}');
        CaseList.Add('{5D4C69D3-E776-4E9D-B397-09336BFDC884}');
        CaseList.Add('{FED919F2-CBDB-45F9-9383-0E1607897400}');
        CaseList.Add('{B0C259BC-64CC-4818-887A-3337D357CDFF}');
        CaseList.Add('{33BFBE99-9140-4112-A55B-35EC0D9B61B9}');
        CaseList.Add('{271D5BC6-17E8-424E-9E34-3BEE548F938F}');
        CaseList.Add('{A8E114BF-F8CD-44DB-A2B3-614BC18F4442}');
        CaseList.Add('{6FBA1A5C-41A0-4430-976E-6B54E4884164}');
        CaseList.Add('{FEE5DFFF-0BC1-4246-AD90-6CB3DC44A451}');
        CaseList.Add('{FA0E357D-1AC0-42AA-94DE-6DACA521D38E}');
        CaseList.Add('{7D508D37-53AC-4E44-9669-743A8BA82A3F}');
        CaseList.Add('{25EADDE7-E634-4A01-9E4B-74E7C9D5AA62}');
        CaseList.Add('{9E57C058-0570-4828-B24A-760D35A38D19}');
        CaseList.Add('{D9B47164-1681-4C6F-A746-8D710E5F103D}');
        CaseList.Add('{EB2141B4-1220-462B-AB1A-9BB3FFDF704A}');
        CaseList.Add('{C1C8C9A9-1AE8-48D7-AB60-9EA08AA0AF21}');
        CaseList.Add('{61ED733A-A96B-45ED-BE21-A98A8B65566B}');
        CaseList.Add('{0CDED40A-A359-45E0-AAEC-AFE7BBCFBC96}');
        CaseList.Add('{B8483E82-4EAB-43DE-B423-B1371AAA9CE0}');
        CaseList.Add('{F39A0864-D2E7-40A5-9633-B6680CD3EC6F}');
        CaseList.Add('{C3B6CECC-CACE-43A4-8F03-BAB6AFE1E15B}');
        CaseList.Add('{98E3D17E-B644-4DBA-836C-CF26A20EDD3F}');
        CaseList.Add('{D0CED206-BE26-47A3-A370-D064D8AFCE44}');
        CaseList.Add('{487C3669-B12A-42C0-9FEA-D23AB1426BF6}');
        CaseList.Add('{1E42FDF3-1868-4205-A6D6-D2FC67BD132F}');
        CaseList.Add('{75222E87-A1A0-48EE-9211-D3F59009C287}');
        CaseList.Add('{25C2D9C3-2A87-41A6-9AB9-DC76E818DF0C}');
        CaseList.Add('{08737F79-35F1-4670-BD1D-E41764E3A9DE}');
        CaseList.Add('{f8bf58d9-7681-458d-9dfc-71ea23a9f853}');
        CaseList.Add('{1abe2c56-9700-4a30-a14a-5e8ecc2f32dd}');
        CaseList.Add('{b8a33720-278b-45b4-8465-2d9fa273d813}');
    end;

    local procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{DB230097-4AA7-44E2-9373-02A467DC95AC}Lbl": Label 'TDS Use Cases';
        "{5D4C69D3-E776-4E9D-B397-09336BFDC884}Lbl": Label 'TDS Use Cases';
        "{FED919F2-CBDB-45F9-9383-0E1607897400}Lbl": Label 'TDS Use Cases';
        "{B0C259BC-64CC-4818-887A-3337D357CDFF}Lbl": Label 'TDS Use Cases';
        "{33BFBE99-9140-4112-A55B-35EC0D9B61B9}Lbl": Label 'TDS Use Cases';
        "{271D5BC6-17E8-424E-9E34-3BEE548F938F}Lbl": Label 'TDS Use Cases';
        "{A8E114BF-F8CD-44DB-A2B3-614BC18F4442}Lbl": Label 'TDS Use Cases';
        "{6FBA1A5C-41A0-4430-976E-6B54E4884164}Lbl": Label 'TDS Use Cases';
        "{FEE5DFFF-0BC1-4246-AD90-6CB3DC44A451}Lbl": Label 'TDS Use Cases';
        "{FA0E357D-1AC0-42AA-94DE-6DACA521D38E}Lbl": Label 'TDS Use Cases';
        "{7D508D37-53AC-4E44-9669-743A8BA82A3F}Lbl": Label 'TDS Use Cases';
        "{25EADDE7-E634-4A01-9E4B-74E7C9D5AA62}Lbl": Label 'TDS Use Cases';
        "{9E57C058-0570-4828-B24A-760D35A38D19}Lbl": Label 'TDS Use Cases';
        "{D9B47164-1681-4C6F-A746-8D710E5F103D}Lbl": Label 'TDS Use Cases';
        "{EB2141B4-1220-462B-AB1A-9BB3FFDF704A}Lbl": Label 'TDS Use Cases';
        "{C1C8C9A9-1AE8-48D7-AB60-9EA08AA0AF21}Lbl": Label 'TDS Use Cases';
        "{61ED733A-A96B-45ED-BE21-A98A8B65566B}Lbl": Label 'TDS Use Cases';
        "{0CDED40A-A359-45E0-AAEC-AFE7BBCFBC96}Lbl": Label 'TDS Use Cases';
        "{B8483E82-4EAB-43DE-B423-B1371AAA9CE0}Lbl": Label 'TDS Use Cases';
        "{F39A0864-D2E7-40A5-9633-B6680CD3EC6F}Lbl": Label 'TDS Use Cases';
        "{C3B6CECC-CACE-43A4-8F03-BAB6AFE1E15B}Lbl": Label 'TDS Use Cases';
        "{98E3D17E-B644-4DBA-836C-CF26A20EDD3F}Lbl": Label 'TDS Use Cases';
        "{D0CED206-BE26-47A3-A370-D064D8AFCE44}Lbl": Label 'TDS Use Cases';
        "{487C3669-B12A-42C0-9FEA-D23AB1426BF6}Lbl": Label 'TDS Use Cases';
        "{1E42FDF3-1868-4205-A6D6-D2FC67BD132F}Lbl": Label 'TDS Use Cases';
        "{75222E87-A1A0-48EE-9211-D3F59009C287}Lbl": Label 'TDS Use Cases';
        "{25C2D9C3-2A87-41A6-9AB9-DC76E818DF0C}Lbl": Label 'TDS Use Cases';
        "{08737F79-35F1-4670-BD1D-E41764E3A9DE}Lbl": Label 'TDS Use Cases';
        "{f8bf58d9-7681-458d-9dfc-71ea23a9f853}Lbl": Label 'TDS Use Cases';
        "{1abe2c56-9700-4a30-a14a-5e8ecc2f32dd}Lbl": Label 'TDS Use Cases';
        "{b8a33720-278b-45b4-8465-2d9fa273d813}Lbl": Label 'TDS Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{DB230097-4AA7-44E2-9373-02A467DC95AC}':
                exit("{DB230097-4AA7-44E2-9373-02A467DC95AC}Lbl");
            '{5D4C69D3-E776-4E9D-B397-09336BFDC884}':
                exit("{5D4C69D3-E776-4E9D-B397-09336BFDC884}Lbl");
            '{FED919F2-CBDB-45F9-9383-0E1607897400}':
                exit("{FED919F2-CBDB-45F9-9383-0E1607897400}Lbl");
            '{B0C259BC-64CC-4818-887A-3337D357CDFF}':
                exit("{B0C259BC-64CC-4818-887A-3337D357CDFF}Lbl");
            '{33BFBE99-9140-4112-A55B-35EC0D9B61B9}':
                exit("{33BFBE99-9140-4112-A55B-35EC0D9B61B9}Lbl");
            '{271D5BC6-17E8-424E-9E34-3BEE548F938F}':
                exit("{271D5BC6-17E8-424E-9E34-3BEE548F938F}Lbl");
            '{A8E114BF-F8CD-44DB-A2B3-614BC18F4442}':
                exit("{A8E114BF-F8CD-44DB-A2B3-614BC18F4442}Lbl");
            '{6FBA1A5C-41A0-4430-976E-6B54E4884164}':
                exit("{6FBA1A5C-41A0-4430-976E-6B54E4884164}Lbl");
            '{FEE5DFFF-0BC1-4246-AD90-6CB3DC44A451}':
                exit("{FEE5DFFF-0BC1-4246-AD90-6CB3DC44A451}Lbl");
            '{FA0E357D-1AC0-42AA-94DE-6DACA521D38E}':
                exit("{FA0E357D-1AC0-42AA-94DE-6DACA521D38E}Lbl");
            '{7D508D37-53AC-4E44-9669-743A8BA82A3F}':
                exit("{7D508D37-53AC-4E44-9669-743A8BA82A3F}Lbl");
            '{25EADDE7-E634-4A01-9E4B-74E7C9D5AA62}':
                exit("{25EADDE7-E634-4A01-9E4B-74E7C9D5AA62}Lbl");
            '{9E57C058-0570-4828-B24A-760D35A38D19}':
                exit("{9E57C058-0570-4828-B24A-760D35A38D19}Lbl");
            '{D9B47164-1681-4C6F-A746-8D710E5F103D}':
                exit("{D9B47164-1681-4C6F-A746-8D710E5F103D}Lbl");
            '{EB2141B4-1220-462B-AB1A-9BB3FFDF704A}':
                exit("{EB2141B4-1220-462B-AB1A-9BB3FFDF704A}Lbl");
            '{C1C8C9A9-1AE8-48D7-AB60-9EA08AA0AF21}':
                exit("{C1C8C9A9-1AE8-48D7-AB60-9EA08AA0AF21}Lbl");
            '{61ED733A-A96B-45ED-BE21-A98A8B65566B}':
                exit("{61ED733A-A96B-45ED-BE21-A98A8B65566B}Lbl");
            '{0CDED40A-A359-45E0-AAEC-AFE7BBCFBC96}':
                exit("{0CDED40A-A359-45E0-AAEC-AFE7BBCFBC96}Lbl");
            '{B8483E82-4EAB-43DE-B423-B1371AAA9CE0}':
                exit("{B8483E82-4EAB-43DE-B423-B1371AAA9CE0}Lbl");
            '{F39A0864-D2E7-40A5-9633-B6680CD3EC6F}':
                exit("{F39A0864-D2E7-40A5-9633-B6680CD3EC6F}Lbl");
            '{C3B6CECC-CACE-43A4-8F03-BAB6AFE1E15B}':
                exit("{C3B6CECC-CACE-43A4-8F03-BAB6AFE1E15B}Lbl");
            '{98E3D17E-B644-4DBA-836C-CF26A20EDD3F}':
                exit("{98E3D17E-B644-4DBA-836C-CF26A20EDD3F}Lbl");
            '{D0CED206-BE26-47A3-A370-D064D8AFCE44}':
                exit("{D0CED206-BE26-47A3-A370-D064D8AFCE44}Lbl");
            '{487C3669-B12A-42C0-9FEA-D23AB1426BF6}':
                exit("{487C3669-B12A-42C0-9FEA-D23AB1426BF6}Lbl");
            '{1E42FDF3-1868-4205-A6D6-D2FC67BD132F}':
                exit("{1E42FDF3-1868-4205-A6D6-D2FC67BD132F}Lbl");
            '{75222E87-A1A0-48EE-9211-D3F59009C287}':
                exit("{75222E87-A1A0-48EE-9211-D3F59009C287}Lbl");
            '{25C2D9C3-2A87-41A6-9AB9-DC76E818DF0C}':
                exit("{25C2D9C3-2A87-41A6-9AB9-DC76E818DF0C}Lbl");
            '{08737F79-35F1-4670-BD1D-E41764E3A9DE}':
                exit("{08737F79-35F1-4670-BD1D-E41764E3A9DE}Lbl");
            '{f8bf58d9-7681-458d-9dfc-71ea23a9f853}':
                exit("{f8bf58d9-7681-458d-9dfc-71ea23a9f853}Lbl");
            '{1abe2c56-9700-4a30-a14a-5e8ecc2f32dd}':
                exit("{1abe2c56-9700-4a30-a14a-5e8ecc2f32dd}Lbl");
            '{b8a33720-278b-45b4-8465-2d9fa273d813}':
                exit("{b8a33720-278b-45b4-8465-2d9fa273d813}Lbl");
        end;

        Handled := false;
    end;
}
