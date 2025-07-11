// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18810 "TCS Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TCSTaxType: Codeunit "TCS Tax Type";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(TCSTaxType.GetText());
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
        TCSTaxType: Codeunit "TCS Tax Type";
        TCSTaxTypeLbl: Label 'TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = TCSTaxTypeLbl then begin
            ConfigText := TCSTaxType.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TCS Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TCSTaxTypeData: Codeunit "TCS Tax Type";
        TCSTaxTypeLbl: Label 'TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = TCSTaxTypeLbl then begin
            ConfigText := TCSTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TCS Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetTCSConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
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
        CaseList.Add('{BC834CD9-7782-4B77-8D0E-0D7EF1679775}');
        CaseList.Add('{42747DC4-6388-459E-9D2E-103F3F4E2AB0}');
        CaseList.Add('{E696BECA-20A6-498E-9615-114585216ABA}');
        CaseList.Add('{4BC77C19-4CA3-4913-8EB5-11EDAE308A25}');
        CaseList.Add('{B3983817-AAEE-4AD8-97D8-16A875361BA7}');
        CaseList.Add('{91492C74-9837-4256-8B07-1BA40247EA73}');
        CaseList.Add('{6AD030DC-AE48-48C9-9651-36BA6742BDED}');
        CaseList.Add('{800AD5B2-89E5-4616-8281-37DDEC382E76}');
        CaseList.Add('{F687A3C1-9192-42D2-A042-39C2B63B35D7}');
        CaseList.Add('{593E67FC-EACA-4C9B-8F95-4A1D3D1712E4}');
        CaseList.Add('{4DC37F56-3558-400D-ABB1-5573CCC0FD30}');
        CaseList.Add('{B8AC2649-DEA6-42B1-BF69-62A706C6DC40}');
        CaseList.Add('{DA63D636-4773-418A-8123-6522A7867E5F}');
        CaseList.Add('{4782B33F-5607-4D84-A74F-7061F377D235}');
        CaseList.Add('{4383C40B-8C8A-413C-A840-713CDA7C8B06}');
        CaseList.Add('{6B7BF4A0-0250-4480-9482-733992652D29}');
        CaseList.Add('{B1B995F9-C500-4846-9FE8-833A900F0846}');
        CaseList.Add('{82174562-748D-4C6F-AE37-852C7CCEFEAC}');
        CaseList.Add('{3ED702E0-AFA2-4771-AD1F-8FBEF7383436}');
        CaseList.Add('{77DE8E48-908D-4E7E-9FBE-98B9EFCB7AE5}');
        CaseList.Add('{1E2CC6D7-1793-4F6E-BF59-A79A941FD309}');
        CaseList.Add('{6F4B6558-D97D-463E-BCC2-A8AE3C7EB872}');
        CaseList.Add('{FE8A4EB1-249A-4BB2-9C23-B1DC2847BC52}');
        CaseList.Add('{5E2AC8E9-8A09-4BA9-8C30-C1CD27CAA214}');
        CaseList.Add('{D9843455-A721-409B-8A37-D111331A8024}');
        CaseList.Add('{C8358DF6-AC70-4AB2-94E4-D609ADC635CA}');
        CaseList.Add('{CB9FAD0D-74A9-4DD5-A83A-E2F6A1FABA06}');
        CaseList.Add('{088AD93D-6264-4C00-8E0D-F15F40E5E4F6}');
        CaseList.Add('{994E3FD7-2FE1-4B6D-AC06-F819F8B94F07}');
    end;

    local procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{BC834CD9-7782-4B77-8D0E-0D7EF1679775}Lbl": Label 'TCS Use Cases';
        "{42747DC4-6388-459E-9D2E-103F3F4E2AB0}Lbl": Label 'TCS Use Cases';
        "{E696BECA-20A6-498E-9615-114585216ABA}Lbl": Label 'TCS Use Cases';
        "{4BC77C19-4CA3-4913-8EB5-11EDAE308A25}Lbl": Label 'TCS Use Cases';
        "{B3983817-AAEE-4AD8-97D8-16A875361BA7}Lbl": Label 'TCS Use Cases';
        "{91492C74-9837-4256-8B07-1BA40247EA73}Lbl": Label 'TCS Use Cases';
        "{6AD030DC-AE48-48C9-9651-36BA6742BDED}Lbl": Label 'TCS Use Cases';
        "{800AD5B2-89E5-4616-8281-37DDEC382E76}Lbl": Label 'TCS Use Cases';
        "{F687A3C1-9192-42D2-A042-39C2B63B35D7}Lbl": Label 'TCS Use Cases';
        "{593E67FC-EACA-4C9B-8F95-4A1D3D1712E4}Lbl": Label 'TCS Use Cases';
        "{4DC37F56-3558-400D-ABB1-5573CCC0FD30}Lbl": Label 'TCS Use Cases';
        "{B8AC2649-DEA6-42B1-BF69-62A706C6DC40}Lbl": Label 'TCS Use Cases';
        "{DA63D636-4773-418A-8123-6522A7867E5F}Lbl": Label 'TCS Use Cases';
        "{4782B33F-5607-4D84-A74F-7061F377D235}Lbl": Label 'TCS Use Cases';
        "{4383C40B-8C8A-413C-A840-713CDA7C8B06}Lbl": Label 'TCS Use Cases';
        "{6B7BF4A0-0250-4480-9482-733992652D29}Lbl": Label 'TCS Use Cases';
        "{B1B995F9-C500-4846-9FE8-833A900F0846}Lbl": Label 'TCS Use Cases';
        "{82174562-748D-4C6F-AE37-852C7CCEFEAC}Lbl": Label 'TCS Use Cases';
        "{3ED702E0-AFA2-4771-AD1F-8FBEF7383436}Lbl": Label 'TCS Use Cases';
        "{77DE8E48-908D-4E7E-9FBE-98B9EFCB7AE5}Lbl": Label 'TCS Use Cases';
        "{1E2CC6D7-1793-4F6E-BF59-A79A941FD309}Lbl": Label 'TCS Use Cases';
        "{6F4B6558-D97D-463E-BCC2-A8AE3C7EB872}Lbl": Label 'TCS Use Cases';
        "{FE8A4EB1-249A-4BB2-9C23-B1DC2847BC52}Lbl": Label 'TCS Use Cases';
        "{5E2AC8E9-8A09-4BA9-8C30-C1CD27CAA214}Lbl": Label 'TCS Use Cases';
        "{D9843455-A721-409B-8A37-D111331A8024}Lbl": Label 'TCS Use Cases';
        "{C8358DF6-AC70-4AB2-94E4-D609ADC635CA}Lbl": Label 'TCS Use Cases';
        "{CB9FAD0D-74A9-4DD5-A83A-E2F6A1FABA06}Lbl": Label 'TCS Use Cases';
        "{088AD93D-6264-4C00-8E0D-F15F40E5E4F6}Lbl": Label 'TCS Use Cases';
        "{994E3FD7-2FE1-4B6D-AC06-F819F8B94F07}Lbl": Label 'TCS Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{BC834CD9-7782-4B77-8D0E-0D7EF1679775}':
                exit("{BC834CD9-7782-4B77-8D0E-0D7EF1679775}Lbl");
            '{42747DC4-6388-459E-9D2E-103F3F4E2AB0}':
                exit("{42747DC4-6388-459E-9D2E-103F3F4E2AB0}Lbl");
            '{E696BECA-20A6-498E-9615-114585216ABA}':
                exit("{E696BECA-20A6-498E-9615-114585216ABA}Lbl");
            '{4BC77C19-4CA3-4913-8EB5-11EDAE308A25}':
                exit("{4BC77C19-4CA3-4913-8EB5-11EDAE308A25}Lbl");
            '{B3983817-AAEE-4AD8-97D8-16A875361BA7}':
                exit("{B3983817-AAEE-4AD8-97D8-16A875361BA7}Lbl");
            '{91492C74-9837-4256-8B07-1BA40247EA73}':
                exit("{91492C74-9837-4256-8B07-1BA40247EA73}Lbl");
            '{6AD030DC-AE48-48C9-9651-36BA6742BDED}':
                exit("{6AD030DC-AE48-48C9-9651-36BA6742BDED}Lbl");
            '{800AD5B2-89E5-4616-8281-37DDEC382E76}':
                exit("{800AD5B2-89E5-4616-8281-37DDEC382E76}Lbl");
            '{F687A3C1-9192-42D2-A042-39C2B63B35D7}':
                exit("{F687A3C1-9192-42D2-A042-39C2B63B35D7}Lbl");
            '{593E67FC-EACA-4C9B-8F95-4A1D3D1712E4}':
                exit("{593E67FC-EACA-4C9B-8F95-4A1D3D1712E4}Lbl");
            '{4DC37F56-3558-400D-ABB1-5573CCC0FD30}':
                exit("{4DC37F56-3558-400D-ABB1-5573CCC0FD30}Lbl");
            '{B8AC2649-DEA6-42B1-BF69-62A706C6DC40}':
                exit("{B8AC2649-DEA6-42B1-BF69-62A706C6DC40}Lbl");
            '{DA63D636-4773-418A-8123-6522A7867E5F}':
                exit("{DA63D636-4773-418A-8123-6522A7867E5F}Lbl");
            '{4782B33F-5607-4D84-A74F-7061F377D235}':
                exit("{4782B33F-5607-4D84-A74F-7061F377D235}Lbl");
            '{4383C40B-8C8A-413C-A840-713CDA7C8B06}':
                exit("{4383C40B-8C8A-413C-A840-713CDA7C8B06}Lbl");
            '{6B7BF4A0-0250-4480-9482-733992652D29}':
                exit("{6B7BF4A0-0250-4480-9482-733992652D29}Lbl");
            '{B1B995F9-C500-4846-9FE8-833A900F0846}':
                exit("{B1B995F9-C500-4846-9FE8-833A900F0846}Lbl");
            '{82174562-748D-4C6F-AE37-852C7CCEFEAC}':
                exit("{82174562-748D-4C6F-AE37-852C7CCEFEAC}Lbl");
            '{3ED702E0-AFA2-4771-AD1F-8FBEF7383436}':
                exit("{3ED702E0-AFA2-4771-AD1F-8FBEF7383436}Lbl");
            '{77DE8E48-908D-4E7E-9FBE-98B9EFCB7AE5}':
                exit("{77DE8E48-908D-4E7E-9FBE-98B9EFCB7AE5}Lbl");
            '{1E2CC6D7-1793-4F6E-BF59-A79A941FD309}':
                exit("{1E2CC6D7-1793-4F6E-BF59-A79A941FD309}Lbl");
            '{6F4B6558-D97D-463E-BCC2-A8AE3C7EB872}':
                exit("{6F4B6558-D97D-463E-BCC2-A8AE3C7EB872}Lbl");
            '{FE8A4EB1-249A-4BB2-9C23-B1DC2847BC52}':
                exit("{FE8A4EB1-249A-4BB2-9C23-B1DC2847BC52}Lbl");
            '{5E2AC8E9-8A09-4BA9-8C30-C1CD27CAA214}':
                exit("{5E2AC8E9-8A09-4BA9-8C30-C1CD27CAA214}Lbl");
            '{D9843455-A721-409B-8A37-D111331A8024}':
                exit("{D9843455-A721-409B-8A37-D111331A8024}Lbl");
            '{C8358DF6-AC70-4AB2-94E4-D609ADC635CA}':
                exit("{C8358DF6-AC70-4AB2-94E4-D609ADC635CA}Lbl");
            '{CB9FAD0D-74A9-4DD5-A83A-E2F6A1FABA06}':
                exit("{CB9FAD0D-74A9-4DD5-A83A-E2F6A1FABA06}Lbl");
            '{088AD93D-6264-4C00-8E0D-F15F40E5E4F6}':
                exit("{088AD93D-6264-4C00-8E0D-F15F40E5E4F6}Lbl");
            '{994E3FD7-2FE1-4B6D-AC06-F819F8B94F07}':
                exit("{994E3FD7-2FE1-4B6D-AC06-F819F8B94F07}Lbl");
        end;

        Handled := false;
    end;
}
