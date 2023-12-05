// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

codeunit 18815 "TCS Tax Configuration"
{
    SingleInstance = true;

    local procedure RefreshKeyValue()
    begin
        if ListUpdated then
            exit;

        UpdateTCSTaxTypes();
        UpdateTCSUseCases();
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

    local procedure UpdateTCSTaxTypes()
    begin
        TaxTypes.Add(TCSTaxTypeLbl, 1);
    end;

    local procedure UpdateTCSUseCases()
    begin
        UseCases.Add('{BC834CD9-7782-4B77-8D0E-0D7EF1679775}', 8);
        UseCases.Add('{42747DC4-6388-459E-9D2E-103F3F4E2AB0}', 1);
        UseCases.Add('{E696BECA-20A6-498E-9615-114585216ABA}', 1);
        UseCases.Add('{4BC77C19-4CA3-4913-8EB5-11EDAE308A25}', 1);
        UseCases.Add('{B3983817-AAEE-4AD8-97D8-16A875361BA7}', 1);
        UseCases.Add('{91492C74-9837-4256-8B07-1BA40247EA73}', 2);
        UseCases.Add('{6AD030DC-AE48-48C9-9651-36BA6742BDED}', 1);
        UseCases.Add('{800AD5B2-89E5-4616-8281-37DDEC382E76}', 1);
        UseCases.Add('{F687A3C1-9192-42D2-A042-39C2B63B35D7}', 1);
        UseCases.Add('{593E67FC-EACA-4C9B-8F95-4A1D3D1712E4}', 1);
        UseCases.Add('{4DC37F56-3558-400D-ABB1-5573CCC0FD30}', 2);
        UseCases.Add('{B8AC2649-DEA6-42B1-BF69-62A706C6DC40}', 1);
        UseCases.Add('{DA63D636-4773-418A-8123-6522A7867E5F}', 1);
        UseCases.Add('{4782B33F-5607-4D84-A74F-7061F377D235}', 1);
        UseCases.Add('{4383C40B-8C8A-413C-A840-713CDA7C8B06}', 1);
        UseCases.Add('{6B7BF4A0-0250-4480-9482-733992652D29}', 3);
        UseCases.Add('{B1B995F9-C500-4846-9FE8-833A900F0846}', 1);
        UseCases.Add('{82174562-748D-4C6F-AE37-852C7CCEFEAC}', 1);
        UseCases.Add('{3ED702E0-AFA2-4771-AD1F-8FBEF7383436}', 1);
        UseCases.Add('{77DE8E48-908D-4E7E-9FBE-98B9EFCB7AE5}', 1);
        UseCases.Add('{1E2CC6D7-1793-4F6E-BF59-A79A941FD309}', 1);
        UseCases.Add('{6F4B6558-D97D-463E-BCC2-A8AE3C7EB872}', 1);
        UseCases.Add('{FE8A4EB1-249A-4BB2-9C23-B1DC2847BC52}', 1);
        UseCases.Add('{5E2AC8E9-8A09-4BA9-8C30-C1CD27CAA214}', 1);
        UseCases.Add('{D9843455-A721-409B-8A37-D111331A8024}', 1);
        UseCases.Add('{C8358DF6-AC70-4AB2-94E4-D609ADC635CA}', 1);
        UseCases.Add('{CB9FAD0D-74A9-4DD5-A83A-E2F6A1FABA06}', 1);
        UseCases.Add('{088AD93D-6264-4C00-8E0D-F15F40E5E4F6}', 1);
        UseCases.Add('{994E3FD7-2FE1-4B6D-AC06-F819F8B94F07}', 1);
    end;

    var
        TaxTypes: Dictionary of [Code[20], Integer];
        UseCases: Dictionary of [Guid, Integer];
        ListUpdated: Boolean;
        TCSTaxTypeLbl: Label 'TCS';
}
