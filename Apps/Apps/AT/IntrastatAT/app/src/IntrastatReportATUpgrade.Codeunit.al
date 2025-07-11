// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Upgrade;
using System.IO;
using System.Utilities;

codeunit 11161 IntrastatReportATUpgrade
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateDefaultDataExchangeDef();
    end;

    procedure UpdateDefaultDataExchangeDef()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportMgtAT: Codeunit IntrastatReportManagementAT;
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        if UpgradeTag.HasUpgradeTag(GetIntrastatATDecimalPrecisionUpgradeTag()) then
            exit;

        if DataExchDef.Get('INTRA-2022-AT') then begin
            DataExchDef.Delete(true);

            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(IntrastatReportMgtAT.GetDataExchangeXMLTxt());
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        end;

        UpgradeTag.SetUpgradeTag(GetIntrastatATDecimalPrecisionUpgradeTag());
    end;

    local procedure GetIntrastatATDecimalPrecisionUpgradeTag(): Code[250]
    begin
        exit('MS-547639-IntrastatATDecimalPrecision-20250117');
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetIntrastatATDecimalPrecisionUpgradeTag());
    end;
}