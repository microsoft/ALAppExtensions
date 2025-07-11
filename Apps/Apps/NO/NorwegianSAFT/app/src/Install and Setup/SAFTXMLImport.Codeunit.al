// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Reporting;
using System.Environment;
using System.IO;
using System.Utilities;

codeunit 10671 "SAF-T XML Import"
{
    Permissions = TableData "Tenant Media" = rimd;
    TableNo = "SAF-T Mapping Range";

    var
        ImportingSourceForMappingLbl: Label 'Importing source for mapping...';
        NotPossibleToFindXMLFilesForMappingTypeErr: Label 'Not possible to find the XML files for mapping type %1', Comment = '%1 = a mapping type, one of the following - SAF-T Standard Account, Income Statement';
        NotPossibleToParseMappingXMLFileErr: Label 'Not possible to parse XML file with %1 for mapping', Comment = '%1 = a mapping type, one of the following - SAF-T Standard Account, Income Statement';
        MappingFileNotLoadedErr: Label 'Mapping source file %1 was not loaded. Choose the Import the Source Files For Mapping action and import one or more mapping source files.', Comment = '%1 = file name, like StandardVATCodes.xml';
        NoMappingSourceIdentifiedErr: Label 'Not possible to identify mapping source type %1. Open a SAF-T Mapping Source page and import source file with such type', Comment = '%1 = possible values: Two Digit Standard Account, Four Digit Standard Account, Income Statement, Standard Tax Code';
        SAFTStandardAccountsTxt: Label 'SAF-T Standard Accounts';
        SAFTGroupingCodesTxt: Label 'SAF-T Grouping Codes';
        SAFTTaxCodeTxt: Label 'SAF-T Tax Codes';
        SelectMappingTxt: Label 'Select an XML file with SAF-T codes for mapping';
        NATxt: Label 'NA', Comment = 'Abbreviation from Not Applicable';
        NotApplicableTxt: Label 'Not applicable';
        AssetsLbl: Label 'Assets';
        LiabilityAndCapitalLbl: Label 'Liability and capital';
        RevenueLbl: Label 'Revenue';
        PurchaseLbl: Label 'Purchase';
        SaleriesAndHRCostsLbl: Label 'Salaries and HR Costs';
        OtherCostsLbl: Label 'Other costs';
        FinanceLbl: Label 'Finance';
        CannotFindCategotyForStdAccErr: Label 'Not possible to find category for standard account %1', Comment = '%1 - standard account no.';
        TenantMediaNoContentErr: Label 'Tenant media %1 has no content. Open the SAF-T Mapping Source page and choose the Update action on selected tenant media code.', Comment = 'File name, like GeneralLedgerAccounts.xml';

    trigger OnRun()
    var
        Window: Dialog;
    begin
        if GuiAllowed() then
            Window.Open(ImportingSourceForMappingLbl);
        ImportMappingData(Rec);
        ImportStandardVATCodes();
        iF GuiAllowed() then
            Window.Close();
    end;

    local procedure ImportMappingData(SAFTMappingRange: Record "SAF-T Mapping Range")
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        CopyTenantMediaToTempFromMappingSources(TempTenantMedia, SAFTMappingRange.GetSAFTMappingSourceTypeByMappingType(), false);
        if not TempTenantMedia.FindSet() then
            error(NotPossibleToFindXMLFilesForMappingTypeErr, format(SAFTMappingRange."Mapping Type"));
        repeat
            FillXMLBufferFromMediaResource(TempXMLBuffer, TempTenantMedia);
            Case SAFTMappingRange."Mapping Type" of
                SAFTMappingRange."Mapping Type"::"Two Digit Standard Account", SAFTMappingRange."Mapping Type"::"Four Digit Standard Account":
                    ImportStandardAccountsFromXMLBuffer(TempXMLBuffer, SAFTMappingRange."Mapping Type");
                SAFTMappingRange."Mapping Type"::"Income Statement":
                    ImportGroupingCodesFromXMLBuffer(TempXMLBuffer);
            end;
        until TempTenantMedia.Next() = 0;
    end;

    procedure ImportFromMappingSource(SAFTMappingSource: Record "SAF-T Mapping Source")
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        if not CopyTenantMediaToTempFromMappingSource(TempTenantMedia, SAFTMappingSource) then
            exit;
        FillXMLBufferFromMediaResource(TempXMLBuffer, TempTenantMedia);
        Case SAFTMappingSource."Source Type" of
            SAFTMappingSource."Source Type"::"Two Digit Standard Account", SAFTMappingSource."Source Type"::"Four Digit Standard Account":
                ImportStandardAccountsFromXMLBuffer(TempXMLBuffer, GetMappingTypeBySourceType(SAFTMappingSource."Source Type"));
            SAFTMappingSource."Source Type"::"Income Statement":
                ImportGroupingCodesFromXMLBuffer(TempXMLBuffer);
        end;

        if SAFTMappingSource."Source Type" = SAFTMappingSource."Source Type"::"Standard Tax Code" then
            ImportStandardVATReportingCodesFromXMLBuffer(TempXMLBuffer);
    end;

    procedure ImportStandardVATCodes()
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
        SAFTSetup: Record "SAF-T Setup";
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        SAFTSetup.Get();
        CopyTenantMediaToTempFromMappingSources(TempTenantMedia, SAFTMappingSourceType::"Standard Tax Code", false);
        FillXMLBufferFromMediaResource(TempXMLBuffer, TempTenantMedia);
        ImportStandardVATReportingCodesFromXMLBuffer(TempXMLBuffer);
        SAFTSetup.Validate("Not Applic. VAT Code", InsertNotApplicableVATReportingCode());
        SAFTSetup.Modify(true);
    end;

    procedure MappingSourceLoaded(SAFTMappingRange: Record "SAF-T Mapping Range"): Boolean
    var
        TempTenantMedia: Record "Tenant Media" temporary;
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        exit(
            CopyTenantMediaToTempFromMappingSources(TempTenantMedia, SAFTMappingRange.GetSAFTMappingSourceTypeByMappingType(), true) and
            CopyTenantMediaToTempFromMappingSources(TempTenantMedia, SAFTMappingSourceType::"Standard Tax Code", true));
    end;

    local procedure ImportStandardVATReportingCodesFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        VATReportingCode: Record "VAT Reporting Code";
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/StandardTaxCodes/TaxCode') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTTaxCodeTxt);
        if not TempXMLBuffer.HasChildNodes() then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTTaxCodeTxt);
        repeat
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            VATReportingCode.Init();
            VATReportingCode.Code := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(VATReportingCode.Code));
            TempChildXMLBuffer.Next();
            VATReportingCode.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(VATReportingCode.Description));
            TempChildXMLBuffer.Next(); // skip eng description
            TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'TaxRate' then
                TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'Compensation' then
                Evaluate(VATReportingCode.Compensation, TempChildXMLBuffer.Value);
            if VATReportingCode.Insert() then;
        until TempXMLBuffer.Next() = 0;
    end;

    local procedure ImportStandardAccountsFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; MappingType: Enum "SAF-T Mapping Type")
    var
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        SAFTMapping: Record "SAF-T Mapping";
        StdAccNo: Code[20];
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/StandardAccounts/Account') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTStandardAccountsTxt);
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, SAFTStandardAccountsTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            if (strlen(TempChildXMLBuffer.Value) > 4) then
                Error('Standard account id must not has length more than 4 chars');
            StdAccNo := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping."No."));
            SAFTMapping.Init();
            SAFTMapping."Mapping Type" := MappingType;
            SAFTMapping."Category No." := TryInsertCategoryForStandardAccount(SAFTMapping."Mapping Type", StdAccNo);
            SAFTMapping."No." := StdAccNo;
            TempChildXMLBuffer.Next();
            SAFTMapping.Description := copystr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping.Description));
            if SAFTMapping.insert() then;
        until TempXMLBuffer.Next() = 0;
        InsertNotApplicationMappingCode(MappingType);
    end;

    local procedure InsertNotApplicationMappingCode(MappingType: Enum "SAF-T Mapping Type")
    var
        SAFTMapping: Record "SAF-T Mapping";
    begin
        SAFTMapping.Init();
        SAFTMapping."Mapping Type" := MappingType;
        SAFTMapping."Category No." := TryInsertSAFTMappingCategory(MappingType, NATxt, NotApplicableTxt);
        SAFTMapping."No." := NATxt;
        SAFTMapping.Description := NotApplicableTxt;
        if SAFTMapping.Insert() then;
    end;

    local procedure InsertNotApplicableVATReportingCode(): Code[20]
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATReportingCode.Init();
        VATReportingCode.Code := NATxt;
        VATReportingCode.Description := NotApplicableTxt;
        if not VATReportingCode.Insert() then;
        exit(VATReportingCode.Code)
    end;

    local procedure ImportGroupingCodesFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        CategoryCode: Code[20];
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/GroupingCategoryCode/Account') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTGroupingCodesTxt);
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, SAFTGroupingCodesTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            CategoryCode := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(CategoryCode));
            if CategoryCode <> SAFTMappingCategory."No." then begin
                SAFTMappingCategory.Init();
                SAFTMappingCategory."Mapping Type" := SAFTMappingCategory."Mapping Type"::"Income Statement";
                SAFTMappingCategory."No." := CategoryCode;
                TempChildXMLBuffer.Next();
                SAFTMappingCategory.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMappingCategory.Description));
                if not SAFTMappingCategory.insert() then
                    SAFTMappingCategory.Modify();
            end else
                TempChildXMLBuffer.Next();

            SAFTMapping.Init();
            SAFTMapping."Mapping Type" := SAFTMapping."Mapping Type"::"Income Statement";
            SAFTMapping."Category No." := SAFTMappingCategory."No.";
            TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'CategoryDescription' then
                TempChildXMLBuffer.Next();
            SAFTMapping."No." := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping."No."));
            TempChildXMLBuffer.Next();
            SAFTMapping.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping.Description));
            if not SAFTMapping.insert() then
                SAFTMapping.Modify();
        until TempXMLBuffer.Next() = 0;
        InsertNotApplicationMappingCode(SAFTMapping."Mapping Type");
    end;

    local procedure CopyTenantMediaToTempFromMappingSources(var TempTenantMedia: Record "Tenant Media" temporary; SAFTMappingSourceType: Enum "SAF-T Mapping Source Type"; CheckOnly: Boolean) MappingSourceFileLoaded: Boolean;
    var
        TenantMedia: Record "Tenant Media";
        SAFTMappingSource: Record "SAF-T Mapping Source";
        TenantMediaExists: Boolean;
    begin
        SAFTMappingSource.SetRange("Source Type", SAFTMappingSourceType);
        if not SAFTMappingSource.FindSet() then begin
            if CheckOnly then
                exit(false);
            error(NoMappingSourceIdentifiedErr, Format(SAFTMappingSourceType));
        end;
        repeat
            MappingSourceFileLoaded := false;
            TenantMediaExists := false;
            if GetTenantMediaFromMappingSourceNo(TenantMedia, SAFTMappingSource."Source No.") then
                TenantMediaExists := true
            else
                TenantMediaExists := InitTenantMediaFromMediaResources(TenantMedia, SAFTMappingSource."Source No.");
            if TenantMediaExists then begin
                TenantMedia.CalcFields(Content);
                if TenantMedia.Content.HasValue() then begin
                    TempTenantMedia.Init();
                    TempTenantMedia := TenantMedia;
                    if not TempTenantMedia.Find() then
                        TempTenantMedia.Insert();
                    MappingSourceFileLoaded := true;
                end;
            end;
            if (not MappingSourceFileLoaded) and (not CheckOnly) then
                error(MappingFileNotLoadedErr, SAFTMappingSource."Source No.");
        until SAFTMappingSource.Next() = 0;
        exit(MappingSourceFileLoaded);
    end;

    local procedure CopyTenantMediaToTempFromMappingSource(var TempTenantMedia: Record "Tenant Media" temporary; SAFTMappingSource: Record "SAF-T Mapping Source"): Boolean
    var
        TenantMedia: Record "Tenant Media";
    begin
        if not GetTenantMediaFromMappingSourceNo(TenantMedia, SAFTMappingSource."Source No.") then
            if not InitTenantMediaFromMediaResources(TenantMedia, SAFTMappingSource."Source No.") then
                exit(false);
        TenantMedia.CalcFields(content);
        TempTenantMedia.Init();
        TempTenantMedia := TenantMedia;
        if not TempTenantMedia.Find() then
            TempTenantMedia.Insert();
        exit(true);
    end;

    local procedure GetTenantMediaFromMappingSourceNo(var TenantMedia: Record "Tenant Media"; SourceNo: Code[50]): Boolean
    begin
        TenantMedia.SetRange("Company Name", CompanyName());
        TenantMedia.SetRange("File Name", UpperCase(SourceNo));
        exit(TenantMedia.FindFirst());
    end;

    local procedure InitTenantMediaFromMediaResources(var TenantMedia: Record "Tenant Media"; SourceNo: Code[50]): Boolean
    var
        MediaResources: Record "Media Resources";
        TempBlob: Codeunit "Temp Blob";
        ImportFileInStream: InStream;
        ImportFileOutStream: OutStream;
    begin
        if not MediaResources.Get(SourceNo) then
            exit(false);
        TempBlob.CreateOutStream(ImportFileOutStream);
        MediaResources.CalcFields(Blob);
        MediaResources.Blob.CreateInStream(ImportFileInStream);
        CopyStream(ImportFileOutStream, ImportFileInStream);
        InsertTenantMediaRecWithTempBlob(TenantMedia, TempBlob, SourceNo);
        exit(true);
    end;

    local procedure FillXMLBufferFromMediaResource(var TempXMLBuffer: Record "XML Buffer" temporary; var TempTenantMedia: Record "Tenant Media" temporary)
    var
        XMLText: Text;
        TextInStream: InStream;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        TempTenantMedia.CalcFields(Content);
        TempTenantMedia.Content.CreateInStream(TextInStream, TEXTENCODING::UTF8);
        TextInStream.Read(XMLText);
        if XMLText = '' then
            Error(TenantMediaNoContentErr, TempTenantMedia.ID);
        TempXMLBuffer.LoadFromText(XMLText);
    end;

    procedure ImportXmlFileIntoTenantMedia(var TenantMedia: Record "Tenant Media")
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ClientFileName: Text;
        FileName: Code[50];
    begin
        ClientFileName := FileManagement.BLOBImportWithFilter(TempBlob, SelectMappingTxt, '', 'XML file (*.xml)|*.xml', 'xml');
        if ClientFileName = '' then
            exit;

        FileName := COPYSTR(FileManagement.GetFileName(ClientFileName), 1, MAXSTRLEN(FileName));
        If GetTenantMediaFromMappingSourceNo(TenantMedia, FileName) then
            TenantMedia.Delete();
        InsertTenantMediaRecWithTempBlob(TenantMedia, TempBlob, FileName);
    end;

    local procedure InsertTenantMediaRecWithTempBlob(var TenantMedia: Record "Tenant Media"; var TempBlob: Codeunit "Temp Blob"; FileName: Code[50])
    var
        ImportFileInStream: InStream;
        ImportFileOutStream: OutStream;
    begin
        TenantMedia.Init();
        TenantMedia.Id := CreateGuid();
        TenantMedia."File Name" := UpperCase(FileName);
        TempBlob.CreateInStream(ImportFileInStream);
        TenantMedia.Content.CreateOutStream(ImportFileOutStream);
        CopyStream(ImportFileOutStream, ImportFileInStream);
        TenantMedia."Company Name" := CompanyName();
        TenantMedia.Insert();
    end;

    local procedure GetMappingTypeBySourceType(SourceType: Enum "SAF-T Mapping Source Type") MappingType: Enum "SAF-T Mapping Type"
    begin
        case SourceType of
            SourceType::"Two Digit Standard Account":
                exit(MappingType::"Two Digit Standard Account");
            SourceType::"Four Digit Standard Account":
                exit(MappingType::"Four Digit Standard Account");
        end;
    end;

    local procedure TryInsertCategoryForStandardAccount(MappingType: Enum "SAF-T Mapping Type"; StdAccNo: Code[20]): Code[20]
    var
        CategoryNo: COde[20];
    begin
        CategoryNo := copystr(StdAccNo, 1, 1);
        case CategoryNo of
            '1':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, AssetsLbl));
            '2':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, LiabilityAndCapitalLbl));
            '3':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, RevenueLbl));
            '4':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, PurchaseLbl));
            '5':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, SaleriesAndHRCostsLbl));
            '6', '7':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, OtherCostsLbl));
            '8':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, FinanceLbl));
            else
                error(CannotFindCategotyForStdAccErr, StdAccNo);
        end;
    end;

    local procedure TryInsertSAFTMappingCategory(MappingType: Enum "SAF-T Mapping Type"; CategoryNo: Code[20]; Description: Text[250]): Code[20]
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
    begin
        SAFTMappingCategory.Init();
        SAFTMappingCategory."Mapping Type" := MappingType;
        SAFTMappingCategory."No." := CategoryNo;
        SAFTMappingCategory.Description := Description;
        if not SAFTMappingCategory.insert() then
            SAFTMappingCategory.modify();
        exit(SAFTMappingCategory."No.");
    end;
}
