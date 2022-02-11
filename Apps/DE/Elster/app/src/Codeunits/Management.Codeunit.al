// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11023 "Elster Management"
{
    var
        SubmissionMessageNotCreatedErr: Label 'No submission message has been created. Press the Create action to generate it.';
        CannotIdentifyAmountsErr: Label 'Cannot identify XML nodes related to amounts in the submission message.';

    procedure GetElsterUpgradeTag(): Code[250];
    begin
        exit('MS-332065-ElsterUpgrade-20191029');
    end;

    procedure GetCleanupElsterTag(): Code[250];
    begin
        exit('MS-332065-CleanupElster-20191029');
    end;

    procedure ShowElecVATDeclOverview(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.")
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempElecVATDeclBuffer: Record "Elec. VAT Decl. Buffer" temporary;
        XmlInStream: InStream;
        RowNo: Integer;
    begin
        if not SalesVATAdvanceNotif."XML Submission Document".HasValue() then
            Error(SubmissionMessageNotCreatedErr);

        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        SalesVATAdvanceNotif."XML Submission Document".CreateInStream(XmlInStream, TextEncoding::UTF8);
        TempXMLBuffer.LoadFromStream(XmlInStream);
        if not TempXMLBuffer.FindNodesByXPath(
            TempXMLBuffer, '/Elster/DatenTeil/Nutzdatenblock/Nutzdaten/Anmeldungssteuern/Steuerfall/Umsatzsteuervoranmeldung/Kz*')
        then
            error(CannotIdentifyAmountsErr);
        TempXMLBuffer.FindSet();
        repeat
            Evaluate(RowNo, DelChr(TempXMLBuffer.Name, '=', DelChr(TempXMLBuffer.Name, '=', '1234567890')));
            if not (RowNo in [9, 10, 22, 23, 26, 29]) then begin
                TempElecVATDeclBuffer.Code := '#' + Format(RowNo);
                Evaluate(TempElecVATDeclBuffer.Amount, TempXMLBuffer.Value);
                TempElecVATDeclBuffer.Insert();
            end;
        until TempXMLBuffer.Next() = 0;
        Page.Run(0, TempElecVATDeclBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetElsterUpgradeTag());
        PerCompanyUpgradeTags.Add(GetCleanupElsterTag());
    end;
}
