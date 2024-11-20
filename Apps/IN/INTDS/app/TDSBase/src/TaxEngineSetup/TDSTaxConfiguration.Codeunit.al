// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

codeunit 18694 "TDS Tax Configuration"
{
    SingleInstance = true;

    local procedure RefreshKeyValue()
    begin
        if ListUpdated then
            exit;

        UpdateTDSTaxTypes();
        UpdateTDSUseCases();
        ListUpdated := true;
    end;

    procedure GetTaxTypes(): List of [Code[20]]
    begin
        RefreshKeyValue();
        exit(TaxTypes.Keys());
    end;

    procedure GetUseCases(): List of [Guid]
    begin
        RefreshKeyValue();
        exit(UseCases.Keys());
    end;

    procedure IsMSTaxType(TaxTypeCode: Code[20]): Boolean
    begin
        exit(TaxTypes.ContainsKey(TaxTypeCode));
    end;

    procedure IsMSUseCase(CaseID: Guid): Boolean
    begin
        exit(UseCases.ContainsKey(CaseID));
    end;

    procedure GetMSTaxTypeVersion(TaxTypeCode: Code[20]): Integer
    begin
        exit(TaxTypes.Get(TaxTypeCode));
    end;

    procedure GetMSUseCaseVersion(CaseID: Guid): Integer
    begin
        exit(UseCases.Get(CaseID));
    end;

    local procedure UpdateTDSTaxTypes()
    begin
        TaxTypes.Add(TDSTaxTypeLbl, 1);
    end;

    local procedure UpdateTDSUseCases()
    begin
        UseCases.Add('{DB230097-4AA7-44E2-9373-02A467DC95AC}', 4);
        UseCases.Add('{5D4C69D3-E776-4E9D-B397-09336BFDC884}', 1);
        UseCases.Add('{FED919F2-CBDB-45F9-9383-0E1607897400}', 2);
        UseCases.Add('{B0C259BC-64CC-4818-887A-3337D357CDFF}', 2);
        UseCases.Add('{33BFBE99-9140-4112-A55B-35EC0D9B61B9}', 2);
        UseCases.Add('{271D5BC6-17E8-424E-9E34-3BEE548F938F}', 1);
        UseCases.Add('{A8E114BF-F8CD-44DB-A2B3-614BC18F4442}', 21);
        UseCases.Add('{6FBA1A5C-41A0-4430-976E-6B54E4884164}', 1);
        UseCases.Add('{FEE5DFFF-0BC1-4246-AD90-6CB3DC44A451}', 1);
        UseCases.Add('{FA0E357D-1AC0-42AA-94DE-6DACA521D38E}', 2);
        UseCases.Add('{7D508D37-53AC-4E44-9669-743A8BA82A3F}', 1);
        UseCases.Add('{25EADDE7-E634-4A01-9E4B-74E7C9D5AA62}', 1);
        UseCases.Add('{9E57C058-0570-4828-B24A-760D35A38D19}', 1);
        UseCases.Add('{D9B47164-1681-4C6F-A746-8D710E5F103D}', 3);
        UseCases.Add('{EB2141B4-1220-462B-AB1A-9BB3FFDF704A}', 1);
        UseCases.Add('{C1C8C9A9-1AE8-48D7-AB60-9EA08AA0AF21}', 4);
        UseCases.Add('{61ED733A-A96B-45ED-BE21-A98A8B65566B}', 1);
        UseCases.Add('{0CDED40A-A359-45E0-AAEC-AFE7BBCFBC96}', 2);
        UseCases.Add('{B8483E82-4EAB-43DE-B423-B1371AAA9CE0}', 2);
        UseCases.Add('{F39A0864-D2E7-40A5-9633-B6680CD3EC6F}', 3);
        UseCases.Add('{C3B6CECC-CACE-43A4-8F03-BAB6AFE1E15B}', 1);
        UseCases.Add('{98E3D17E-B644-4DBA-836C-CF26A20EDD3F}', 3);
        UseCases.Add('{D0CED206-BE26-47A3-A370-D064D8AFCE44}', 1);
        UseCases.Add('{487C3669-B12A-42C0-9FEA-D23AB1426BF6}', 1);
        UseCases.Add('{1E42FDF3-1868-4205-A6D6-D2FC67BD132F}', 7);
        UseCases.Add('{75222E87-A1A0-48EE-9211-D3F59009C287}', 1);
        UseCases.Add('{25C2D9C3-2A87-41A6-9AB9-DC76E818DF0C}', 1);
        UseCases.Add('{08737F79-35F1-4670-BD1D-E41764E3A9DE}', 1);
        UseCases.Add('{f8bf58d9-7681-458d-9dfc-71ea23a9f853}', 3);
        UseCases.Add('{1abe2c56-9700-4a30-a14a-5e8ecc2f32dd}', 2);
        UseCases.Add('{b8a33720-278b-45b4-8465-2d9fa273d813}', 3);
    end;

    var
        TaxTypes: Dictionary of [Code[20], Integer];
        UseCases: Dictionary of [Guid, Integer];
        ListUpdated: Boolean;
        TDSTaxTypeLbl: Label 'TDS';
}
