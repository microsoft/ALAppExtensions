// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18004 "GST Base Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(GSTTaxTypeData.GetText());
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade GST Tax Config", 'OnUpgradeGSTUseCases', '', false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UseCaseConfig := GetText(CaseID);
        if UseCaseConfig <> '' then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        GSTTaxTypeLbl: Label 'GST';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTaxTypeLbl then begin
            ConfigText := GSTTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        GSTTaxTypeLbl: Label 'GST';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTaxTypeLbl then begin
            ConfigText := GSTTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetGSTConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;

    local procedure GetText(CaseId: Guid): Text
    var
        IsHandled: Boolean;
    begin
        exit(GetConfig(CaseId, IsHandled))
    end;

    local procedure UpdateUseCaseList(CaseList: list of [Guid])
    begin
        CaseList.Add('{AFA9BC82-6757-44E3-B5E4-00029DACDA64}');
        CaseList.Add('{8EECE1FD-4BDB-4A37-92ED-00380C170CFC}');
        CaseList.Add('{46054EB7-3CE7-421C-B047-00658AC5C150}');
        CaseList.Add('{E9E7486C-DBFB-432C-886F-017AD828CE5E}');
        CaseList.Add('{6D031AA1-2009-4D4A-A8E7-01D9116EDC5C}');
        CaseList.Add('{87FB95AD-905D-4832-9EC3-0330B674D601}');
        CaseList.Add('{74601C3A-21C1-4924-950E-039ADD6086E6}');
        CaseList.Add('{10675EE2-5AA7-4D43-8794-03BA8CD85445}');
        CaseList.Add('{D2A96240-2F58-406C-8774-03CD60C28E5D}');
        CaseList.Add('{547DDC98-8D3C-46A0-84BE-03E71BA135DA}');
        CaseList.Add('{BBD37D0A-E328-4544-B5E1-03FCF65399D5}');
        CaseList.Add('{1C2FBFBD-A18B-4A5D-819E-043993E5510C}');
        CaseList.Add('{4684DF92-D578-4978-B4EC-04ACC07C8206}');
        CaseList.Add('{668C2032-DD90-4A23-8F30-04B69FE7C99E}');
        CaseList.Add('{C89845E0-C8B1-45B1-9C1B-04EC264B7AC7}');
        CaseList.Add('{76F9EC4B-C6F3-4DBE-B1CA-04EFC5AD609E}');
        CaseList.Add('{4AC1A712-CC9B-4CB7-91EA-05245C1D7211}');
        CaseList.Add('{D9221422-669E-485D-8224-053D641FE4F3}');
        CaseList.Add('{005ED1ED-F66A-4A08-8647-0554154F0DF2}');
        CaseList.Add('{57322220-978A-459E-8EC5-05AB66E6B362}');
        CaseList.Add('{F807C5DC-40B1-4E22-AB49-06BC54A22558}');
        CaseList.Add('{64233AA2-2DB0-4AC9-8078-0755AB5DA89D}');
        CaseList.Add('{DD75810D-2D5B-438A-A3AB-079E1B1D7AB9}');
        CaseList.Add('{19FC1701-0FE4-4ED3-83B8-07DAB075A043}');
        CaseList.Add('{79839F30-7F44-4411-BB2D-07FFA294A38D}');
        CaseList.Add('{A59206F4-476D-4ED9-8665-08535755BB5E}');
        CaseList.Add('{9B0FE6DB-6121-44B0-8BD0-08B8060D7A92}');
        CaseList.Add('{71EC1D59-01EC-4486-8CB4-0957D4ADF38B}');
        CaseList.Add('{B5A9628F-46F5-48C4-9CC0-09CBAE26D7EE}');
        CaseList.Add('{C75CF1E3-CC01-4458-86FB-0A29BC40560B}');
        CaseList.Add('{DA8B91D0-1B63-44EE-BA57-0A40B1403080}');
        CaseList.Add('{99F473AC-553E-4032-AEDB-0AE44C871CD2}');
        CaseList.Add('{50157D1D-C080-4AF0-8C63-0B5E918F5AF2}');
        CaseList.Add('{06F95F30-2C34-4CD2-9084-0B9101B9455D}');
        CaseList.Add('{6F89240D-BBA1-4BB9-85B6-0BE2154EE0B8}');
        CaseList.Add('{4A025601-FF3D-4BA6-A567-0C31785D0D36}');
        CaseList.Add('{8638A2E3-3F44-4672-A54D-0D65B1528FF9}');
        CaseList.Add('{48C973FB-77C2-476C-AB39-0E61F0F76F0D}');
        CaseList.Add('{4A2B9E24-01A5-43C9-A43E-0E7C9CC1C8BB}');
        CaseList.Add('{0FD2A76A-DECB-4FAC-8008-10D6762CDAFE}');
        CaseList.Add('{B90130D9-0471-4034-8687-11B04ABDCE72}');
        CaseList.Add('{142D2618-98AC-4DD8-922F-11CF063DD8D8}');
        CaseList.Add('{047704F8-A619-401F-9653-12103103E14A}');
        CaseList.Add('{759DC0B3-0697-4262-B0B6-12AA4A6E3822}');
        CaseList.Add('{F6DED4E3-7405-4E6E-B0DF-1320041F130A}');
        CaseList.Add('{7E44665E-5E48-4F98-8E9A-135669D3E75B}');
        CaseList.Add('{B618D919-C2A5-4BB8-B7EF-13784A51A6D5}');
        CaseList.Add('{7AC16E57-E977-41B3-9338-1399811A688B}');
        CaseList.Add('{A48A1647-673E-4C77-9997-143963591989}');
        CaseList.Add('{B053F5FC-CD93-4EA7-AC71-1590E006FAAE}');
        CaseList.Add('{52FD8776-17C2-428A-B747-159404771D07}');
        CaseList.Add('{1201ECAE-F4F2-43D7-938E-15F5361C2062}');
        CaseList.Add('{FEE41ACD-C7C4-4653-9A34-15F7F0B70663}');
        CaseList.Add('{9607CA1C-5361-4206-A86E-162026F82D0C}');
        CaseList.Add('{101CAF41-34AB-4EA1-9277-166954A7FF94}');
        CaseList.Add('{43228213-4CEA-41C4-B28B-170B00BC81A8}');
        CaseList.Add('{F5794DA7-0CC7-42C2-BEA0-18EB8F98BB5A}');
        CaseList.Add('{B2150DAA-4B46-41F2-89BF-19F5FD89362E}');
        CaseList.Add('{E411752D-2CC4-4CD4-9D35-1AE651319762}');
        CaseList.Add('{BE8902D9-72AA-41C9-BACE-1B781D7C8107}');
        CaseList.Add('{36710BC3-FED5-4726-8AB5-1DC108CF23AF}');
        CaseList.Add('{8E0D2716-6C6D-4CDF-863F-1E043223D7DF}');
        CaseList.Add('{A9E13C42-F366-4E5F-A057-1E0B4E43D454}');
        CaseList.Add('{C6FDF908-18DE-47B6-ADED-1E654C153D2A}');
        CaseList.Add('{2E7A7A10-CCD5-4673-AF42-1EF83425931F}');
        CaseList.Add('{1C9C14DA-22A0-4F6B-968A-1F79BE11B7A1}');
        CaseList.Add('{A485DD0E-AB08-49E5-9C7C-1FCA3398AE3F}');
        CaseList.Add('{B6045C50-0B69-4DCE-B55D-20613A893341}');
        CaseList.Add('{2A733D02-2125-4EA9-97E3-2068E5708A94}');
        CaseList.Add('{2341D31D-659B-4C70-B0FD-20C4494A4F1F}');
        CaseList.Add('{B69B4BDA-5CAC-4C9C-B4DB-211912D30EF2}');
        CaseList.Add('{4962D3B9-0349-4BE9-B173-22B456AEE6C6}');
        CaseList.Add('{AEDED96A-9927-4DF4-B89B-22FA7C77C19F}');
        CaseList.Add('{11160E03-89D0-481D-B2EA-24898F3DB4AB}');
        CaseList.Add('{B4662B2E-9E63-4BA7-A683-248E5811B566}');
        CaseList.Add('{9639222B-DFA8-4F14-9A72-24E994C1C7DA}');
        CaseList.Add('{99C83819-83BC-418A-A2A7-26A041F2F99A}');
        CaseList.Add('{8E46C7A8-FFB5-40D2-8DBB-26E9FEDDF17D}');
        CaseList.Add('{EC905260-0D39-42CD-ADAE-27F4E74CE267}');
        CaseList.Add('{85D7B57B-6657-4C5B-889D-282A48B9D0FB}');
        CaseList.Add('{B61CB389-28BD-4569-BF95-284B62972B23}');
        CaseList.Add('{C07C2110-2740-4FAD-975B-293FAAD86247}');
        CaseList.Add('{F719A304-09CF-479B-A123-2A4E34ED3133}');
        CaseList.Add('{AA1B2E3A-4149-4352-B081-2A869CDE5353}');
        CaseList.Add('{8D0E6401-974F-4F8E-9254-2AF9067E73DC}');
        CaseList.Add('{41F1CFC3-B9F5-464D-9B6D-2C7B6C83186C}');
        CaseList.Add('{97664A61-096E-43D9-BF55-2D5672F02F7F}');
        CaseList.Add('{52BFB82F-A54A-4E62-9DC3-2D608D6373B0}');
        CaseList.Add('{529A1457-1F3B-412A-87D0-2EA18CA27186}');
        CaseList.Add('{246B0F60-6CA4-42A1-ACDD-30C38C89D2C4}');
        CaseList.Add('{53AA1183-8DEC-4542-A708-317C5CD7BDA9}');
        CaseList.Add('{A7ED2E31-2CA7-4D60-A415-31A78736388D}');
        CaseList.Add('{78DCCF81-7548-4028-A6AF-31AEB633FC3C}');
        CaseList.Add('{64F0C586-3993-4F05-A127-332E7E46802D}');
        CaseList.Add('{A106F715-2EC1-43B7-B0AE-33F6AEEF3B2A}');
        CaseList.Add('{21A349A2-B069-4AA5-86B9-34136BE37267}');
        CaseList.Add('{9167AE32-6B66-48FB-AF03-35D261A7C5BC}');
        CaseList.Add('{4C815B8B-6831-4E19-899D-361FBA9CFC43}');
        CaseList.Add('{62CA4077-63DB-4812-8DBA-369BDD0A5A63}');
        CaseList.Add('{149E867B-BE67-4BA4-AE3B-36C10F7552F5}');
        CaseList.Add('{3EEDD099-9182-42DE-BBF0-385833BC88BE}');
        CaseList.Add('{6856A59C-FE7F-4DDA-B180-391F6E0D0A5F}');
        CaseList.Add('{F0453435-C2EF-43BB-BC81-39454E1DE4B9}');
        CaseList.Add('{81A24E9D-52B9-4EFE-A18B-398C6BAD55ED}');
        CaseList.Add('{0120B543-BBCA-433A-B84D-3A07CA4BD763}');
        CaseList.Add('{97856AB0-DAB0-4CF3-B1B1-3A6EB1524E0F}');
        CaseList.Add('{DF8067FF-2F97-485F-8364-3AC5536AD82D}');
        CaseList.Add('{9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B}');
        CaseList.Add('{09E58D68-C9B5-4A27-B4FE-3BCA8B383E14}');
        CaseList.Add('{25E8E204-2E63-4B79-824C-3C1185D6467C}');
        CaseList.Add('{46AD3622-5D72-4048-9FAC-3C31077C2DF0}');
        CaseList.Add('{F7D97DC6-CF0E-4248-95A3-3C7189BF844D}');
        CaseList.Add('{24F69259-FD27-49A7-B5E8-3CBF5351132F}');
        CaseList.Add('{97CF7642-AB0E-4686-A5CE-3D7C7C641E7E}');
        CaseList.Add('{7627B9EF-CB23-4EAB-88D9-3D894B6F6607}');
        CaseList.Add('{4F234B8B-1B95-4938-B3DF-3D96784EAC77}');
        CaseList.Add('{F8D35423-18AA-4916-A10C-3DC5A6F80CB0}');
        CaseList.Add('{C8AEE991-4EDD-4562-BCE7-3DFA3502C8D2}');
        CaseList.Add('{15E17CFF-8262-4E83-8FD4-3EC012EEA465}');
        CaseList.Add('{96B76AC2-66FF-4457-9DE3-3F2A3213C3E6}');
        CaseList.Add('{11784DD8-7EF0-42CF-9A18-401A9ABC6466}');
        CaseList.Add('{26581492-A8D9-41EB-B84E-40671AE8CC3C}');
        CaseList.Add('{E6B27281-EC3F-4040-B035-4179D33884CE}');
        CaseList.Add('{F14B809C-31CA-4B7D-989E-419B00D35F8F}');
        CaseList.Add('{7E182C87-669C-4CD8-8336-41C2ABE6144C}');
        CaseList.Add('{7307BDA2-283F-4094-82E0-41EC241CE177}');
        CaseList.Add('{536EFB4F-1EBC-4731-861E-433F3BA23A4A}');
        CaseList.Add('{80BC1B3E-DB26-4E90-B780-43C8BA593655}');
        CaseList.Add('{C211C520-8428-4E89-8A9A-446A5EC41D39}');
        CaseList.Add('{C9ED5F18-07B9-43AF-9221-448B962EC9CD}');
        CaseList.Add('{ABD1A54F-36DA-45A7-AFED-451B98434B0C}');
        CaseList.Add('{F4B17FC7-3605-47DD-804E-4573BCB3FAC7}');
        CaseList.Add('{8EC585FC-1F0E-4A31-A28A-463F3239EB57}');
        CaseList.Add('{4001BD59-B35E-4BBC-B7AD-464FBB21E54A}');
        CaseList.Add('{E530DADD-215F-47FF-8A84-46A1E62353CF}');
        CaseList.Add('{EB169AE5-8DE0-4490-8DFD-46CEE05AA5C1}');
        CaseList.Add('{710042C6-833D-4CF4-B943-47CF6691F7DE}');
        CaseList.Add('{34D0EE0E-FC73-416C-A59C-484107E36965}');
        CaseList.Add('{F52FFF81-A64B-4A23-B699-49E370AB59F0}');
        CaseList.Add('{95551286-5BF2-42D5-895A-4A4F450A424B}');
        CaseList.Add('{5B85FA47-8603-4A7F-9B76-4A5AD999CA81}');
        CaseList.Add('{5C3AA147-EDD0-4271-9CB8-4A6F6C98962A}');
        CaseList.Add('{E35E188E-728D-42BE-94F0-4B0476315B0B}');
        CaseList.Add('{887FEE8B-EFB6-4010-B79B-4CDB44F23CC8}');
        CaseList.Add('{AF9D718A-2832-4D92-A195-4D7DD81E2029}');
        CaseList.Add('{4753502A-0359-4A8C-A37C-4DB4B6FCD790}');
        CaseList.Add('{5F9FDC49-A99D-4F72-AA5F-4E0BF5B3AC34}');
        CaseList.Add('{8F88FDD0-561E-4FEA-A663-4F4BAEC9D009}');
        CaseList.Add('{6A72F56C-CA49-4D53-939A-4FABC050BFB3}');
        CaseList.Add('{2653A4AF-CD57-4A29-B4C2-4FE3749AC4AD}');
        CaseList.Add('{2C80FA78-CBBE-45E7-8C62-5010B692AC9C}');
        CaseList.Add('{A56AAD73-6807-47CF-BB9C-501BD61D691D}');
        CaseList.Add('{C915C6D6-9C5D-4C2F-BAB6-50E13850581E}');
        CaseList.Add('{FEB751CF-3E8D-42AB-965E-51097FF60E64}');
        CaseList.Add('{8E2CB0E2-795D-4DC3-879B-5117E415DFB9}');
        CaseList.Add('{118F40D5-2D0E-45D6-B458-52D6BF00A035}');
        CaseList.Add('{CCF91681-45AA-45DC-94A6-52DBBF199CF5}');
        CaseList.Add('{44F4B3DF-4625-4E8F-9BE3-53C61B67463B}');
        CaseList.Add('{64A2BCC0-3E88-4613-B91D-540FF4977F86}');
        CaseList.Add('{5E1C6C44-CCBA-49ED-AD64-54D360467B0F}');
        CaseList.Add('{7ABC67E5-F6F0-4ECB-9634-55258429DFD8}');
        CaseList.Add('{A9D34135-2984-4C5D-99C0-5563408C59EE}');
        CaseList.Add('{137A0843-A280-441F-8D87-5639EDB2B01E}');
        CaseList.Add('{26ED31B0-75B8-439C-8E16-56518665184F}');
        CaseList.Add('{09CD7163-15FB-4340-82BF-57373BE3E206}');
        CaseList.Add('{975372FC-F93D-4E8B-81EA-57B6751B9F94}');
        CaseList.Add('{AA215442-D318-4160-A666-57E3FBE06CDD}');
        CaseList.Add('{93FE03BD-63C7-44B5-B40D-5974C8300527}');
        CaseList.Add('{819CADCF-BE64-4BC6-93BA-59EDE239EB54}');
        CaseList.Add('{3335E143-1F90-4E63-B6E7-5A4897019FFA}');
        CaseList.Add('{D0EADC0B-CBC1-4E07-8ADF-5AE168893B04}');
        CaseList.Add('{D1629C9B-AA5B-4237-94CE-5B14BAF756C0}');
        CaseList.Add('{B2CD61FA-9C30-4FE5-B5C5-5B535BA6DF96}');
        CaseList.Add('{27255CC6-70FC-4D33-91F1-5B83F03CE33E}');
        CaseList.Add('{8A18FA5B-AD17-43D3-8981-5BB20A04EFA2}');
        CaseList.Add('{0027CF9D-DA15-43A2-83D4-5CD214E0278B}');
        CaseList.Add('{015DD77D-3D2F-4B90-8C74-5CE5921E0C27}');
        CaseList.Add('{BACBB54A-0D30-4206-AA6A-5CF48A744D5E}');
        CaseList.Add('{895C47DF-89E2-4A14-9329-5E260C1DBF05}');
        CaseList.Add('{F230C59A-547E-41CA-B6B9-5E8BE22A1BEF}');
        CaseList.Add('{01289E18-40A0-4AC7-92DA-601F5AF77AA0}');
        CaseList.Add('{0371699B-6B05-4B16-99FB-604F142308AA}');
        CaseList.Add('{8503C963-7C87-45CD-8543-607AE516F9F8}');
        CaseList.Add('{81E2ACA0-D6DD-4B4A-ADEF-60B602660F25}');
        CaseList.Add('{01C97F7D-4263-4387-84E1-610D2EA4A762}');
        CaseList.Add('{4CB6ACCD-BD47-4485-A757-62924EA09524}');
        CaseList.Add('{9236A009-169D-4464-8B2C-62C94B782C26}');
        CaseList.Add('{60F5C368-9B10-45CB-BB1B-63DEF7520AB6}');
        CaseList.Add('{AF5EE023-63DF-4210-AD71-6436230F6DFA}');
        CaseList.Add('{4D947EDC-3710-49D2-91D5-6446978D43EC}');
        CaseList.Add('{CA856646-6B6F-42D2-A4CC-64A8F52DE9F6}');
        CaseList.Add('{75F37BC7-AA5D-483D-A8A0-653E94AD6B8D}');
        CaseList.Add('{04F944A1-EF9C-440F-A89B-654782D13EAA}');
        CaseList.Add('{2AB850AD-528A-498A-9E23-65E396AC61A8}');
        CaseList.Add('{F7C5C8B6-2EB3-478E-AE6B-66BEEB6A3861}');
        CaseList.Add('{21957E13-9751-40A2-B591-67ADE93573E7}');
        CaseList.Add('{A7F8D194-33DA-472D-87CB-693FB589CD45}');
        CaseList.Add('{D95F6D4E-EEF5-41B7-8284-694BCBDFEABD}');
        CaseList.Add('{B5669E1C-A496-431B-A29F-69E527E37AA0}');
        CaseList.Add('{A734B9DD-A4C1-427E-AF18-6A8B27474F50}');
        CaseList.Add('{7FD02BAE-DA8D-4100-962E-6A8F7FDE823C}');
        CaseList.Add('{774A6E80-FBB4-4413-9144-6ACA8C6546D2}');
        CaseList.Add('{98A43A23-24F8-4FC2-9D4E-6B45D74B02FB}');
        CaseList.Add('{3F057D29-C926-453B-8B17-6B5E431A20B4}');
        CaseList.Add('{7C3076A9-460B-41BC-AED8-6B615E4835D2}');
        CaseList.Add('{31C539BE-990C-4E00-AF1A-6BFA1333ED7E}');
        CaseList.Add('{CE4E5351-F5F5-413A-AAF9-6C5EA6530D93}');
        CaseList.Add('{6946230A-A2F4-4E4B-90C6-6C907D010EB5}');
        CaseList.Add('{C99A231E-6BBF-4982-AEAF-6CAAC7E5BA9B}');
        CaseList.Add('{DB44587F-08FB-4D5F-96A3-6CD4D4E30300}');
        CaseList.Add('{02B82B77-D7E5-4A49-89A2-6D46EC87AE61}');
        CaseList.Add('{A8ED1A73-743C-4D08-98E3-6D85C416E951}');
        CaseList.Add('{884574EB-3354-459C-AF96-6EB624CCEFFE}');
        CaseList.Add('{6621F516-24B5-47CC-AB8B-6EF51F2616E3}');
        CaseList.Add('{15A78CF5-A4CC-4804-95DA-6FB3DCBF2DBF}');
        CaseList.Add('{960BC8FC-FF34-4E46-A6A0-6FD2CB7BBDA2}');
        CaseList.Add('{144DB41F-813A-4EE0-87EC-7082D07652B7}');
        CaseList.Add('{3C23CDAC-6995-4B6C-9E4B-708B540C413B}');
        CaseList.Add('{B3036F44-2238-4DC9-B250-70AA3FEC7821}');
        CaseList.Add('{7342ECF9-7916-4923-AC4C-71E973942346}');
        CaseList.Add('{F9812F85-5C7A-41AC-8E1B-726669627637}');
        CaseList.Add('{545DC1C5-C848-43B9-BFCE-72C3A45C94BA}');
        CaseList.Add('{B68BAE5C-F887-46E8-9B4C-7333EB6152E0}');
        CaseList.Add('{6FB5A46A-83C0-495F-9495-7365027603EA}');
        CaseList.Add('{789CE492-C2BE-4EEC-8E98-740310FDD0E3}');
        CaseList.Add('{B12DD0D6-A87C-4A8C-AE71-746B26156893}');
        CaseList.Add('{C9854015-8E55-43F1-A5F2-747FC1CF6A0F}');
        CaseList.Add('{70C3E4EB-0051-468C-A35C-748883F08A12}');
        CaseList.Add('{20913086-F0CD-4AC8-AF0A-755723E44946}');
        CaseList.Add('{CF175943-0F1A-4814-BF17-756FB88F497C}');
        CaseList.Add('{0686E40E-9643-42C8-B4D1-7587447E98E0}');
        CaseList.Add('{028465BA-B14C-4266-9D47-75A8087EE299}');
        CaseList.Add('{AE2974C0-8A1D-4821-8999-7617690C41FC}');
        CaseList.Add('{888E76DA-FA62-4714-83A3-76777E325D84}');
        CaseList.Add('{0AAD1908-46DC-4370-8A8D-77096D9B30B0}');
        CaseList.Add('{6B464955-261F-4EAF-A749-7807444FC37C}');
        CaseList.Add('{EAD964E4-7CD1-4462-96B3-78A3FA9DE087}');
        CaseList.Add('{62A4192A-86D8-4431-A641-78EF2F348546}');
        CaseList.Add('{282C9335-DD37-49C9-9C60-7A0DB8A4B8F0}');
        CaseList.Add('{2DA1B2DF-5B9F-4E93-8F99-7A26E87BB4A2}');
        CaseList.Add('{2E369D91-2885-47EB-886E-7AD35816B42E}');
        CaseList.Add('{F67095C1-F610-4B59-A1E5-7B58D83A6CF5}');
        CaseList.Add('{B45F2436-2E00-4A49-9A8E-7B9202FE0F0A}');
        CaseList.Add('{33896D17-0F26-4376-8304-7BA20BE4E6D4}');
        CaseList.Add('{277B1053-C551-4BF4-9518-7BFE200A8E18}');
        CaseList.Add('{073D94DC-E7F0-4535-B269-7C36C626FD96}');
        CaseList.Add('{3DC33AD0-69AB-4B36-B58D-7C409957507C}');
        CaseList.Add('{9F7A9C0A-BC4A-45C2-B79B-7D22EDB6ABBB}');
        CaseList.Add('{18F45902-76C4-4B57-AF7F-7D9B3A76D51F}');
        CaseList.Add('{EA146DA9-BB20-4A42-9C06-7E83FDF9F943}');
        CaseList.Add('{B064E1CD-DB51-456E-AE19-7F2AC8C9DC11}');
        CaseList.Add('{441D3A0A-1F6C-4F47-AC82-7F5E2782785D}');
        CaseList.Add('{00B59093-4DB8-4152-99DB-7F9368A143A8}');
        CaseList.Add('{9666CA08-2C56-43C5-B36F-7FD3745FE832}');
        CaseList.Add('{61FB3B94-A2C7-4F3F-B4A8-801D842328E1}');
        CaseList.Add('{C4BC4E11-E295-4A20-9F5F-801F2406A610}');
        CaseList.Add('{DA389E3B-A6C3-4DE1-9843-807B2161B9DE}');
        CaseList.Add('{8FDC8D41-E5D7-40D7-B962-80DA519596F3}');
        CaseList.Add('{DB7C51C1-1F9F-40F2-82C2-82D59793413C}');
        CaseList.Add('{C02EF3F0-A659-4762-854B-830A8D59B371}');
        CaseList.Add('{6510FF1C-A0A5-4C52-8DE5-836BE2536650}');
        CaseList.Add('{693D346E-069E-4306-9F7C-84665CD42141}');
        CaseList.Add('{55AD5167-785F-4CC3-B633-84A8414EE100}');
        CaseList.Add('{4C0ECC95-F5CD-46B2-B302-84C3A5AD7D4E}');
        CaseList.Add('{E06B429C-0CDD-4F49-9C4D-8546151805AD}');
        CaseList.Add('{E076372D-BFB5-4911-B6EE-85F1F71B1569}');
        CaseList.Add('{1CB4368B-D6AF-4B89-AFEB-8641B0152451}');
        CaseList.Add('{A4461039-C91C-4102-9438-866AF5607096}');
        CaseList.Add('{38C5A554-206D-44A5-9090-86CAC52A7715}');
        CaseList.Add('{B83A838B-C0A8-4E69-B735-86D011229B1C}');
        CaseList.Add('{23B7CD0D-EA02-4835-9AE8-875813B138F0}');
        CaseList.Add('{9DFF9CBE-B1A5-4D28-A855-8783315A87D0}');
        CaseList.Add('{CCF41113-DC62-47E2-B45B-87AF0248AF65}');
        CaseList.Add('{2CEB6A3E-11E4-420F-A3C6-886B920BEC29}');
        CaseList.Add('{36017702-208F-4E8C-A75E-8872EA7D1205}');
        CaseList.Add('{A8BF5AD2-5132-40E7-9DF1-893B3940F6EE}');
        CaseList.Add('{990AEEEE-91BD-4C0E-8346-897F141E4EDB}');
        CaseList.Add('{BBA0DF22-691B-46EB-8500-8B270596F2E9}');
        CaseList.Add('{CFE77ACE-1F20-4126-98D9-8D14B18088EE}');
        CaseList.Add('{A8FE6EC6-8FE0-42C6-AE40-8D3B2BC638C0}');
    end;

    procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{AFA9BC82-6757-44E3-B5E4-00029DACDA64}Lbl": Label 'GST Use Cases';
        "{8EECE1FD-4BDB-4A37-92ED-00380C170CFC}Lbl": Label 'GST Use Cases';
        "{46054EB7-3CE7-421C-B047-00658AC5C150}Lbl": Label 'GST Use Cases';
        "{E9E7486C-DBFB-432C-886F-017AD828CE5E}Lbl": Label 'GST Use Cases';
        "{6D031AA1-2009-4D4A-A8E7-01D9116EDC5C}Lbl": Label 'GST Use Cases';
        "{87FB95AD-905D-4832-9EC3-0330B674D601}Lbl": Label 'GST Use Cases';
        "{74601C3A-21C1-4924-950E-039ADD6086E6}Lbl": Label 'GST Use Cases';
        "{10675EE2-5AA7-4D43-8794-03BA8CD85445}Lbl": Label 'GST Use Cases';
        "{D2A96240-2F58-406C-8774-03CD60C28E5D}Lbl": Label 'GST Use Cases';
        "{547DDC98-8D3C-46A0-84BE-03E71BA135DA}Lbl": Label 'GST Use Cases';
        "{BBD37D0A-E328-4544-B5E1-03FCF65399D5}Lbl": Label 'GST Use Cases';
        "{1C2FBFBD-A18B-4A5D-819E-043993E5510C}Lbl": Label 'GST Use Cases';
        "{4684DF92-D578-4978-B4EC-04ACC07C8206}Lbl": Label 'GST Use Cases';
        "{668C2032-DD90-4A23-8F30-04B69FE7C99E}Lbl": Label 'GST Use Cases';
        "{C89845E0-C8B1-45B1-9C1B-04EC264B7AC7}Lbl": Label 'GST Use Cases';
        "{76F9EC4B-C6F3-4DBE-B1CA-04EFC5AD609E}Lbl": Label 'GST Use Cases';
        "{4AC1A712-CC9B-4CB7-91EA-05245C1D7211}Lbl": Label 'GST Use Cases';
        "{D9221422-669E-485D-8224-053D641FE4F3}Lbl": Label 'GST Use Cases';
        "{005ED1ED-F66A-4A08-8647-0554154F0DF2}Lbl": Label 'GST Use Cases';
        "{57322220-978A-459E-8EC5-05AB66E6B362}Lbl": Label 'GST Use Cases';
        "{F807C5DC-40B1-4E22-AB49-06BC54A22558}Lbl": Label 'GST Use Cases';
        "{64233AA2-2DB0-4AC9-8078-0755AB5DA89D}Lbl": Label 'GST Use Cases';
        "{DD75810D-2D5B-438A-A3AB-079E1B1D7AB9}Lbl": Label 'GST Use Cases';
        "{19FC1701-0FE4-4ED3-83B8-07DAB075A043}Lbl": Label 'GST Use Cases';
        "{79839F30-7F44-4411-BB2D-07FFA294A38D}Lbl": Label 'GST Use Cases';
        "{A59206F4-476D-4ED9-8665-08535755BB5E}Lbl": Label 'GST Use Cases';
        "{9B0FE6DB-6121-44B0-8BD0-08B8060D7A92}Lbl": Label 'GST Use Cases';
        "{71EC1D59-01EC-4486-8CB4-0957D4ADF38B}Lbl": Label 'GST Use Cases';
        "{B5A9628F-46F5-48C4-9CC0-09CBAE26D7EE}Lbl": Label 'GST Use Cases';
        "{C75CF1E3-CC01-4458-86FB-0A29BC40560B}Lbl": Label 'GST Use Cases';
        "{DA8B91D0-1B63-44EE-BA57-0A40B1403080}Lbl": Label 'GST Use Cases';
        "{99F473AC-553E-4032-AEDB-0AE44C871CD2}Lbl": Label 'GST Use Cases';
        "{50157D1D-C080-4AF0-8C63-0B5E918F5AF2}Lbl": Label 'GST Use Cases';
        "{06F95F30-2C34-4CD2-9084-0B9101B9455D}Lbl": Label 'GST Use Cases';
        "{6F89240D-BBA1-4BB9-85B6-0BE2154EE0B8}Lbl": Label 'GST Use Cases';
        "{4A025601-FF3D-4BA6-A567-0C31785D0D36}Lbl": Label 'GST Use Cases';
        "{8638A2E3-3F44-4672-A54D-0D65B1528FF9}Lbl": Label 'GST Use Cases';
        "{48C973FB-77C2-476C-AB39-0E61F0F76F0D}Lbl": Label 'GST Use Cases';
        "{4A2B9E24-01A5-43C9-A43E-0E7C9CC1C8BB}Lbl": Label 'GST Use Cases';
        "{0FD2A76A-DECB-4FAC-8008-10D6762CDAFE}Lbl": Label 'GST Use Cases';
        "{B90130D9-0471-4034-8687-11B04ABDCE72}Lbl": Label 'GST Use Cases';
        "{142D2618-98AC-4DD8-922F-11CF063DD8D8}Lbl": Label 'GST Use Cases';
        "{047704F8-A619-401F-9653-12103103E14A}Lbl": Label 'GST Use Cases';
        "{759DC0B3-0697-4262-B0B6-12AA4A6E3822}Lbl": Label 'GST Use Cases';
        "{F6DED4E3-7405-4E6E-B0DF-1320041F130A}Lbl": Label 'GST Use Cases';
        "{7E44665E-5E48-4F98-8E9A-135669D3E75B}Lbl": Label 'GST Use Cases';
        "{B618D919-C2A5-4BB8-B7EF-13784A51A6D5}Lbl": Label 'GST Use Cases';
        "{7AC16E57-E977-41B3-9338-1399811A688B}Lbl": Label 'GST Use Cases';
        "{A48A1647-673E-4C77-9997-143963591989}Lbl": Label 'GST Use Cases';
        "{B053F5FC-CD93-4EA7-AC71-1590E006FAAE}Lbl": Label 'GST Use Cases';
        "{52FD8776-17C2-428A-B747-159404771D07}Lbl": Label 'GST Use Cases';
        "{1201ECAE-F4F2-43D7-938E-15F5361C2062}Lbl": Label 'GST Use Cases';
        "{FEE41ACD-C7C4-4653-9A34-15F7F0B70663}Lbl": Label 'GST Use Cases';
        "{9607CA1C-5361-4206-A86E-162026F82D0C}Lbl": Label 'GST Use Cases';
        "{101CAF41-34AB-4EA1-9277-166954A7FF94}Lbl": Label 'GST Use Cases';
        "{43228213-4CEA-41C4-B28B-170B00BC81A8}Lbl": Label 'GST Use Cases';
        "{F5794DA7-0CC7-42C2-BEA0-18EB8F98BB5A}Lbl": Label 'GST Use Cases';
        "{B2150DAA-4B46-41F2-89BF-19F5FD89362E}Lbl": Label 'GST Use Cases';
        "{E411752D-2CC4-4CD4-9D35-1AE651319762}Lbl": Label 'GST Use Cases';
        "{BE8902D9-72AA-41C9-BACE-1B781D7C8107}Lbl": Label 'GST Use Cases';
        "{36710BC3-FED5-4726-8AB5-1DC108CF23AF}Lbl": Label 'GST Use Cases';
        "{8E0D2716-6C6D-4CDF-863F-1E043223D7DF}Lbl": Label 'GST Use Cases';
        "{A9E13C42-F366-4E5F-A057-1E0B4E43D454}Lbl": Label 'GST Use Cases';
        "{C6FDF908-18DE-47B6-ADED-1E654C153D2A}Lbl": Label 'GST Use Cases';
        "{2E7A7A10-CCD5-4673-AF42-1EF83425931F}Lbl": Label 'GST Use Cases';
        "{1C9C14DA-22A0-4F6B-968A-1F79BE11B7A1}Lbl": Label 'GST Use Cases';
        "{A485DD0E-AB08-49E5-9C7C-1FCA3398AE3F}Lbl": Label 'GST Use Cases';
        "{B6045C50-0B69-4DCE-B55D-20613A893341}Lbl": Label 'GST Use Cases';
        "{2A733D02-2125-4EA9-97E3-2068E5708A94}Lbl": Label 'GST Use Cases';
        "{2341D31D-659B-4C70-B0FD-20C4494A4F1F}Lbl": Label 'GST Use Cases';
        "{B69B4BDA-5CAC-4C9C-B4DB-211912D30EF2}Lbl": Label 'GST Use Cases';
        "{4962D3B9-0349-4BE9-B173-22B456AEE6C6}Lbl": Label 'GST Use Cases';
        "{AEDED96A-9927-4DF4-B89B-22FA7C77C19F}Lbl": Label 'GST Use Cases';
        "{11160E03-89D0-481D-B2EA-24898F3DB4AB}Lbl": Label 'GST Use Cases';
        "{B4662B2E-9E63-4BA7-A683-248E5811B566}Lbl": Label 'GST Use Cases';
        "{9639222B-DFA8-4F14-9A72-24E994C1C7DA}Lbl": Label 'GST Use Cases';
        "{99C83819-83BC-418A-A2A7-26A041F2F99A}Lbl": Label 'GST Use Cases';
        "{8E46C7A8-FFB5-40D2-8DBB-26E9FEDDF17D}Lbl": Label 'GST Use Cases';
        "{EC905260-0D39-42CD-ADAE-27F4E74CE267}Lbl": Label 'GST Use Cases';
        "{85D7B57B-6657-4C5B-889D-282A48B9D0FB}Lbl": Label 'GST Use Cases';
        "{B61CB389-28BD-4569-BF95-284B62972B23}Lbl": Label 'GST Use Cases';
        "{C07C2110-2740-4FAD-975B-293FAAD86247}Lbl": Label 'GST Use Cases';
        "{F719A304-09CF-479B-A123-2A4E34ED3133}Lbl": Label 'GST Use Cases';
        "{AA1B2E3A-4149-4352-B081-2A869CDE5353}Lbl": Label 'GST Use Cases';
        "{8D0E6401-974F-4F8E-9254-2AF9067E73DC}Lbl": Label 'GST Use Cases';
        "{41F1CFC3-B9F5-464D-9B6D-2C7B6C83186C}Lbl": Label 'GST Use Cases';
        "{97664A61-096E-43D9-BF55-2D5672F02F7F}Lbl": Label 'GST Use Cases';
        "{52BFB82F-A54A-4E62-9DC3-2D608D6373B0}Lbl": Label 'GST Use Cases';
        "{529A1457-1F3B-412A-87D0-2EA18CA27186}Lbl": Label 'GST Use Cases';
        "{246B0F60-6CA4-42A1-ACDD-30C38C89D2C4}Lbl": Label 'GST Use Cases';
        "{53AA1183-8DEC-4542-A708-317C5CD7BDA9}Lbl": Label 'GST Use Cases';
        "{A7ED2E31-2CA7-4D60-A415-31A78736388D}Lbl": Label 'GST Use Cases';
        "{78DCCF81-7548-4028-A6AF-31AEB633FC3C}Lbl": Label 'GST Use Cases';
        "{64F0C586-3993-4F05-A127-332E7E46802D}Lbl": Label 'GST Use Cases';
        "{A106F715-2EC1-43B7-B0AE-33F6AEEF3B2A}Lbl": Label 'GST Use Cases';
        "{21A349A2-B069-4AA5-86B9-34136BE37267}Lbl": Label 'GST Use Cases';
        "{9167AE32-6B66-48FB-AF03-35D261A7C5BC}Lbl": Label 'GST Use Cases';
        "{4C815B8B-6831-4E19-899D-361FBA9CFC43}Lbl": Label 'GST Use Cases';
        "{62CA4077-63DB-4812-8DBA-369BDD0A5A63}Lbl": Label 'GST Use Cases';
        "{149E867B-BE67-4BA4-AE3B-36C10F7552F5}Lbl": Label 'GST Use Cases';
        "{3EEDD099-9182-42DE-BBF0-385833BC88BE}Lbl": Label 'GST Use Cases';
        "{6856A59C-FE7F-4DDA-B180-391F6E0D0A5F}Lbl": Label 'GST Use Cases';
        "{F0453435-C2EF-43BB-BC81-39454E1DE4B9}Lbl": Label 'GST Use Cases';
        "{81A24E9D-52B9-4EFE-A18B-398C6BAD55ED}Lbl": Label 'GST Use Cases';
        "{0120B543-BBCA-433A-B84D-3A07CA4BD763}Lbl": Label 'GST Use Cases';
        "{97856AB0-DAB0-4CF3-B1B1-3A6EB1524E0F}Lbl": Label 'GST Use Cases';
        "{DF8067FF-2F97-485F-8364-3AC5536AD82D}Lbl": Label 'GST Use Cases';
        "{9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B}Lbl": Label 'GST Use Cases';
        "{09E58D68-C9B5-4A27-B4FE-3BCA8B383E14}Lbl": Label 'GST Use Cases';
        "{25E8E204-2E63-4B79-824C-3C1185D6467C}Lbl": Label 'GST Use Cases';
        "{46AD3622-5D72-4048-9FAC-3C31077C2DF0}Lbl": Label 'GST Use Cases';
        "{F7D97DC6-CF0E-4248-95A3-3C7189BF844D}Lbl": Label 'GST Use Cases';
        "{24F69259-FD27-49A7-B5E8-3CBF5351132F}Lbl": Label 'GST Use Cases';
        "{97CF7642-AB0E-4686-A5CE-3D7C7C641E7E}Lbl": Label 'GST Use Cases';
        "{7627B9EF-CB23-4EAB-88D9-3D894B6F6607}Lbl": Label 'GST Use Cases';
        "{4F234B8B-1B95-4938-B3DF-3D96784EAC77}Lbl": Label 'GST Use Cases';
        "{F8D35423-18AA-4916-A10C-3DC5A6F80CB0}Lbl": Label 'GST Use Cases';
        "{C8AEE991-4EDD-4562-BCE7-3DFA3502C8D2}Lbl": Label 'GST Use Cases';
        "{15E17CFF-8262-4E83-8FD4-3EC012EEA465}Lbl": Label 'GST Use Cases';
        "{96B76AC2-66FF-4457-9DE3-3F2A3213C3E6}Lbl": Label 'GST Use Cases';
        "{11784DD8-7EF0-42CF-9A18-401A9ABC6466}Lbl": Label 'GST Use Cases';
        "{26581492-A8D9-41EB-B84E-40671AE8CC3C}Lbl": Label 'GST Use Cases';
        "{E6B27281-EC3F-4040-B035-4179D33884CE}Lbl": Label 'GST Use Cases';
        "{F14B809C-31CA-4B7D-989E-419B00D35F8F}Lbl": Label 'GST Use Cases';
        "{7E182C87-669C-4CD8-8336-41C2ABE6144C}Lbl": Label 'GST Use Cases';
        "{7307BDA2-283F-4094-82E0-41EC241CE177}Lbl": Label 'GST Use Cases';
        "{536EFB4F-1EBC-4731-861E-433F3BA23A4A}Lbl": Label 'GST Use Cases';
        "{80BC1B3E-DB26-4E90-B780-43C8BA593655}Lbl": Label 'GST Use Cases';
        "{C211C520-8428-4E89-8A9A-446A5EC41D39}Lbl": Label 'GST Use Cases';
        "{C9ED5F18-07B9-43AF-9221-448B962EC9CD}Lbl": Label 'GST Use Cases';
        "{ABD1A54F-36DA-45A7-AFED-451B98434B0C}Lbl": Label 'GST Use Cases';
        "{F4B17FC7-3605-47DD-804E-4573BCB3FAC7}Lbl": Label 'GST Use Cases';
        "{8EC585FC-1F0E-4A31-A28A-463F3239EB57}Lbl": Label 'GST Use Cases';
        "{4001BD59-B35E-4BBC-B7AD-464FBB21E54A}Lbl": Label 'GST Use Cases';
        "{E530DADD-215F-47FF-8A84-46A1E62353CF}Lbl": Label 'GST Use Cases';
        "{EB169AE5-8DE0-4490-8DFD-46CEE05AA5C1}Lbl": Label 'GST Use Cases';
        "{710042C6-833D-4CF4-B943-47CF6691F7DE}Lbl": Label 'GST Use Cases';
        "{34D0EE0E-FC73-416C-A59C-484107E36965}Lbl": Label 'GST Use Cases';
        "{F52FFF81-A64B-4A23-B699-49E370AB59F0}Lbl": Label 'GST Use Cases';
        "{95551286-5BF2-42D5-895A-4A4F450A424B}Lbl": Label 'GST Use Cases';
        "{5B85FA47-8603-4A7F-9B76-4A5AD999CA81}Lbl": Label 'GST Use Cases';
        "{5C3AA147-EDD0-4271-9CB8-4A6F6C98962A}Lbl": Label 'GST Use Cases';
        "{E35E188E-728D-42BE-94F0-4B0476315B0B}Lbl": Label 'GST Use Cases';
        "{887FEE8B-EFB6-4010-B79B-4CDB44F23CC8}Lbl": Label 'GST Use Cases';
        "{AF9D718A-2832-4D92-A195-4D7DD81E2029}Lbl": Label 'GST Use Cases';
        "{4753502A-0359-4A8C-A37C-4DB4B6FCD790}Lbl": Label 'GST Use Cases';
        "{5F9FDC49-A99D-4F72-AA5F-4E0BF5B3AC34}Lbl": Label 'GST Use Cases';
        "{8F88FDD0-561E-4FEA-A663-4F4BAEC9D009}Lbl": Label 'GST Use Cases';
        "{6A72F56C-CA49-4D53-939A-4FABC050BFB3}Lbl": Label 'GST Use Cases';
        "{2653A4AF-CD57-4A29-B4C2-4FE3749AC4AD}Lbl": Label 'GST Use Cases';
        "{2C80FA78-CBBE-45E7-8C62-5010B692AC9C}Lbl": Label 'GST Use Cases';
        "{A56AAD73-6807-47CF-BB9C-501BD61D691D}Lbl": Label 'GST Use Cases';
        "{C915C6D6-9C5D-4C2F-BAB6-50E13850581E}Lbl": Label 'GST Use Cases';
        "{FEB751CF-3E8D-42AB-965E-51097FF60E64}Lbl": Label 'GST Use Cases';
        "{8E2CB0E2-795D-4DC3-879B-5117E415DFB9}Lbl": Label 'GST Use Cases';
        "{118F40D5-2D0E-45D6-B458-52D6BF00A035}Lbl": Label 'GST Use Cases';
        "{CCF91681-45AA-45DC-94A6-52DBBF199CF5}Lbl": Label 'GST Use Cases';
        "{44F4B3DF-4625-4E8F-9BE3-53C61B67463B}Lbl": Label 'GST Use Cases';
        "{64A2BCC0-3E88-4613-B91D-540FF4977F86}Lbl": Label 'GST Use Cases';
        "{5E1C6C44-CCBA-49ED-AD64-54D360467B0F}Lbl": Label 'GST Use Cases';
        "{7ABC67E5-F6F0-4ECB-9634-55258429DFD8}Lbl": Label 'GST Use Cases';
        "{A9D34135-2984-4C5D-99C0-5563408C59EE}Lbl": Label 'GST Use Cases';
        "{137A0843-A280-441F-8D87-5639EDB2B01E}Lbl": Label 'GST Use Cases';
        "{26ED31B0-75B8-439C-8E16-56518665184F}Lbl": Label 'GST Use Cases';
        "{09CD7163-15FB-4340-82BF-57373BE3E206}Lbl": Label 'GST Use Cases';
        "{975372FC-F93D-4E8B-81EA-57B6751B9F94}Lbl": Label 'GST Use Cases';
        "{AA215442-D318-4160-A666-57E3FBE06CDD}Lbl": Label 'GST Use Cases';
        "{93FE03BD-63C7-44B5-B40D-5974C8300527}Lbl": Label 'GST Use Cases';
        "{819CADCF-BE64-4BC6-93BA-59EDE239EB54}Lbl": Label 'GST Use Cases';
        "{3335E143-1F90-4E63-B6E7-5A4897019FFA}Lbl": Label 'GST Use Cases';
        "{D0EADC0B-CBC1-4E07-8ADF-5AE168893B04}Lbl": Label 'GST Use Cases';
        "{D1629C9B-AA5B-4237-94CE-5B14BAF756C0}Lbl": Label 'GST Use Cases';
        "{B2CD61FA-9C30-4FE5-B5C5-5B535BA6DF96}Lbl": Label 'GST Use Cases';
        "{27255CC6-70FC-4D33-91F1-5B83F03CE33E}Lbl": Label 'GST Use Cases';
        "{8A18FA5B-AD17-43D3-8981-5BB20A04EFA2}Lbl": Label 'GST Use Cases';
        "{0027CF9D-DA15-43A2-83D4-5CD214E0278B}Lbl": Label 'GST Use Cases';
        "{015DD77D-3D2F-4B90-8C74-5CE5921E0C27}Lbl": Label 'GST Use Cases';
        "{BACBB54A-0D30-4206-AA6A-5CF48A744D5E}Lbl": Label 'GST Use Cases';
        "{895C47DF-89E2-4A14-9329-5E260C1DBF05}Lbl": Label 'GST Use Cases';
        "{F230C59A-547E-41CA-B6B9-5E8BE22A1BEF}Lbl": Label 'GST Use Cases';
        "{01289E18-40A0-4AC7-92DA-601F5AF77AA0}Lbl": Label 'GST Use Cases';
        "{0371699B-6B05-4B16-99FB-604F142308AA}Lbl": Label 'GST Use Cases';
        "{8503C963-7C87-45CD-8543-607AE516F9F8}Lbl": Label 'GST Use Cases';
        "{81E2ACA0-D6DD-4B4A-ADEF-60B602660F25}Lbl": Label 'GST Use Cases';
        "{01C97F7D-4263-4387-84E1-610D2EA4A762}Lbl": Label 'GST Use Cases';
        "{4CB6ACCD-BD47-4485-A757-62924EA09524}Lbl": Label 'GST Use Cases';
        "{9236A009-169D-4464-8B2C-62C94B782C26}Lbl": Label 'GST Use Cases';
        "{60F5C368-9B10-45CB-BB1B-63DEF7520AB6}Lbl": Label 'GST Use Cases';
        "{AF5EE023-63DF-4210-AD71-6436230F6DFA}Lbl": Label 'GST Use Cases';
        "{4D947EDC-3710-49D2-91D5-6446978D43EC}Lbl": Label 'GST Use Cases';
        "{CA856646-6B6F-42D2-A4CC-64A8F52DE9F6}Lbl": Label 'GST Use Cases';
        "{75F37BC7-AA5D-483D-A8A0-653E94AD6B8D}Lbl": Label 'GST Use Cases';
        "{04F944A1-EF9C-440F-A89B-654782D13EAA}Lbl": Label 'GST Use Cases';
        "{2AB850AD-528A-498A-9E23-65E396AC61A8}Lbl": Label 'GST Use Cases';
        "{F7C5C8B6-2EB3-478E-AE6B-66BEEB6A3861}Lbl": Label 'GST Use Cases';
        "{21957E13-9751-40A2-B591-67ADE93573E7}Lbl": Label 'GST Use Cases';
        "{A7F8D194-33DA-472D-87CB-693FB589CD45}Lbl": Label 'GST Use Cases';
        "{D95F6D4E-EEF5-41B7-8284-694BCBDFEABD}Lbl": Label 'GST Use Cases';
        "{B5669E1C-A496-431B-A29F-69E527E37AA0}Lbl": Label 'GST Use Cases';
        "{A734B9DD-A4C1-427E-AF18-6A8B27474F50}Lbl": Label 'GST Use Cases';
        "{7FD02BAE-DA8D-4100-962E-6A8F7FDE823C}Lbl": Label 'GST Use Cases';
        "{774A6E80-FBB4-4413-9144-6ACA8C6546D2}Lbl": Label 'GST Use Cases';
        "{98A43A23-24F8-4FC2-9D4E-6B45D74B02FB}Lbl": Label 'GST Use Cases';
        "{3F057D29-C926-453B-8B17-6B5E431A20B4}Lbl": Label 'GST Use Cases';
        "{7C3076A9-460B-41BC-AED8-6B615E4835D2}Lbl": Label 'GST Use Cases';
        "{31C539BE-990C-4E00-AF1A-6BFA1333ED7E}Lbl": Label 'GST Use Cases';
        "{CE4E5351-F5F5-413A-AAF9-6C5EA6530D93}Lbl": Label 'GST Use Cases';
        "{6946230A-A2F4-4E4B-90C6-6C907D010EB5}Lbl": Label 'GST Use Cases';
        "{C99A231E-6BBF-4982-AEAF-6CAAC7E5BA9B}Lbl": Label 'GST Use Cases';
        "{DB44587F-08FB-4D5F-96A3-6CD4D4E30300}Lbl": Label 'GST Use Cases';
        "{02B82B77-D7E5-4A49-89A2-6D46EC87AE61}Lbl": Label 'GST Use Cases';
        "{A8ED1A73-743C-4D08-98E3-6D85C416E951}Lbl": Label 'GST Use Cases';
        "{884574EB-3354-459C-AF96-6EB624CCEFFE}Lbl": Label 'GST Use Cases';
        "{6621F516-24B5-47CC-AB8B-6EF51F2616E3}Lbl": Label 'GST Use Cases';
        "{15A78CF5-A4CC-4804-95DA-6FB3DCBF2DBF}Lbl": Label 'GST Use Cases';
        "{960BC8FC-FF34-4E46-A6A0-6FD2CB7BBDA2}Lbl": Label 'GST Use Cases';
        "{144DB41F-813A-4EE0-87EC-7082D07652B7}Lbl": Label 'GST Use Cases';
        "{3C23CDAC-6995-4B6C-9E4B-708B540C413B}Lbl": Label 'GST Use Cases';
        "{B3036F44-2238-4DC9-B250-70AA3FEC7821}Lbl": Label 'GST Use Cases';
        "{7342ECF9-7916-4923-AC4C-71E973942346}Lbl": Label 'GST Use Cases';
        "{F9812F85-5C7A-41AC-8E1B-726669627637}Lbl": Label 'GST Use Cases';
        "{545DC1C5-C848-43B9-BFCE-72C3A45C94BA}Lbl": Label 'GST Use Cases';
        "{B68BAE5C-F887-46E8-9B4C-7333EB6152E0}Lbl": Label 'GST Use Cases';
        "{6FB5A46A-83C0-495F-9495-7365027603EA}Lbl": Label 'GST Use Cases';
        "{789CE492-C2BE-4EEC-8E98-740310FDD0E3}Lbl": Label 'GST Use Cases';
        "{B12DD0D6-A87C-4A8C-AE71-746B26156893}Lbl": Label 'GST Use Cases';
        "{C9854015-8E55-43F1-A5F2-747FC1CF6A0F}Lbl": Label 'GST Use Cases';
        "{70C3E4EB-0051-468C-A35C-748883F08A12}Lbl": Label 'GST Use Cases';
        "{20913086-F0CD-4AC8-AF0A-755723E44946}Lbl": Label 'GST Use Cases';
        "{CF175943-0F1A-4814-BF17-756FB88F497C}Lbl": Label 'GST Use Cases';
        "{0686E40E-9643-42C8-B4D1-7587447E98E0}Lbl": Label 'GST Use Cases';
        "{028465BA-B14C-4266-9D47-75A8087EE299}Lbl": Label 'GST Use Cases';
        "{AE2974C0-8A1D-4821-8999-7617690C41FC}Lbl": Label 'GST Use Cases';
        "{888E76DA-FA62-4714-83A3-76777E325D84}Lbl": Label 'GST Use Cases';
        "{0AAD1908-46DC-4370-8A8D-77096D9B30B0}Lbl": Label 'GST Use Cases';
        "{6B464955-261F-4EAF-A749-7807444FC37C}Lbl": Label 'GST Use Cases';
        "{EAD964E4-7CD1-4462-96B3-78A3FA9DE087}Lbl": Label 'GST Use Cases';
        "{62A4192A-86D8-4431-A641-78EF2F348546}Lbl": Label 'GST Use Cases';
        "{282C9335-DD37-49C9-9C60-7A0DB8A4B8F0}Lbl": Label 'GST Use Cases';
        "{2DA1B2DF-5B9F-4E93-8F99-7A26E87BB4A2}Lbl": Label 'GST Use Cases';
        "{2E369D91-2885-47EB-886E-7AD35816B42E}Lbl": Label 'GST Use Cases';
        "{F67095C1-F610-4B59-A1E5-7B58D83A6CF5}Lbl": Label 'GST Use Cases';
        "{B45F2436-2E00-4A49-9A8E-7B9202FE0F0A}Lbl": Label 'GST Use Cases';
        "{33896D17-0F26-4376-8304-7BA20BE4E6D4}Lbl": Label 'GST Use Cases';
        "{277B1053-C551-4BF4-9518-7BFE200A8E18}Lbl": Label 'GST Use Cases';
        "{073D94DC-E7F0-4535-B269-7C36C626FD96}Lbl": Label 'GST Use Cases';
        "{3DC33AD0-69AB-4B36-B58D-7C409957507C}Lbl": Label 'GST Use Cases';
        "{9F7A9C0A-BC4A-45C2-B79B-7D22EDB6ABBB}Lbl": Label 'GST Use Cases';
        "{18F45902-76C4-4B57-AF7F-7D9B3A76D51F}Lbl": Label 'GST Use Cases';
        "{EA146DA9-BB20-4A42-9C06-7E83FDF9F943}Lbl": Label 'GST Use Cases';
        "{B064E1CD-DB51-456E-AE19-7F2AC8C9DC11}Lbl": Label 'GST Use Cases';
        "{441D3A0A-1F6C-4F47-AC82-7F5E2782785D}Lbl": Label 'GST Use Cases';
        "{00B59093-4DB8-4152-99DB-7F9368A143A8}Lbl": Label 'GST Use Cases';
        "{9666CA08-2C56-43C5-B36F-7FD3745FE832}Lbl": Label 'GST Use Cases';
        "{61FB3B94-A2C7-4F3F-B4A8-801D842328E1}Lbl": Label 'GST Use Cases';
        "{C4BC4E11-E295-4A20-9F5F-801F2406A610}Lbl": Label 'GST Use Cases';
        "{DA389E3B-A6C3-4DE1-9843-807B2161B9DE}Lbl": Label 'GST Use Cases';
        "{8FDC8D41-E5D7-40D7-B962-80DA519596F3}Lbl": Label 'GST Use Cases';
        "{DB7C51C1-1F9F-40F2-82C2-82D59793413C}Lbl": Label 'GST Use Cases';
        "{C02EF3F0-A659-4762-854B-830A8D59B371}Lbl": Label 'GST Use Cases';
        "{6510FF1C-A0A5-4C52-8DE5-836BE2536650}Lbl": Label 'GST Use Cases';
        "{693D346E-069E-4306-9F7C-84665CD42141}Lbl": Label 'GST Use Cases';
        "{55AD5167-785F-4CC3-B633-84A8414EE100}Lbl": Label 'GST Use Cases';
        "{4C0ECC95-F5CD-46B2-B302-84C3A5AD7D4E}Lbl": Label 'GST Use Cases';
        "{E06B429C-0CDD-4F49-9C4D-8546151805AD}Lbl": Label 'GST Use Cases';
        "{E076372D-BFB5-4911-B6EE-85F1F71B1569}Lbl": Label 'GST Use Cases';
        "{1CB4368B-D6AF-4B89-AFEB-8641B0152451}Lbl": Label 'GST Use Cases';
        "{A4461039-C91C-4102-9438-866AF5607096}Lbl": Label 'GST Use Cases';
        "{38C5A554-206D-44A5-9090-86CAC52A7715}Lbl": Label 'GST Use Cases';
        "{B83A838B-C0A8-4E69-B735-86D011229B1C}Lbl": Label 'GST Use Cases';
        "{23B7CD0D-EA02-4835-9AE8-875813B138F0}Lbl": Label 'GST Use Cases';
        "{9DFF9CBE-B1A5-4D28-A855-8783315A87D0}Lbl": Label 'GST Use Cases';
        "{CCF41113-DC62-47E2-B45B-87AF0248AF65}Lbl": Label 'GST Use Cases';
        "{2CEB6A3E-11E4-420F-A3C6-886B920BEC29}Lbl": Label 'GST Use Cases';
        "{36017702-208F-4E8C-A75E-8872EA7D1205}Lbl": Label 'GST Use Cases';
        "{A8BF5AD2-5132-40E7-9DF1-893B3940F6EE}Lbl": Label 'GST Use Cases';
        "{990AEEEE-91BD-4C0E-8346-897F141E4EDB}Lbl": Label 'GST Use Cases';
        "{BBA0DF22-691B-46EB-8500-8B270596F2E9}Lbl": Label 'GST Use Cases';
        "{CFE77ACE-1F20-4126-98D9-8D14B18088EE}Lbl": Label 'GST Use Cases';
        "{A8FE6EC6-8FE0-42C6-AE40-8D3B2BC638C0}Lbl": Label 'GST Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{AFA9BC82-6757-44E3-B5E4-00029DACDA64}':
                exit("{AFA9BC82-6757-44E3-B5E4-00029DACDA64}Lbl");
            '{8EECE1FD-4BDB-4A37-92ED-00380C170CFC}':
                exit("{8EECE1FD-4BDB-4A37-92ED-00380C170CFC}Lbl");
            '{46054EB7-3CE7-421C-B047-00658AC5C150}':
                exit("{46054EB7-3CE7-421C-B047-00658AC5C150}Lbl");
            '{E9E7486C-DBFB-432C-886F-017AD828CE5E}':
                exit("{E9E7486C-DBFB-432C-886F-017AD828CE5E}Lbl");
            '{6D031AA1-2009-4D4A-A8E7-01D9116EDC5C}':
                exit("{6D031AA1-2009-4D4A-A8E7-01D9116EDC5C}Lbl");
            '{87FB95AD-905D-4832-9EC3-0330B674D601}':
                exit("{87FB95AD-905D-4832-9EC3-0330B674D601}Lbl");
            '{74601C3A-21C1-4924-950E-039ADD6086E6}':
                exit("{74601C3A-21C1-4924-950E-039ADD6086E6}Lbl");
            '{10675EE2-5AA7-4D43-8794-03BA8CD85445}':
                exit("{10675EE2-5AA7-4D43-8794-03BA8CD85445}Lbl");
            '{D2A96240-2F58-406C-8774-03CD60C28E5D}':
                exit("{D2A96240-2F58-406C-8774-03CD60C28E5D}Lbl");
            '{547DDC98-8D3C-46A0-84BE-03E71BA135DA}':
                exit("{547DDC98-8D3C-46A0-84BE-03E71BA135DA}Lbl");
        end;
        case CaseID of
            '{BBD37D0A-E328-4544-B5E1-03FCF65399D5}':
                exit("{BBD37D0A-E328-4544-B5E1-03FCF65399D5}Lbl");
            '{1C2FBFBD-A18B-4A5D-819E-043993E5510C}':
                exit("{1C2FBFBD-A18B-4A5D-819E-043993E5510C}Lbl");
            '{4684DF92-D578-4978-B4EC-04ACC07C8206}':
                exit("{4684DF92-D578-4978-B4EC-04ACC07C8206}Lbl");
            '{668C2032-DD90-4A23-8F30-04B69FE7C99E}':
                exit("{668C2032-DD90-4A23-8F30-04B69FE7C99E}Lbl");
            '{C89845E0-C8B1-45B1-9C1B-04EC264B7AC7}':
                exit("{C89845E0-C8B1-45B1-9C1B-04EC264B7AC7}Lbl");
            '{76F9EC4B-C6F3-4DBE-B1CA-04EFC5AD609E}':
                exit("{76F9EC4B-C6F3-4DBE-B1CA-04EFC5AD609E}Lbl");
            '{4AC1A712-CC9B-4CB7-91EA-05245C1D7211}':
                exit("{4AC1A712-CC9B-4CB7-91EA-05245C1D7211}Lbl");
            '{D9221422-669E-485D-8224-053D641FE4F3}':
                exit("{D9221422-669E-485D-8224-053D641FE4F3}Lbl");
            '{005ED1ED-F66A-4A08-8647-0554154F0DF2}':
                exit("{005ED1ED-F66A-4A08-8647-0554154F0DF2}Lbl");
            '{57322220-978A-459E-8EC5-05AB66E6B362}':
                exit("{57322220-978A-459E-8EC5-05AB66E6B362}Lbl");
        end;
        case CaseID of
            '{F807C5DC-40B1-4E22-AB49-06BC54A22558}':
                exit("{F807C5DC-40B1-4E22-AB49-06BC54A22558}Lbl");
            '{64233AA2-2DB0-4AC9-8078-0755AB5DA89D}':
                exit("{64233AA2-2DB0-4AC9-8078-0755AB5DA89D}Lbl");
            '{DD75810D-2D5B-438A-A3AB-079E1B1D7AB9}':
                exit("{DD75810D-2D5B-438A-A3AB-079E1B1D7AB9}Lbl");
            '{19FC1701-0FE4-4ED3-83B8-07DAB075A043}':
                exit("{19FC1701-0FE4-4ED3-83B8-07DAB075A043}Lbl");
            '{79839F30-7F44-4411-BB2D-07FFA294A38D}':
                exit("{79839F30-7F44-4411-BB2D-07FFA294A38D}Lbl");
            '{A59206F4-476D-4ED9-8665-08535755BB5E}':
                exit("{A59206F4-476D-4ED9-8665-08535755BB5E}Lbl");
            '{9B0FE6DB-6121-44B0-8BD0-08B8060D7A92}':
                exit("{9B0FE6DB-6121-44B0-8BD0-08B8060D7A92}Lbl");
            '{71EC1D59-01EC-4486-8CB4-0957D4ADF38B}':
                exit("{71EC1D59-01EC-4486-8CB4-0957D4ADF38B}Lbl");
            '{B5A9628F-46F5-48C4-9CC0-09CBAE26D7EE}':
                exit("{B5A9628F-46F5-48C4-9CC0-09CBAE26D7EE}Lbl");
            '{C75CF1E3-CC01-4458-86FB-0A29BC40560B}':
                exit("{C75CF1E3-CC01-4458-86FB-0A29BC40560B}Lbl");
        end;
        case CaseID of
            '{DA8B91D0-1B63-44EE-BA57-0A40B1403080}':
                exit("{DA8B91D0-1B63-44EE-BA57-0A40B1403080}Lbl");
            '{99F473AC-553E-4032-AEDB-0AE44C871CD2}':
                exit("{99F473AC-553E-4032-AEDB-0AE44C871CD2}Lbl");
            '{50157D1D-C080-4AF0-8C63-0B5E918F5AF2}':
                exit("{50157D1D-C080-4AF0-8C63-0B5E918F5AF2}Lbl");
            '{06F95F30-2C34-4CD2-9084-0B9101B9455D}':
                exit("{06F95F30-2C34-4CD2-9084-0B9101B9455D}Lbl");
            '{6F89240D-BBA1-4BB9-85B6-0BE2154EE0B8}':
                exit("{6F89240D-BBA1-4BB9-85B6-0BE2154EE0B8}Lbl");
            '{4A025601-FF3D-4BA6-A567-0C31785D0D36}':
                exit("{4A025601-FF3D-4BA6-A567-0C31785D0D36}Lbl");
            '{8638A2E3-3F44-4672-A54D-0D65B1528FF9}':
                exit("{8638A2E3-3F44-4672-A54D-0D65B1528FF9}Lbl");
            '{48C973FB-77C2-476C-AB39-0E61F0F76F0D}':
                exit("{48C973FB-77C2-476C-AB39-0E61F0F76F0D}Lbl");
            '{4A2B9E24-01A5-43C9-A43E-0E7C9CC1C8BB}':
                exit("{4A2B9E24-01A5-43C9-A43E-0E7C9CC1C8BB}Lbl");
            '{0FD2A76A-DECB-4FAC-8008-10D6762CDAFE}':
                exit("{0FD2A76A-DECB-4FAC-8008-10D6762CDAFE}Lbl");
        end;
        case CaseID of
            '{B90130D9-0471-4034-8687-11B04ABDCE72}':
                exit("{B90130D9-0471-4034-8687-11B04ABDCE72}Lbl");
            '{142D2618-98AC-4DD8-922F-11CF063DD8D8}':
                exit("{142D2618-98AC-4DD8-922F-11CF063DD8D8}Lbl");
            '{047704F8-A619-401F-9653-12103103E14A}':
                exit("{047704F8-A619-401F-9653-12103103E14A}Lbl");
            '{759DC0B3-0697-4262-B0B6-12AA4A6E3822}':
                exit("{759DC0B3-0697-4262-B0B6-12AA4A6E3822}Lbl");
            '{F6DED4E3-7405-4E6E-B0DF-1320041F130A}':
                exit("{F6DED4E3-7405-4E6E-B0DF-1320041F130A}Lbl");
            '{7E44665E-5E48-4F98-8E9A-135669D3E75B}':
                exit("{7E44665E-5E48-4F98-8E9A-135669D3E75B}Lbl");
            '{B618D919-C2A5-4BB8-B7EF-13784A51A6D5}':
                exit("{B618D919-C2A5-4BB8-B7EF-13784A51A6D5}Lbl");
            '{7AC16E57-E977-41B3-9338-1399811A688B}':
                exit("{7AC16E57-E977-41B3-9338-1399811A688B}Lbl");
            '{A48A1647-673E-4C77-9997-143963591989}':
                exit("{A48A1647-673E-4C77-9997-143963591989}Lbl");
            '{B053F5FC-CD93-4EA7-AC71-1590E006FAAE}':
                exit("{B053F5FC-CD93-4EA7-AC71-1590E006FAAE}Lbl");
        end;
        case CaseID of
            '{52FD8776-17C2-428A-B747-159404771D07}':
                exit("{52FD8776-17C2-428A-B747-159404771D07}Lbl");
            '{1201ECAE-F4F2-43D7-938E-15F5361C2062}':
                exit("{1201ECAE-F4F2-43D7-938E-15F5361C2062}Lbl");
            '{FEE41ACD-C7C4-4653-9A34-15F7F0B70663}':
                exit("{FEE41ACD-C7C4-4653-9A34-15F7F0B70663}Lbl");
            '{9607CA1C-5361-4206-A86E-162026F82D0C}':
                exit("{9607CA1C-5361-4206-A86E-162026F82D0C}Lbl");
            '{101CAF41-34AB-4EA1-9277-166954A7FF94}':
                exit("{101CAF41-34AB-4EA1-9277-166954A7FF94}Lbl");
            '{43228213-4CEA-41C4-B28B-170B00BC81A8}':
                exit("{43228213-4CEA-41C4-B28B-170B00BC81A8}Lbl");
            '{F5794DA7-0CC7-42C2-BEA0-18EB8F98BB5A}':
                exit("{F5794DA7-0CC7-42C2-BEA0-18EB8F98BB5A}Lbl");
            '{B2150DAA-4B46-41F2-89BF-19F5FD89362E}':
                exit("{B2150DAA-4B46-41F2-89BF-19F5FD89362E}Lbl");
            '{E411752D-2CC4-4CD4-9D35-1AE651319762}':
                exit("{E411752D-2CC4-4CD4-9D35-1AE651319762}Lbl");
            '{BE8902D9-72AA-41C9-BACE-1B781D7C8107}':
                exit("{BE8902D9-72AA-41C9-BACE-1B781D7C8107}Lbl");
        end;
        case CaseID of
            '{36710BC3-FED5-4726-8AB5-1DC108CF23AF}':
                exit("{36710BC3-FED5-4726-8AB5-1DC108CF23AF}Lbl");
            '{8E0D2716-6C6D-4CDF-863F-1E043223D7DF}':
                exit("{8E0D2716-6C6D-4CDF-863F-1E043223D7DF}Lbl");
            '{A9E13C42-F366-4E5F-A057-1E0B4E43D454}':
                exit("{A9E13C42-F366-4E5F-A057-1E0B4E43D454}Lbl");
            '{C6FDF908-18DE-47B6-ADED-1E654C153D2A}':
                exit("{C6FDF908-18DE-47B6-ADED-1E654C153D2A}Lbl");
            '{2E7A7A10-CCD5-4673-AF42-1EF83425931F}':
                exit("{2E7A7A10-CCD5-4673-AF42-1EF83425931F}Lbl");
            '{1C9C14DA-22A0-4F6B-968A-1F79BE11B7A1}':
                exit("{1C9C14DA-22A0-4F6B-968A-1F79BE11B7A1}Lbl");
            '{A485DD0E-AB08-49E5-9C7C-1FCA3398AE3F}':
                exit("{A485DD0E-AB08-49E5-9C7C-1FCA3398AE3F}Lbl");
            '{B6045C50-0B69-4DCE-B55D-20613A893341}':
                exit("{B6045C50-0B69-4DCE-B55D-20613A893341}Lbl");
            '{2A733D02-2125-4EA9-97E3-2068E5708A94}':
                exit("{2A733D02-2125-4EA9-97E3-2068E5708A94}Lbl");
            '{2341D31D-659B-4C70-B0FD-20C4494A4F1F}':
                exit("{2341D31D-659B-4C70-B0FD-20C4494A4F1F}Lbl");
        end;
        case CaseID of
            '{B69B4BDA-5CAC-4C9C-B4DB-211912D30EF2}':
                exit("{B69B4BDA-5CAC-4C9C-B4DB-211912D30EF2}Lbl");
            '{4962D3B9-0349-4BE9-B173-22B456AEE6C6}':
                exit("{4962D3B9-0349-4BE9-B173-22B456AEE6C6}Lbl");
            '{AEDED96A-9927-4DF4-B89B-22FA7C77C19F}':
                exit("{AEDED96A-9927-4DF4-B89B-22FA7C77C19F}Lbl");
            '{11160E03-89D0-481D-B2EA-24898F3DB4AB}':
                exit("{11160E03-89D0-481D-B2EA-24898F3DB4AB}Lbl");
            '{B4662B2E-9E63-4BA7-A683-248E5811B566}':
                exit("{B4662B2E-9E63-4BA7-A683-248E5811B566}Lbl");
            '{9639222B-DFA8-4F14-9A72-24E994C1C7DA}':
                exit("{9639222B-DFA8-4F14-9A72-24E994C1C7DA}Lbl");
            '{99C83819-83BC-418A-A2A7-26A041F2F99A}':
                exit("{99C83819-83BC-418A-A2A7-26A041F2F99A}Lbl");
            '{8E46C7A8-FFB5-40D2-8DBB-26E9FEDDF17D}':
                exit("{8E46C7A8-FFB5-40D2-8DBB-26E9FEDDF17D}Lbl");
            '{EC905260-0D39-42CD-ADAE-27F4E74CE267}':
                exit("{EC905260-0D39-42CD-ADAE-27F4E74CE267}Lbl");
            '{85D7B57B-6657-4C5B-889D-282A48B9D0FB}':
                exit("{85D7B57B-6657-4C5B-889D-282A48B9D0FB}Lbl");
        end;
        case CaseID of
            '{B61CB389-28BD-4569-BF95-284B62972B23}':
                exit("{B61CB389-28BD-4569-BF95-284B62972B23}Lbl");
            '{C07C2110-2740-4FAD-975B-293FAAD86247}':
                exit("{C07C2110-2740-4FAD-975B-293FAAD86247}Lbl");
            '{F719A304-09CF-479B-A123-2A4E34ED3133}':
                exit("{F719A304-09CF-479B-A123-2A4E34ED3133}Lbl");
            '{AA1B2E3A-4149-4352-B081-2A869CDE5353}':
                exit("{AA1B2E3A-4149-4352-B081-2A869CDE5353}Lbl");
            '{8D0E6401-974F-4F8E-9254-2AF9067E73DC}':
                exit("{8D0E6401-974F-4F8E-9254-2AF9067E73DC}Lbl");
            '{41F1CFC3-B9F5-464D-9B6D-2C7B6C83186C}':
                exit("{41F1CFC3-B9F5-464D-9B6D-2C7B6C83186C}Lbl");
            '{97664A61-096E-43D9-BF55-2D5672F02F7F}':
                exit("{97664A61-096E-43D9-BF55-2D5672F02F7F}Lbl");
            '{52BFB82F-A54A-4E62-9DC3-2D608D6373B0}':
                exit("{52BFB82F-A54A-4E62-9DC3-2D608D6373B0}Lbl");
            '{529A1457-1F3B-412A-87D0-2EA18CA27186}':
                exit("{529A1457-1F3B-412A-87D0-2EA18CA27186}Lbl");
            '{246B0F60-6CA4-42A1-ACDD-30C38C89D2C4}':
                exit("{246B0F60-6CA4-42A1-ACDD-30C38C89D2C4}Lbl");
        end;
        case CaseID of
            '{53AA1183-8DEC-4542-A708-317C5CD7BDA9}':
                exit("{53AA1183-8DEC-4542-A708-317C5CD7BDA9}Lbl");
            '{A7ED2E31-2CA7-4D60-A415-31A78736388D}':
                exit("{A7ED2E31-2CA7-4D60-A415-31A78736388D}Lbl");
            '{78DCCF81-7548-4028-A6AF-31AEB633FC3C}':
                exit("{78DCCF81-7548-4028-A6AF-31AEB633FC3C}Lbl");
            '{64F0C586-3993-4F05-A127-332E7E46802D}':
                exit("{64F0C586-3993-4F05-A127-332E7E46802D}Lbl");
            '{A106F715-2EC1-43B7-B0AE-33F6AEEF3B2A}':
                exit("{A106F715-2EC1-43B7-B0AE-33F6AEEF3B2A}Lbl");
            '{21A349A2-B069-4AA5-86B9-34136BE37267}':
                exit("{21A349A2-B069-4AA5-86B9-34136BE37267}Lbl");
            '{9167AE32-6B66-48FB-AF03-35D261A7C5BC}':
                exit("{9167AE32-6B66-48FB-AF03-35D261A7C5BC}Lbl");
            '{4C815B8B-6831-4E19-899D-361FBA9CFC43}':
                exit("{4C815B8B-6831-4E19-899D-361FBA9CFC43}Lbl");
            '{62CA4077-63DB-4812-8DBA-369BDD0A5A63}':
                exit("{62CA4077-63DB-4812-8DBA-369BDD0A5A63}Lbl");
            '{149E867B-BE67-4BA4-AE3B-36C10F7552F5}':
                exit("{149E867B-BE67-4BA4-AE3B-36C10F7552F5}Lbl");
        end;
        case CaseID of
            '{3EEDD099-9182-42DE-BBF0-385833BC88BE}':
                exit("{3EEDD099-9182-42DE-BBF0-385833BC88BE}Lbl");
            '{6856A59C-FE7F-4DDA-B180-391F6E0D0A5F}':
                exit("{6856A59C-FE7F-4DDA-B180-391F6E0D0A5F}Lbl");
            '{F0453435-C2EF-43BB-BC81-39454E1DE4B9}':
                exit("{F0453435-C2EF-43BB-BC81-39454E1DE4B9}Lbl");
            '{81A24E9D-52B9-4EFE-A18B-398C6BAD55ED}':
                exit("{81A24E9D-52B9-4EFE-A18B-398C6BAD55ED}Lbl");
            '{0120B543-BBCA-433A-B84D-3A07CA4BD763}':
                exit("{0120B543-BBCA-433A-B84D-3A07CA4BD763}Lbl");
            '{97856AB0-DAB0-4CF3-B1B1-3A6EB1524E0F}':
                exit("{97856AB0-DAB0-4CF3-B1B1-3A6EB1524E0F}Lbl");
            '{DF8067FF-2F97-485F-8364-3AC5536AD82D}':
                exit("{DF8067FF-2F97-485F-8364-3AC5536AD82D}Lbl");
            '{9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B}':
                exit("{9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B}Lbl");
            '{09E58D68-C9B5-4A27-B4FE-3BCA8B383E14}':
                exit("{09E58D68-C9B5-4A27-B4FE-3BCA8B383E14}Lbl");
            '{25E8E204-2E63-4B79-824C-3C1185D6467C}':
                exit("{25E8E204-2E63-4B79-824C-3C1185D6467C}Lbl");
        end;
        case CaseID of
            '{46AD3622-5D72-4048-9FAC-3C31077C2DF0}':
                exit("{46AD3622-5D72-4048-9FAC-3C31077C2DF0}Lbl");
            '{F7D97DC6-CF0E-4248-95A3-3C7189BF844D}':
                exit("{F7D97DC6-CF0E-4248-95A3-3C7189BF844D}Lbl");
            '{24F69259-FD27-49A7-B5E8-3CBF5351132F}':
                exit("{24F69259-FD27-49A7-B5E8-3CBF5351132F}Lbl");
            '{97CF7642-AB0E-4686-A5CE-3D7C7C641E7E}':
                exit("{97CF7642-AB0E-4686-A5CE-3D7C7C641E7E}Lbl");
            '{7627B9EF-CB23-4EAB-88D9-3D894B6F6607}':
                exit("{7627B9EF-CB23-4EAB-88D9-3D894B6F6607}Lbl");
            '{4F234B8B-1B95-4938-B3DF-3D96784EAC77}':
                exit("{4F234B8B-1B95-4938-B3DF-3D96784EAC77}Lbl");
            '{F8D35423-18AA-4916-A10C-3DC5A6F80CB0}':
                exit("{F8D35423-18AA-4916-A10C-3DC5A6F80CB0}Lbl");
            '{C8AEE991-4EDD-4562-BCE7-3DFA3502C8D2}':
                exit("{C8AEE991-4EDD-4562-BCE7-3DFA3502C8D2}Lbl");
            '{15E17CFF-8262-4E83-8FD4-3EC012EEA465}':
                exit("{15E17CFF-8262-4E83-8FD4-3EC012EEA465}Lbl");
            '{96B76AC2-66FF-4457-9DE3-3F2A3213C3E6}':
                exit("{96B76AC2-66FF-4457-9DE3-3F2A3213C3E6}Lbl");
        end;
        case CaseID of
            '{11784DD8-7EF0-42CF-9A18-401A9ABC6466}':
                exit("{11784DD8-7EF0-42CF-9A18-401A9ABC6466}Lbl");
            '{26581492-A8D9-41EB-B84E-40671AE8CC3C}':
                exit("{26581492-A8D9-41EB-B84E-40671AE8CC3C}Lbl");
            '{E6B27281-EC3F-4040-B035-4179D33884CE}':
                exit("{E6B27281-EC3F-4040-B035-4179D33884CE}Lbl");
            '{F14B809C-31CA-4B7D-989E-419B00D35F8F}':
                exit("{F14B809C-31CA-4B7D-989E-419B00D35F8F}Lbl");
            '{7E182C87-669C-4CD8-8336-41C2ABE6144C}':
                exit("{7E182C87-669C-4CD8-8336-41C2ABE6144C}Lbl");
            '{7307BDA2-283F-4094-82E0-41EC241CE177}':
                exit("{7307BDA2-283F-4094-82E0-41EC241CE177}Lbl");
            '{536EFB4F-1EBC-4731-861E-433F3BA23A4A}':
                exit("{536EFB4F-1EBC-4731-861E-433F3BA23A4A}Lbl");
            '{80BC1B3E-DB26-4E90-B780-43C8BA593655}':
                exit("{80BC1B3E-DB26-4E90-B780-43C8BA593655}Lbl");
            '{C211C520-8428-4E89-8A9A-446A5EC41D39}':
                exit("{C211C520-8428-4E89-8A9A-446A5EC41D39}Lbl");
            '{C9ED5F18-07B9-43AF-9221-448B962EC9CD}':
                exit("{C9ED5F18-07B9-43AF-9221-448B962EC9CD}Lbl");
        end;
        case CaseID of
            '{ABD1A54F-36DA-45A7-AFED-451B98434B0C}':
                exit("{ABD1A54F-36DA-45A7-AFED-451B98434B0C}Lbl");
            '{F4B17FC7-3605-47DD-804E-4573BCB3FAC7}':
                exit("{F4B17FC7-3605-47DD-804E-4573BCB3FAC7}Lbl");
            '{8EC585FC-1F0E-4A31-A28A-463F3239EB57}':
                exit("{8EC585FC-1F0E-4A31-A28A-463F3239EB57}Lbl");
            '{4001BD59-B35E-4BBC-B7AD-464FBB21E54A}':
                exit("{4001BD59-B35E-4BBC-B7AD-464FBB21E54A}Lbl");
            '{E530DADD-215F-47FF-8A84-46A1E62353CF}':
                exit("{E530DADD-215F-47FF-8A84-46A1E62353CF}Lbl");
            '{EB169AE5-8DE0-4490-8DFD-46CEE05AA5C1}':
                exit("{EB169AE5-8DE0-4490-8DFD-46CEE05AA5C1}Lbl");
            '{710042C6-833D-4CF4-B943-47CF6691F7DE}':
                exit("{710042C6-833D-4CF4-B943-47CF6691F7DE}Lbl");
            '{34D0EE0E-FC73-416C-A59C-484107E36965}':
                exit("{34D0EE0E-FC73-416C-A59C-484107E36965}Lbl");
            '{F52FFF81-A64B-4A23-B699-49E370AB59F0}':
                exit("{F52FFF81-A64B-4A23-B699-49E370AB59F0}Lbl");
            '{95551286-5BF2-42D5-895A-4A4F450A424B}':
                exit("{95551286-5BF2-42D5-895A-4A4F450A424B}Lbl");
        end;
        case CaseID of
            '{5B85FA47-8603-4A7F-9B76-4A5AD999CA81}':
                exit("{5B85FA47-8603-4A7F-9B76-4A5AD999CA81}Lbl");
            '{5C3AA147-EDD0-4271-9CB8-4A6F6C98962A}':
                exit("{5C3AA147-EDD0-4271-9CB8-4A6F6C98962A}Lbl");
            '{E35E188E-728D-42BE-94F0-4B0476315B0B}':
                exit("{E35E188E-728D-42BE-94F0-4B0476315B0B}Lbl");
            '{887FEE8B-EFB6-4010-B79B-4CDB44F23CC8}':
                exit("{887FEE8B-EFB6-4010-B79B-4CDB44F23CC8}Lbl");
            '{AF9D718A-2832-4D92-A195-4D7DD81E2029}':
                exit("{AF9D718A-2832-4D92-A195-4D7DD81E2029}Lbl");
            '{4753502A-0359-4A8C-A37C-4DB4B6FCD790}':
                exit("{4753502A-0359-4A8C-A37C-4DB4B6FCD790}Lbl");
            '{5F9FDC49-A99D-4F72-AA5F-4E0BF5B3AC34}':
                exit("{5F9FDC49-A99D-4F72-AA5F-4E0BF5B3AC34}Lbl");
            '{8F88FDD0-561E-4FEA-A663-4F4BAEC9D009}':
                exit("{8F88FDD0-561E-4FEA-A663-4F4BAEC9D009}Lbl");
            '{6A72F56C-CA49-4D53-939A-4FABC050BFB3}':
                exit("{6A72F56C-CA49-4D53-939A-4FABC050BFB3}Lbl");
            '{2653A4AF-CD57-4A29-B4C2-4FE3749AC4AD}':
                exit("{2653A4AF-CD57-4A29-B4C2-4FE3749AC4AD}Lbl");
        end;
        case CaseID of
            '{2C80FA78-CBBE-45E7-8C62-5010B692AC9C}':
                exit("{2C80FA78-CBBE-45E7-8C62-5010B692AC9C}Lbl");
            '{A56AAD73-6807-47CF-BB9C-501BD61D691D}':
                exit("{A56AAD73-6807-47CF-BB9C-501BD61D691D}Lbl");
            '{C915C6D6-9C5D-4C2F-BAB6-50E13850581E}':
                exit("{C915C6D6-9C5D-4C2F-BAB6-50E13850581E}Lbl");
            '{FEB751CF-3E8D-42AB-965E-51097FF60E64}':
                exit("{FEB751CF-3E8D-42AB-965E-51097FF60E64}Lbl");
            '{8E2CB0E2-795D-4DC3-879B-5117E415DFB9}':
                exit("{8E2CB0E2-795D-4DC3-879B-5117E415DFB9}Lbl");
            '{118F40D5-2D0E-45D6-B458-52D6BF00A035}':
                exit("{118F40D5-2D0E-45D6-B458-52D6BF00A035}Lbl");
            '{CCF91681-45AA-45DC-94A6-52DBBF199CF5}':
                exit("{CCF91681-45AA-45DC-94A6-52DBBF199CF5}Lbl");
            '{44F4B3DF-4625-4E8F-9BE3-53C61B67463B}':
                exit("{44F4B3DF-4625-4E8F-9BE3-53C61B67463B}Lbl");
            '{64A2BCC0-3E88-4613-B91D-540FF4977F86}':
                exit("{64A2BCC0-3E88-4613-B91D-540FF4977F86}Lbl");
            '{5E1C6C44-CCBA-49ED-AD64-54D360467B0F}':
                exit("{5E1C6C44-CCBA-49ED-AD64-54D360467B0F}Lbl");
        end;
        case CaseID of
            '{7ABC67E5-F6F0-4ECB-9634-55258429DFD8}':
                exit("{7ABC67E5-F6F0-4ECB-9634-55258429DFD8}Lbl");
            '{A9D34135-2984-4C5D-99C0-5563408C59EE}':
                exit("{A9D34135-2984-4C5D-99C0-5563408C59EE}Lbl");
            '{137A0843-A280-441F-8D87-5639EDB2B01E}':
                exit("{137A0843-A280-441F-8D87-5639EDB2B01E}Lbl");
            '{26ED31B0-75B8-439C-8E16-56518665184F}':
                exit("{26ED31B0-75B8-439C-8E16-56518665184F}Lbl");
            '{09CD7163-15FB-4340-82BF-57373BE3E206}':
                exit("{09CD7163-15FB-4340-82BF-57373BE3E206}Lbl");
            '{975372FC-F93D-4E8B-81EA-57B6751B9F94}':
                exit("{975372FC-F93D-4E8B-81EA-57B6751B9F94}Lbl");
            '{AA215442-D318-4160-A666-57E3FBE06CDD}':
                exit("{AA215442-D318-4160-A666-57E3FBE06CDD}Lbl");
            '{93FE03BD-63C7-44B5-B40D-5974C8300527}':
                exit("{93FE03BD-63C7-44B5-B40D-5974C8300527}Lbl");
            '{819CADCF-BE64-4BC6-93BA-59EDE239EB54}':
                exit("{819CADCF-BE64-4BC6-93BA-59EDE239EB54}Lbl");
            '{3335E143-1F90-4E63-B6E7-5A4897019FFA}':
                exit("{3335E143-1F90-4E63-B6E7-5A4897019FFA}Lbl");
        end;
        case CaseID of
            '{D0EADC0B-CBC1-4E07-8ADF-5AE168893B04}':
                exit("{D0EADC0B-CBC1-4E07-8ADF-5AE168893B04}Lbl");
            '{D1629C9B-AA5B-4237-94CE-5B14BAF756C0}':
                exit("{D1629C9B-AA5B-4237-94CE-5B14BAF756C0}Lbl");
            '{B2CD61FA-9C30-4FE5-B5C5-5B535BA6DF96}':
                exit("{B2CD61FA-9C30-4FE5-B5C5-5B535BA6DF96}Lbl");
            '{27255CC6-70FC-4D33-91F1-5B83F03CE33E}':
                exit("{27255CC6-70FC-4D33-91F1-5B83F03CE33E}Lbl");
            '{8A18FA5B-AD17-43D3-8981-5BB20A04EFA2}':
                exit("{8A18FA5B-AD17-43D3-8981-5BB20A04EFA2}Lbl");
            '{0027CF9D-DA15-43A2-83D4-5CD214E0278B}':
                exit("{0027CF9D-DA15-43A2-83D4-5CD214E0278B}Lbl");
            '{015DD77D-3D2F-4B90-8C74-5CE5921E0C27}':
                exit("{015DD77D-3D2F-4B90-8C74-5CE5921E0C27}Lbl");
            '{BACBB54A-0D30-4206-AA6A-5CF48A744D5E}':
                exit("{BACBB54A-0D30-4206-AA6A-5CF48A744D5E}Lbl");
            '{895C47DF-89E2-4A14-9329-5E260C1DBF05}':
                exit("{895C47DF-89E2-4A14-9329-5E260C1DBF05}Lbl");
            '{F230C59A-547E-41CA-B6B9-5E8BE22A1BEF}':
                exit("{F230C59A-547E-41CA-B6B9-5E8BE22A1BEF}Lbl");
        end;
        case CaseID of
            '{01289E18-40A0-4AC7-92DA-601F5AF77AA0}':
                exit("{01289E18-40A0-4AC7-92DA-601F5AF77AA0}Lbl");
            '{0371699B-6B05-4B16-99FB-604F142308AA}':
                exit("{0371699B-6B05-4B16-99FB-604F142308AA}Lbl");
            '{8503C963-7C87-45CD-8543-607AE516F9F8}':
                exit("{8503C963-7C87-45CD-8543-607AE516F9F8}Lbl");
            '{81E2ACA0-D6DD-4B4A-ADEF-60B602660F25}':
                exit("{81E2ACA0-D6DD-4B4A-ADEF-60B602660F25}Lbl");
            '{01C97F7D-4263-4387-84E1-610D2EA4A762}':
                exit("{01C97F7D-4263-4387-84E1-610D2EA4A762}Lbl");
            '{4CB6ACCD-BD47-4485-A757-62924EA09524}':
                exit("{4CB6ACCD-BD47-4485-A757-62924EA09524}Lbl");
            '{9236A009-169D-4464-8B2C-62C94B782C26}':
                exit("{9236A009-169D-4464-8B2C-62C94B782C26}Lbl");
            '{60F5C368-9B10-45CB-BB1B-63DEF7520AB6}':
                exit("{60F5C368-9B10-45CB-BB1B-63DEF7520AB6}Lbl");
            '{AF5EE023-63DF-4210-AD71-6436230F6DFA}':
                exit("{AF5EE023-63DF-4210-AD71-6436230F6DFA}Lbl");
            '{4D947EDC-3710-49D2-91D5-6446978D43EC}':
                exit("{4D947EDC-3710-49D2-91D5-6446978D43EC}Lbl");
        end;
        case CaseID of
            '{CA856646-6B6F-42D2-A4CC-64A8F52DE9F6}':
                exit("{CA856646-6B6F-42D2-A4CC-64A8F52DE9F6}Lbl");
            '{75F37BC7-AA5D-483D-A8A0-653E94AD6B8D}':
                exit("{75F37BC7-AA5D-483D-A8A0-653E94AD6B8D}Lbl");
            '{04F944A1-EF9C-440F-A89B-654782D13EAA}':
                exit("{04F944A1-EF9C-440F-A89B-654782D13EAA}Lbl");
            '{2AB850AD-528A-498A-9E23-65E396AC61A8}':
                exit("{2AB850AD-528A-498A-9E23-65E396AC61A8}Lbl");
            '{F7C5C8B6-2EB3-478E-AE6B-66BEEB6A3861}':
                exit("{F7C5C8B6-2EB3-478E-AE6B-66BEEB6A3861}Lbl");
            '{21957E13-9751-40A2-B591-67ADE93573E7}':
                exit("{21957E13-9751-40A2-B591-67ADE93573E7}Lbl");
            '{A7F8D194-33DA-472D-87CB-693FB589CD45}':
                exit("{A7F8D194-33DA-472D-87CB-693FB589CD45}Lbl");
            '{D95F6D4E-EEF5-41B7-8284-694BCBDFEABD}':
                exit("{D95F6D4E-EEF5-41B7-8284-694BCBDFEABD}Lbl");
            '{B5669E1C-A496-431B-A29F-69E527E37AA0}':
                exit("{B5669E1C-A496-431B-A29F-69E527E37AA0}Lbl");
            '{A734B9DD-A4C1-427E-AF18-6A8B27474F50}':
                exit("{A734B9DD-A4C1-427E-AF18-6A8B27474F50}Lbl");
        end;
        case CaseID of
            '{7FD02BAE-DA8D-4100-962E-6A8F7FDE823C}':
                exit("{7FD02BAE-DA8D-4100-962E-6A8F7FDE823C}Lbl");
            '{774A6E80-FBB4-4413-9144-6ACA8C6546D2}':
                exit("{774A6E80-FBB4-4413-9144-6ACA8C6546D2}Lbl");
            '{98A43A23-24F8-4FC2-9D4E-6B45D74B02FB}':
                exit("{98A43A23-24F8-4FC2-9D4E-6B45D74B02FB}Lbl");
            '{3F057D29-C926-453B-8B17-6B5E431A20B4}':
                exit("{3F057D29-C926-453B-8B17-6B5E431A20B4}Lbl");
            '{7C3076A9-460B-41BC-AED8-6B615E4835D2}':
                exit("{7C3076A9-460B-41BC-AED8-6B615E4835D2}Lbl");
            '{31C539BE-990C-4E00-AF1A-6BFA1333ED7E}':
                exit("{31C539BE-990C-4E00-AF1A-6BFA1333ED7E}Lbl");
            '{CE4E5351-F5F5-413A-AAF9-6C5EA6530D93}':
                exit("{CE4E5351-F5F5-413A-AAF9-6C5EA6530D93}Lbl");
            '{6946230A-A2F4-4E4B-90C6-6C907D010EB5}':
                exit("{6946230A-A2F4-4E4B-90C6-6C907D010EB5}Lbl");
            '{C99A231E-6BBF-4982-AEAF-6CAAC7E5BA9B}':
                exit("{C99A231E-6BBF-4982-AEAF-6CAAC7E5BA9B}Lbl");
            '{DB44587F-08FB-4D5F-96A3-6CD4D4E30300}':
                exit("{DB44587F-08FB-4D5F-96A3-6CD4D4E30300}Lbl");
        end;
        case CaseID of
            '{02B82B77-D7E5-4A49-89A2-6D46EC87AE61}':
                exit("{02B82B77-D7E5-4A49-89A2-6D46EC87AE61}Lbl");
            '{A8ED1A73-743C-4D08-98E3-6D85C416E951}':
                exit("{A8ED1A73-743C-4D08-98E3-6D85C416E951}Lbl");
            '{884574EB-3354-459C-AF96-6EB624CCEFFE}':
                exit("{884574EB-3354-459C-AF96-6EB624CCEFFE}Lbl");
            '{6621F516-24B5-47CC-AB8B-6EF51F2616E3}':
                exit("{6621F516-24B5-47CC-AB8B-6EF51F2616E3}Lbl");
            '{15A78CF5-A4CC-4804-95DA-6FB3DCBF2DBF}':
                exit("{15A78CF5-A4CC-4804-95DA-6FB3DCBF2DBF}Lbl");
            '{960BC8FC-FF34-4E46-A6A0-6FD2CB7BBDA2}':
                exit("{960BC8FC-FF34-4E46-A6A0-6FD2CB7BBDA2}Lbl");
            '{144DB41F-813A-4EE0-87EC-7082D07652B7}':
                exit("{144DB41F-813A-4EE0-87EC-7082D07652B7}Lbl");
            '{3C23CDAC-6995-4B6C-9E4B-708B540C413B}':
                exit("{3C23CDAC-6995-4B6C-9E4B-708B540C413B}Lbl");
            '{B3036F44-2238-4DC9-B250-70AA3FEC7821}':
                exit("{B3036F44-2238-4DC9-B250-70AA3FEC7821}Lbl");
            '{7342ECF9-7916-4923-AC4C-71E973942346}':
                exit("{7342ECF9-7916-4923-AC4C-71E973942346}Lbl");
        end;
        case CaseID of
            '{F9812F85-5C7A-41AC-8E1B-726669627637}':
                exit("{F9812F85-5C7A-41AC-8E1B-726669627637}Lbl");
            '{545DC1C5-C848-43B9-BFCE-72C3A45C94BA}':
                exit("{545DC1C5-C848-43B9-BFCE-72C3A45C94BA}Lbl");
            '{B68BAE5C-F887-46E8-9B4C-7333EB6152E0}':
                exit("{B68BAE5C-F887-46E8-9B4C-7333EB6152E0}Lbl");
            '{6FB5A46A-83C0-495F-9495-7365027603EA}':
                exit("{6FB5A46A-83C0-495F-9495-7365027603EA}Lbl");
            '{789CE492-C2BE-4EEC-8E98-740310FDD0E3}':
                exit("{789CE492-C2BE-4EEC-8E98-740310FDD0E3}Lbl");
            '{B12DD0D6-A87C-4A8C-AE71-746B26156893}':
                exit("{B12DD0D6-A87C-4A8C-AE71-746B26156893}Lbl");
            '{C9854015-8E55-43F1-A5F2-747FC1CF6A0F}':
                exit("{C9854015-8E55-43F1-A5F2-747FC1CF6A0F}Lbl");
            '{70C3E4EB-0051-468C-A35C-748883F08A12}':
                exit("{70C3E4EB-0051-468C-A35C-748883F08A12}Lbl");
            '{20913086-F0CD-4AC8-AF0A-755723E44946}':
                exit("{20913086-F0CD-4AC8-AF0A-755723E44946}Lbl");
            '{CF175943-0F1A-4814-BF17-756FB88F497C}':
                exit("{CF175943-0F1A-4814-BF17-756FB88F497C}Lbl");
        end;
        case CaseID of
            '{0686E40E-9643-42C8-B4D1-7587447E98E0}':
                exit("{0686E40E-9643-42C8-B4D1-7587447E98E0}Lbl");
            '{028465BA-B14C-4266-9D47-75A8087EE299}':
                exit("{028465BA-B14C-4266-9D47-75A8087EE299}Lbl");
            '{AE2974C0-8A1D-4821-8999-7617690C41FC}':
                exit("{AE2974C0-8A1D-4821-8999-7617690C41FC}Lbl");
            '{888E76DA-FA62-4714-83A3-76777E325D84}':
                exit("{888E76DA-FA62-4714-83A3-76777E325D84}Lbl");
            '{0AAD1908-46DC-4370-8A8D-77096D9B30B0}':
                exit("{0AAD1908-46DC-4370-8A8D-77096D9B30B0}Lbl");
            '{6B464955-261F-4EAF-A749-7807444FC37C}':
                exit("{6B464955-261F-4EAF-A749-7807444FC37C}Lbl");
            '{EAD964E4-7CD1-4462-96B3-78A3FA9DE087}':
                exit("{EAD964E4-7CD1-4462-96B3-78A3FA9DE087}Lbl");
            '{62A4192A-86D8-4431-A641-78EF2F348546}':
                exit("{62A4192A-86D8-4431-A641-78EF2F348546}Lbl");
            '{282C9335-DD37-49C9-9C60-7A0DB8A4B8F0}':
                exit("{282C9335-DD37-49C9-9C60-7A0DB8A4B8F0}Lbl");
            '{2DA1B2DF-5B9F-4E93-8F99-7A26E87BB4A2}':
                exit("{2DA1B2DF-5B9F-4E93-8F99-7A26E87BB4A2}Lbl");
        end;
        case CaseID of
            '{2E369D91-2885-47EB-886E-7AD35816B42E}':
                exit("{2E369D91-2885-47EB-886E-7AD35816B42E}Lbl");
            '{F67095C1-F610-4B59-A1E5-7B58D83A6CF5}':
                exit("{F67095C1-F610-4B59-A1E5-7B58D83A6CF5}Lbl");
            '{B45F2436-2E00-4A49-9A8E-7B9202FE0F0A}':
                exit("{B45F2436-2E00-4A49-9A8E-7B9202FE0F0A}Lbl");
            '{33896D17-0F26-4376-8304-7BA20BE4E6D4}':
                exit("{33896D17-0F26-4376-8304-7BA20BE4E6D4}Lbl");
            '{277B1053-C551-4BF4-9518-7BFE200A8E18}':
                exit("{277B1053-C551-4BF4-9518-7BFE200A8E18}Lbl");
            '{073D94DC-E7F0-4535-B269-7C36C626FD96}':
                exit("{073D94DC-E7F0-4535-B269-7C36C626FD96}Lbl");
            '{3DC33AD0-69AB-4B36-B58D-7C409957507C}':
                exit("{3DC33AD0-69AB-4B36-B58D-7C409957507C}Lbl");
            '{9F7A9C0A-BC4A-45C2-B79B-7D22EDB6ABBB}':
                exit("{9F7A9C0A-BC4A-45C2-B79B-7D22EDB6ABBB}Lbl");
            '{18F45902-76C4-4B57-AF7F-7D9B3A76D51F}':
                exit("{18F45902-76C4-4B57-AF7F-7D9B3A76D51F}Lbl");
            '{EA146DA9-BB20-4A42-9C06-7E83FDF9F943}':
                exit("{EA146DA9-BB20-4A42-9C06-7E83FDF9F943}Lbl");
        end;
        case CaseID of
            '{B064E1CD-DB51-456E-AE19-7F2AC8C9DC11}':
                exit("{B064E1CD-DB51-456E-AE19-7F2AC8C9DC11}Lbl");
            '{441D3A0A-1F6C-4F47-AC82-7F5E2782785D}':
                exit("{441D3A0A-1F6C-4F47-AC82-7F5E2782785D}Lbl");
            '{00B59093-4DB8-4152-99DB-7F9368A143A8}':
                exit("{00B59093-4DB8-4152-99DB-7F9368A143A8}Lbl");
            '{9666CA08-2C56-43C5-B36F-7FD3745FE832}':
                exit("{9666CA08-2C56-43C5-B36F-7FD3745FE832}Lbl");
            '{61FB3B94-A2C7-4F3F-B4A8-801D842328E1}':
                exit("{61FB3B94-A2C7-4F3F-B4A8-801D842328E1}Lbl");
            '{C4BC4E11-E295-4A20-9F5F-801F2406A610}':
                exit("{C4BC4E11-E295-4A20-9F5F-801F2406A610}Lbl");
            '{DA389E3B-A6C3-4DE1-9843-807B2161B9DE}':
                exit("{DA389E3B-A6C3-4DE1-9843-807B2161B9DE}Lbl");
            '{8FDC8D41-E5D7-40D7-B962-80DA519596F3}':
                exit("{8FDC8D41-E5D7-40D7-B962-80DA519596F3}Lbl");
            '{DB7C51C1-1F9F-40F2-82C2-82D59793413C}':
                exit("{DB7C51C1-1F9F-40F2-82C2-82D59793413C}Lbl");
            '{C02EF3F0-A659-4762-854B-830A8D59B371}':
                exit("{C02EF3F0-A659-4762-854B-830A8D59B371}Lbl");
        end;
        case CaseID of
            '{6510FF1C-A0A5-4C52-8DE5-836BE2536650}':
                exit("{6510FF1C-A0A5-4C52-8DE5-836BE2536650}Lbl");
            '{693D346E-069E-4306-9F7C-84665CD42141}':
                exit("{693D346E-069E-4306-9F7C-84665CD42141}Lbl");
            '{55AD5167-785F-4CC3-B633-84A8414EE100}':
                exit("{55AD5167-785F-4CC3-B633-84A8414EE100}Lbl");
            '{4C0ECC95-F5CD-46B2-B302-84C3A5AD7D4E}':
                exit("{4C0ECC95-F5CD-46B2-B302-84C3A5AD7D4E}Lbl");
            '{E06B429C-0CDD-4F49-9C4D-8546151805AD}':
                exit("{E06B429C-0CDD-4F49-9C4D-8546151805AD}Lbl");
            '{E076372D-BFB5-4911-B6EE-85F1F71B1569}':
                exit("{E076372D-BFB5-4911-B6EE-85F1F71B1569}Lbl");
            '{1CB4368B-D6AF-4B89-AFEB-8641B0152451}':
                exit("{1CB4368B-D6AF-4B89-AFEB-8641B0152451}Lbl");
            '{A4461039-C91C-4102-9438-866AF5607096}':
                exit("{A4461039-C91C-4102-9438-866AF5607096}Lbl");
            '{38C5A554-206D-44A5-9090-86CAC52A7715}':
                exit("{38C5A554-206D-44A5-9090-86CAC52A7715}Lbl");
            '{B83A838B-C0A8-4E69-B735-86D011229B1C}':
                exit("{B83A838B-C0A8-4E69-B735-86D011229B1C}Lbl");
        end;
        case CaseID of
            '{23B7CD0D-EA02-4835-9AE8-875813B138F0}':
                exit("{23B7CD0D-EA02-4835-9AE8-875813B138F0}Lbl");
            '{9DFF9CBE-B1A5-4D28-A855-8783315A87D0}':
                exit("{9DFF9CBE-B1A5-4D28-A855-8783315A87D0}Lbl");
            '{CCF41113-DC62-47E2-B45B-87AF0248AF65}':
                exit("{CCF41113-DC62-47E2-B45B-87AF0248AF65}Lbl");
            '{2CEB6A3E-11E4-420F-A3C6-886B920BEC29}':
                exit("{2CEB6A3E-11E4-420F-A3C6-886B920BEC29}Lbl");
            '{36017702-208F-4E8C-A75E-8872EA7D1205}':
                exit("{36017702-208F-4E8C-A75E-8872EA7D1205}Lbl");
            '{A8BF5AD2-5132-40E7-9DF1-893B3940F6EE}':
                exit("{A8BF5AD2-5132-40E7-9DF1-893B3940F6EE}Lbl");
            '{990AEEEE-91BD-4C0E-8346-897F141E4EDB}':
                exit("{990AEEEE-91BD-4C0E-8346-897F141E4EDB}Lbl");
            '{BBA0DF22-691B-46EB-8500-8B270596F2E9}':
                exit("{BBA0DF22-691B-46EB-8500-8B270596F2E9}Lbl");
            '{CFE77ACE-1F20-4126-98D9-8D14B18088EE}':
                exit("{CFE77ACE-1F20-4126-98D9-8D14B18088EE}Lbl");
            '{A8FE6EC6-8FE0-42C6-AE40-8D3B2BC638C0}':
                exit("{A8FE6EC6-8FE0-42C6-AE40-8D3B2BC638C0}Lbl");
        end;

        Handled := false;
    end;
}
