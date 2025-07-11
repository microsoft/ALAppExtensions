// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Service.Reports;
using System.IO;
using System.Upgrade;
using System.Utilities;

codeunit 12225 ServDeclITUpgrade
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateDefaultDataExchangeDef();
    end;

    procedure UpdateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        ServiceDeclarationMgtIT: Codeunit "Service Declaration Mgt. IT";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if UpgradeTag.HasUpgradeTag(GetServiceDeclarationITSumUpgradeTag()) then
            exit;

        if DataExchDef.Get('SERVDECLITP-2023') then begin
            DataExchDef.Delete(true);
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(ServiceDeclarationMgtIT.GetPurchaseDataExchDefinition());
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if DataExchDef.Get('SERVDECLITS-2023') then begin
            DataExchDef.Delete(true);
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(ServiceDeclarationMgtIT.GetSaleDataExchDefinition());
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if DataExchDef.Get('SERVDECLITPC-2023') then begin
            DataExchDef.Delete(true);
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(ServiceDeclarationMgtIT.GetPurchaseCorrectionDataExchDefinition());
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        if DataExchDef.Get('SERVDECLITSC-2023') then begin
            DataExchDef.Delete(true);
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(ServiceDeclarationMgtIT.GetSaleCorrectionDataExchDefinition());
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
            Clear(TempBlob);
        end;

        UpgradeTag.SetUpgradeTag(GetServiceDeclarationITSumUpgradeTag());
    end;

    local procedure GetServiceDeclarationITSumUpgradeTag(): Code[250]
    begin
        exit('MS-569038-ServiceDeclarationITSum-20250324');
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetServiceDeclarationITSumUpgradeTag());
    end;
}